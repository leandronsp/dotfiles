/**
 * rules-loader — inject global identity + .claude/rules/*.md into the system prompt.
 *
 * Pi only auto-loads CLAUDE.md / AGENTS.md. It never reads .claude/rules/*.md
 * (the bulk of project conventions) nor the global ~/.claude/CLAUDE.md identity.
 * This fills that gap, mirroring the Claude Code harness. Same pattern as auto-memory:
 * read once, print a visible load message on session_start, inject on before_agent_start.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFile, readdir } from "node:fs/promises";
import { join } from "node:path";
import { homedir } from "node:os";

async function readMdDir(dir: string): Promise<string[]> {
	try {
		const files = (await readdir(dir)).filter((f) => f.endsWith(".md")).sort();
		return Promise.all(
			files.map(async (f) => `### ${f}\n\n${await readFile(join(dir, f), "utf-8")}`),
		);
	} catch {
		return [];
	}
}

async function readFileOrEmpty(path: string): Promise<string> {
	try {
		const body = await readFile(path, "utf-8");
		return body.trim() ? `### ${path}\n\n${body}` : "";
	} catch {
		return "";
	}
}

export default function (pi: ExtensionAPI) {
	let cached: string | null = null;

	async function load(cwd: string): Promise<string> {
		if (cached !== null) return cached;
		const home = homedir();
		const parts = [
			await readFileOrEmpty(join(home, ".claude", "CLAUDE.md")),
			...(await readMdDir(join(home, ".claude", "rules"))),
			...(await readMdDir(join(cwd, ".claude", "rules"))),
		].filter(Boolean);
		cached = parts.length ? parts.join("\n\n") : "";
		return cached;
	}

	pi.on("session_start", async (_event, ctx) => {
		const body = await load(ctx.cwd);
		if (!body) return;
		const count = body.match(/^### /gm)?.length ?? 0;
		try { ctx.ui.setStatus("rules", `📐 ${count} rule files loaded`); } catch { /* no UI */ }
		pi.sendMessage({
			customType: "rules-loader",
			content: `📐 Loaded ${count} rule/identity files (~/.claude/CLAUDE.md, ~/.claude/rules, .claude/rules)`,
			display: true,
		});
	});

	pi.on("before_agent_start", async (event, ctx) => {
		const body = await load(ctx.cwd);
		if (!body) return;
		const block = `\n\n<project-rules>\nGlobal identity and project conventions (~/.claude/CLAUDE.md, ~/.claude/rules, .claude/rules):\n\n${body}\n</project-rules>`;
		return { systemPrompt: event.systemPrompt + block };
	});
}
