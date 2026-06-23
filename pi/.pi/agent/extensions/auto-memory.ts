/**
 * auto-memory — fully automatic learning capture
 *
 * The LLM autonomously calls `remember` to record facts during a session.
 * Learnings auto-load into the system prompt on every turn.
 * Zero user action needed.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";
import { writeFile, readFile, mkdir } from "node:fs/promises";
import { join, basename } from "node:path";
import { homedir } from "node:os";

// ── Config ──────────────────────────────────────────────────────────

const VAULT = join(homedir(), "vault", "learnings");
const MAX_FACTS = 15;
const DAYS = 90;

// ── Helpers ─────────────────────────────────────────────────────────

function slug(cwd: string) {
	return basename(cwd).replace(/[^a-zA-Z0-9_-]/g, "_") || "unknown";
}

function file(cwd: string) {
	return join(VAULT, `${slug(cwd)}.md`);
}

function today() {
	return new Date().toISOString().slice(0, 10);
}

let saveLock = Promise.resolve();

async function saveLearning(cwd: string, cat: string, text: string): Promise<boolean> {
	const path = file(cwd);
	await mkdir(VAULT, { recursive: true });

	// Serialize writes with a simple promise chain (avoids withFileMutationQueue dep)
	return new Promise((resolve) => {
		saveLock = saveLock.then(async () => {
			try {
				let content = "";
				try { content = await readFile(path, "utf-8"); } catch { /* new file */ }

				if (content.includes(text)) return resolve(false);

				if (!content) {
					content = `# Learnings for ${slug(cwd)}\n\n## ${today()}\n`;
				}

				await writeFile(
					path,
					content.trimEnd() + `\n- [${cat}] ${text}\n`,
					"utf-8",
				);
				resolve(true);
			} catch {
				resolve(false);
			}
		});
	});
}

async function loadRecent(cwd: string): Promise<string[]> {
	try {
		const raw = await readFile(file(cwd), "utf-8");
		const lines = raw.split("\n");

		const cutoff = new Date();
		cutoff.setDate(cutoff.getDate() - DAYS);
		const cutoffStr = cutoff.toISOString().slice(0, 10);

		const out: string[] = [];
		let current = "";
		for (const line of lines) {
			const m = line.match(/^## (\d{4}-\d{2}-\d{2})/);
			if (m) { current = m[1]; continue; }
			const f = line.match(/^- \[(learned|decided|pattern|gotcha)\]\s+(.+)/);
			if (f && current >= cutoffStr) out.push(`- [${f[1]}] ${f[2]}`);
		}
		return out.slice(-MAX_FACTS);
	} catch {
		return [];
	}
}

// ── Extension ───────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ auto-memory", display: true }); } catch {} });
	const sessionFacts: string[] = [];
	let loaded = false;

	// ── Tool ───────────────────────────────────────────────────

	pi.registerTool({
		name: "remember",
		label: "Remember",
		description:
			"Save a one-line fact, learning, pattern, or gotcha for this project. " +
			"Use AUTONOMOUSLY whenever you discover something worth keeping. " +
			"Keep each fact to ONE LINE. Be specific and actionable. " +
			'Good: "docker-compose precisa de COMPOSE_PROJECT_NAME=mendio" ' +
			'Bad: "Aprendemos sobre Docker hoje"',
		promptGuidelines: [
			"Call remember AUTONOMOUSLY when you discover a fact, pattern, gotcha, or decision worth keeping for future sessions. One line per fact.",
		],
		parameters: Type.Object({
			category: Type.String({
				description: "Category: learned | decided | pattern | gotcha",
			}),
			fact: Type.String({
				description: "One-line fact. Be specific and actionable.",
			}),
		}),
		async execute(_id, params, _signal, _upd, ctx) {
			const ok = await saveLearning(process.cwd(), params.category, params.fact);
			if (ok) {
				sessionFacts.push(`[${params.category}] ${params.fact}`);
				const msg = `🧠 [${params.category}] ${params.fact}`;
				try { ctx.ui.notify(msg, "info"); } catch { /* no UI */ }
				return {
					content: [{ type: "text" as const, text: `Saved: ${msg}` }],
					details: {},
				};
			}
			return {
				content: [{ type: "text" as const, text: "Already recorded." }],
				details: {},
			};
		},
	});

	// ── Load on session start: visible message ──────────────────

	pi.on("session_start", async (_event, ctx) => {
		try {
			const facts = await loadRecent(ctx.cwd);
			if (facts.length > 0) {
				loaded = true;
				ctx.ui.setStatus("memory", `🧠 ${facts.length} learnings loaded for ${slug(ctx.cwd)}`);
				pi.sendMessage({
					customType: "auto-memory",
					content: `🧠 Loaded ${facts.length} project learnings for ${slug(ctx.cwd)}`,
					display: true,
				});
			}
		} catch { /* */ }
	});

	// ── Load on first "before_agent_start" each session ──────────

	pi.on("before_agent_start", async (event, ctx) => {
		const facts = await loadRecent(ctx.cwd);
		if (facts.length === 0) return;

		// Show once per session
		if (!loaded) {
			loaded = true;
			try { ctx.ui.setStatus("memory", `🧠 ${facts.length} learnings loaded for ${slug(ctx.cwd)}`); } catch { /* */ }
		}

		const block = `\n\n<project-memory>\nProject learnings from past sessions (${slug(ctx.cwd)}):\n${facts.join("\n")}\n</project-memory>`;
		return { systemPrompt: event.systemPrompt + block };
	});

	// ── Recap on shutdown and before compaction ──────────────────

	async function writeRecap(cwd: string, kind: string, note: string) {
		if (sessionFacts.length === 0) return;
		try {
			const recapDir = join(homedir(), "vault", "sessions");
			await mkdir(recapDir, { recursive: true });
			const now = new Date().toISOString().replace("T", " ").slice(0, 19);
			const lines = [`# Auto-recap (${kind}): ${slug(cwd)}`, `**Date:** ${now}`];
			if (note) lines.push(`**Note:** ${note}`);
			lines.push("", "## Facts recorded this session", ...sessionFacts.map((f) => `- ${f}`), "");
			await writeFile(join(recapDir, `auto-recap-${Date.now().toString(36)}.md`), lines.join("\n"), "utf-8");
		} catch { /* best effort */ }
	}

	// Checkpoint before context is compacted away (pi >= 0.79.10). A long session that
	// compacts several times — or crashes before shutdown — still gets its facts recapped.
	pi.on("session_before_compact", async (event, ctx) => {
		const { reason = "unknown", willRetry = false } = event as { reason?: string; willRetry?: boolean };
		if (willRetry) return; // overflow retry fires its own event — don't double-write
		await writeRecap(ctx.cwd, "compact", `reason=${reason}`);
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		await writeRecap(ctx.cwd, "shutdown", "");
	});
}
