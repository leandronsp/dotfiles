/**
 * Neovim Bridge Extension
 *
 * Watches /tmp/pi-nvim-bridge.md for changes from Neovim.
 * Supports @file references (expands to file content) and ![alt](img) images.
 *
 * Also registers /nvim-read command as manual fallback.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { watch, readFileSync, writeFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";
import { homedir } from "node:os";

const BRIDGE_IN = "/tmp/pi-nvim-bridge.md";
let lastSentHash = "";
let lastSentTime = 0;
const COOLDOWN_MS = 1000;
let watcher: ReturnType<typeof watch> | null = null;

function resolvePath(raw: string, cwd: string): string {
	if (raw.startsWith("~")) return raw.replace("~", homedir());
	if (raw.startsWith("/")) return raw;
	return resolve(cwd, raw);
}

function isImagePath(p: string): boolean {
	return /\.(png|jpe?g|gif|webp|bmp)$/i.test(p);
}

function mediaTypeFromPath(p: string): string {
	const ext = p.split(".").pop()?.toLowerCase() || "png";
	const map: Record<string, string> = {
		png: "image/png", jpg: "image/jpeg", jpeg: "image/jpeg",
		gif: "image/gif", webp: "image/webp", bmp: "image/bmp",
	};
	return map[ext] || "image/png";
}

type ContentBlock = { type: "text"; text: string } | { type: "image"; source: { type: "base64"; mediaType: string; data: string } };

function parseAndExpand(raw: string, cwd: string): ContentBlock[] {
	const blocks: ContentBlock[] = [];

	const imgRegex = /!\[([^\]]*)\]\(([^)]+)\)/g;
	let lastIdx = 0;
	let match: RegExpExecArray | null;

	while ((match = imgRegex.exec(raw)) !== null) {
		const before = raw.slice(lastIdx, match.index);
		if (before.trim()) {
			blocks.push(...expandAtRefs(before, cwd));
		}

		const imgPath = resolvePath(match[2], cwd);
		try {
			if (existsSync(imgPath) && isImagePath(imgPath)) {
				const data = readFileSync(imgPath).toString("base64");
				blocks.push({
					type: "image",
					source: { type: "base64", mediaType: mediaTypeFromPath(imgPath), data },
				});
			} else {
				blocks.push({ type: "text", text: `[image not found: ${match[2]}]` });
			}
		} catch {
			blocks.push({ type: "text", text: `[image error: ${match[2]}]` });
		}

		lastIdx = imgRegex.lastIndex;
	}

	const tail = raw.slice(lastIdx);
	if (tail.trim()) {
		blocks.push(...expandAtRefs(tail, cwd));
	}

	return blocks;
}

function expandAtRefs(text: string, cwd: string): ContentBlock[] {
	const blocks: ContentBlock[] = [];

	const atRegex = /(?:^|\s)@([^\s,;:!?()]+)/g;
	let lastIdx = 0;
	let match: RegExpExecArray | null;

	while ((match = atRegex.exec(text)) !== null) {
		const prefix = text.slice(lastIdx, match.index);
		if (prefix) blocks.push({ type: "text", text: prefix });

		const rawPath = match[1];
		const absPath = resolvePath(rawPath, cwd);

		try {
			if (existsSync(absPath) && !isImagePath(absPath)) {
				const content = readFileSync(absPath, "utf-8");
				const lang = rawPath.split(".").pop() || "";
				blocks.push({ type: "text", text: `@${rawPath}:\n\`\`\`${lang}\n${content.trim()}\n\`\`\`` });
			} else {
				blocks.push({ type: "text", text: match[0] });
			}
		} catch {
			blocks.push({ type: "text", text: match[0] });
		}

		lastIdx = atRegex.lastIndex;
	}

	const tail = text.slice(lastIdx);
	if (tail) blocks.push({ type: "text", text: tail });

	return blocks;
}

function sendIfNew(pi: ExtensionAPI, cwd: string): boolean {
	try {
		if (!existsSync(BRIDGE_IN)) return false;

		const raw = readFileSync(BRIDGE_IN, "utf-8").trim();
		if (!raw) return false;

		// Hash-based dedup + cooldown — avoids double-send from duplicate fs.watch events
		const now = Date.now();
		if (now - lastSentTime < COOLDOWN_MS) return false;

		const hash = require("node:crypto").createHash("sha256").update(raw).digest("hex");
		if (hash === lastSentHash) return false;

		lastSentHash = hash;
		lastSentTime = now;

		const blocks = parseAndExpand(raw, cwd);

		// Clear BEFORE sending — sendUserMessage is async, watcher
		// callbacks can fire before the file is cleared otherwise
		writeFileSync(BRIDGE_IN, "", "utf-8");
		pi.sendUserMessage(blocks, { deliverAs: "steer" });
		return true;
	} catch {
		return false;
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("nvim-read", {
		description: "Read pending Neovim bridge messages (@file, ![img])",
		handler: async (_args, ctx) => {
			const sent = sendIfNew(pi, ctx.cwd);
			if (sent) {
				ctx.ui.notify("nvim-bridge: message sent to agent", "info");
			} else {
				ctx.ui.notify("nvim-bridge: no new message (" + BRIDGE_IN + ")", "info");
			}
		},
	});

	pi.on("session_start", (_event, ctx) => {
		if (!watcher) {
			try {
				watcher = watch(BRIDGE_IN, () => {
					sendIfNew(pi, ctx.cwd);
				});
			} catch { /* file may not exist yet */ }
		}

		ctx.ui.notify("nvim-bridge: ready (/nvim-read as fallback)", "info");
	});

	pi.on("agent_end", async (_event, ctx) => {
		sendIfNew(pi, ctx.cwd);
	});

	pi.on("session_shutdown", () => {
		// watcher cleaned up on process exit
	});
}
