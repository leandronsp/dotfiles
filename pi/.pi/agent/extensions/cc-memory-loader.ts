/**
 * cc-memory-loader — read Claude Code's auto-memory into pi's system prompt.
 *
 * Claude Code stores per-project memory at
 *   ~/.claude/projects/<encoded-cwd>/memory/MEMORY.md
 * where <encoded-cwd> is the absolute path with every "/" and "." replaced by "-".
 *
 * This makes pi ALSO read from Claude Code's memory, so both agents share the same
 * curated knowledge. MEMORY.md is the index; topic files live next to it and the model
 * can Read them on demand (the absolute dir is injected for that).
 *
 * Worktree-aware: Claude Code keys memory to the MAIN repo, not the worktree, so when
 * pi runs inside /repo/.worktrees/<name> we also try the stripped main-repo path.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { homedir } from "node:os";

function encode(path: string): string {
	return path.replace(/[/.]/g, "-");
}

function candidates(cwd: string): string[] {
	const out = [cwd];
	const mainRepo = cwd.replace(/\/\.worktrees\/[^/]+.*$/, "");
	if (mainRepo !== cwd) out.push(mainRepo);
	return out;
}

async function loadMemory(cwd: string): Promise<{ dir: string; index: string } | null> {
	const base = join(homedir(), ".claude", "projects");
	for (const c of candidates(cwd)) {
		const dir = join(base, encode(c), "memory");
		try {
			const index = await readFile(join(dir, "MEMORY.md"), "utf-8");
			if (index.trim()) return { dir, index };
		} catch {
			/* try next candidate */
		}
	}
	return null;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ cc-memory-loader", display: true }); } catch {} });
	let cached: string | null = null;

	pi.on("session_start", async (_event, ctx) => {
		const mem = await loadMemory(ctx.cwd);
		if (!mem) return;
		try { ctx.ui.setStatus("cc-memory", "🧠 Claude Code memory loaded"); } catch { /* no UI */ }
		pi.sendMessage({
			customType: "cc-memory",
			content: `🧠 Loaded Claude Code memory (${mem.dir})`,
			display: true,
		});
	});

	pi.on("before_agent_start", async (event, ctx) => {
		if (cached === null) {
			const mem = await loadMemory(ctx.cwd);
			cached = mem
				? `\n\n<claude-memory>\nCurated memory from Claude Code (index below; topic files live in ${mem.dir} — Read them when relevant):\n\n${mem.index}\n</claude-memory>`
				: "";
		}
		if (!cached) return;
		return { systemPrompt: event.systemPrompt + cached };
	});
}
