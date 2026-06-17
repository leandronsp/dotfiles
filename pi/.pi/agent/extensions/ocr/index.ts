/**
 * OCR Extension — automatic image → text for non-vision models
 *
 * Hooks into before_agent_start. When images are attached to a message and the
 * current model lacks vision support, OCR extracts the text automatically.
 * No user action needed — images are transparently converted to text.
 *
 * Pipeline:
 *   1. image-use (Apple Vision, Neural Engine) — primary, best accuracy
 *   2. Tesseract + PIL enhance (5x upscale, unsharp mask) — fallback
 *
 * Also works with images sent via the Neovim bridge (![alt](path.png) syntax).
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { writeFile, unlink } from "node:fs/promises";
import { join } from "node:path";
import { tmpdir } from "node:os";

const execFileAsync = promisify(execFile);

// ── Config ─────────────────────────────────────────────────────────────

const TESSERACT_LANG = "eng+por";
const TESSERACT_TIMEOUT = 30_000;
const TESSERACT_MAX_BUFFER = 2 * 1024 * 1024;

// ── Helpers ────────────────────────────────────────────────────────────

function mediaTypeToExt(mediaType: string): string {
	const map: Record<string, string> = {
		"image/png": "png",
		"image/jpeg": "jpg",
		"image/gif": "gif",
		"image/webp": "webp",
		"image/bmp": "bmp",
		"image/tiff": "tiff",
	};
	return map[mediaType] || "png";
}

async function writeTempImage(buffer: Buffer, ext: string): Promise<string> {
	const tmpPath = join(tmpdir(), `pi-ocr-${Date.now()}-${Math.random().toString(36).slice(2, 6)}.${ext}`);
	await writeFile(tmpPath, buffer);
	return tmpPath;
}

async function writeTempEnhanced(originalPath: string): Promise<string> {
	const enhancedPath = join(tmpdir(), `pi-ocr-enhanced-${Date.now()}.png`);
	try {
		await execFileAsync("python3", [
			"-c",
			`
from PIL import Image, ImageEnhance, ImageFilter, ImageOps
img = Image.open("${originalPath}")
# Convert to grayscale
img = img.convert('L')
# Auto-levels (stretch histogram, cutoff=1 preserves dark text)
img = ImageOps.autocontrast(img, cutoff=1)
# Upscale 5x — better for small monospace fonts
img = img.resize((img.width * 5, img.height * 5), Image.LANCZOS)
# Light median filter to remove JPEG artifacts without blurring text
img = img.filter(ImageFilter.MedianFilter(1))
# Sharpen with unsharp mask (radius=1, amount=200%) — fine detail
img = img.filter(ImageFilter.UnsharpMask(radius=1, percent=200, threshold=2))
# Moderate contrast boost
img = ImageEnhance.Contrast(img).enhance(1.5)
img.save("${enhancedPath}")
`,
		], { timeout: 15_000 });
		return enhancedPath;
	} catch {
		return originalPath;
	}
}

// ── OCR ────────────────────────────────────────────────────────────────

async function tesseract(imagePath: string, psm: number, oem = 1): Promise<string> {
	try {
		const { stdout } = await execFileAsync("tesseract", [
			imagePath,
			"stdout",
			"-l", TESSERACT_LANG,
			"--psm", String(psm),
			"--oem", String(oem),
		], {
			timeout: TESSERACT_TIMEOUT,
			maxBuffer: TESSERACT_MAX_BUFFER,
		});
		return stdout;
	} catch {
		return "";
	}
}

async function visionOcr(imagePath: string): Promise<string> {
	try {
		const { stdout } = await execFileAsync("image-use", [
			"--lang", "en,pt",
			imagePath,
		], { timeout: 15_000 });
		return stdout;
	} catch {
		return "";
	}
}

function guessImageType(text: string): "code" | "ui" | "document" | "terminal" | "unknown" {
	const t = text.trim();
	if (!t) return "unknown";

	// Code: lots of indentation, punctuation, common keywords
	const codePatterns = /\b(function|def|class|import|export|const|let|var|return|if|else|for|while|async|await)\b/;
	const bracketDensity = (t.match(/[{}()[\];]/g) || []).length / Math.max(t.length, 1);
	if (codePatterns.test(t) || bracketDensity > 0.03) return "code";

	// Terminal: prompt chars, paths, common commands
	const terminalPatterns = /[#$>]\s|\/\w+\/\w+|\.\w{2,4}\b|error|warning|fail|success/i;
	const shortLines = t.split("\n").filter(l => l.trim().length > 0 && l.trim().length < 120).length;
	if (terminalPatterns.test(t) && shortLines > 2) return "terminal";

	// UI: buttons, labels, navigation, common app words
	const uiPatterns = /\b(button|settings|save|cancel|submit|delete|edit|create|search|filter|menu|home|profile|logout|login|sign.up|dashboard|admin|loading|click|here|page|tab|form|select|choose|toggle|switch)\b/i;
	if (uiPatterns.test(t)) return "ui";

	// Document: long paragraphs, punctuation flow
	const avgLineLength = t.split("\n").reduce((s, l) => s + l.length, 0) / Math.max(t.split("\n").length, 1);
	if (avgLineLength > 60) return "document";

	return "unknown";
}

function cleanupOcrOutput(text: string): string {
	// Remove long numeric strings (memory addresses, hex dumps)
	text = text.replace(/\b[0-9a-fA-F]{10,}\b/g, "");

	// Fix common bracket OCR errors
	text = text.replace(/\{]/g, "[]");
	text = text.replace(/\[}/g, "[]");
	text = text.replace(/\(\[\]/g, "[]");

	// Collapse whitespace
	text = text.replace(/[ \t]{3,}/g, "  ");

	// Remove noise lines (1-3 chars of non-text)
	text = text
		.split("\n")
		.filter((line) => {
			const trimmed = line.trim();
			if (trimmed.length === 0) return true;
			if (trimmed.length <= 3 && /^[^a-zA-Zá-úÁ-Ú]*$/.test(trimmed)) return false;
			return true;
		})
		.join("\n");

	// Collapse blank lines
	text = text.replace(/\n{4,}/g, "\n\n\n");

	return text.trim();
}

async function ocrImage(image: {
	type: string;
	source: { type: string; data?: string; url?: string; mediaType?: string; path?: string };
}): Promise<string> {
	let tmpPath: string | null = null;

	try {
		// Decode image source to temp file
		if (image.source.type === "base64" && image.source.data) {
			const buffer = Buffer.from(image.source.data, "base64");
			const ext = mediaTypeToExt(image.source.mediaType || image.type);
			tmpPath = await writeTempImage(buffer, ext);
		} else if (image.source.type === "url" && image.source.url) {
			const ext = "png";
			tmpPath = join(tmpdir(), `pi-ocr-url-${Date.now()}.png`);
			await execFileAsync("curl", ["-sL", "--max-time", "15", "-o", tmpPath, image.source.url]);
		} else if (image.source.type === "file" && (image.source as any).path) {
			tmpPath = (image.source as any).path;
		} else {
			return "";
		}

		if (!tmpPath) return "";

		// Stage 1: Apple Vision (image-use) — best accuracy, Neural Engine
		const visionText = await visionOcr(tmpPath);
		if (visionText.trim().length >= 20) return cleanupOcrOutput(visionText);

		// Stage 2: Enhanced + Tesseract pipeline
		const enhanced = await writeTempEnhanced(tmpPath);
		let text = "";

		// PSM 3 (auto page) — handles mixed markdown + code + paragraphs
		text = await tesseract(enhanced, 3, 1);
		if (text.trim().length >= 20) {
			if (enhanced !== tmpPath) await unlink(enhanced).catch(() => {});
			return cleanupOcrOutput(text);
		}

		// PSM 4 on enhanced (single column) — fallback for uniform documents
		const psm4 = await tesseract(enhanced, 4, 1);
		if (psm4.trim().length > text.trim().length) text = psm4;

		// PSM 6 on enhanced (uniform block) — fallback for code/terminal
		const psm6 = await tesseract(enhanced, 6, 1);
		if (psm6.trim().length > text.trim().length) text = psm6;

		if (enhanced !== tmpPath) await unlink(enhanced).catch(() => {});

		if (text.trim().length >= 10) return cleanupOcrOutput(text);

		// Stage 2: Fall back to raw image with PSM 3
		const raw = await tesseract(tmpPath, 3, 1);
		if (raw.trim().length > text.trim().length) text = raw;

		if (text.trim().length >= 5) return cleanupOcrOutput(text);

		// Stage 3: PSM 11 (sparse text) + PSM 12 (sparse with OSD)
		const sparse = await tesseract(tmpPath, 11, 1);
		if (sparse.trim().length > text.trim().length) text = sparse;

		return cleanupOcrOutput(text);
	} finally {
		if (tmpPath && image.source.type !== "file") {
			await unlink(tmpPath).catch(() => {});
		}
	}
}

// ── Extension ──────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	pi.on("before_agent_start", async (event, ctx) => {
		if (!event.images || event.images.length === 0) return;

		const model = ctx.model;
		if (!model) return;

		// Skip if model already supports images natively
		if (model.input?.includes("image")) return;

		const ocrResults: string[] = [];

		for (let i = 0; i < event.images.length; i++) {
			const image = event.images[i];
			try {
				const text = await ocrImage(image);
				const cleaned = cleanupOcrOutput(text);

				if (cleaned) {
					const imgType = guessImageType(cleaned);
					ocrResults.push(
						`### Image ${i + 1}${imgType !== "unknown" ? ` (${imgType})` : ""}\n\n${cleaned}`,
					);
				} else {
					ocrResults.push(
						`### Image ${i + 1}\nNo text detected. This image likely contains a drawing, diagram, or photo without readable text.`,
					);
				}
			} catch (err) {
				ocrResults.push(
					`### Image ${i + 1}\nOCR error: ${err instanceof Error ? err.message : String(err)}`,
				);
			}
		}

		if (ocrResults.length === 0) return;

		const ocrText = ocrResults.join("\n\n---\n\n");

		return {
			message: {
				customType: "ocr-fallback",
				content: `[OCR] Text extracted from ${event.images.length} attached image(s):\n\n${ocrText}`,
				display: true,
			},
		};
	});
}
