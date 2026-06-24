/**
 * truncate-output — per-tool output caps before the context window sees them.
 *
 * A runaway grep/find/cat/log can dump tens of thousands of tokens into context, burning the
 * model budget and crowding out useful context. This trims each text block to a per-tool limit
 * (tool_result hook), keeping the head + line count and telling the model to narrow the search.
 * Edit/write results are left alone (they're small and meaningful).
 *
 * Per-tool limits (chars):
 *   web_search — 2,000  (snippets are short)
 *   web_fetch  — 8,000  (enough for article intro)
 *   web_snapshot — 5,000 (accessibility trees can be huge)
 *   bash       — 5,000  (command output)
 *   read       — 20,000 (file content, generous for code)
 *   default    — 20,000 (everything else)
 *
 * Also strips ANSI escape codes from bash output (noise). Line count is always reported so
 * the model knows how much was dropped and can re-run with narrower scope.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const LIMITS: Record<string, number> = {
	web_search: 2_000,
	web_fetch: 8_000,
	web_snapshot: 5_000,
	bash: 5_000,
	read: 20_000,
};

const DEFAULT_LIMIT = 20_000;
const ANSI = /\x1b\[[0-9;]*[a-zA-Z]/g;

function stripAnsi(text: string): string {
	return text.replace(ANSI, "");
}

function lineInfo(text: string): { lines: number; chars: number } {
	return { lines: text.split("\n").length, chars: text.length };
}

function truncate(text: string, limit: number): { output: string; dropped: number } {
	if (text.length <= limit) return { output: text, dropped: 0 };

	const info = lineInfo(text);
	const head = text.slice(0, limit);
	const headLines = head.split("\n").length;
	const droppedLines = info.lines - headLines;

	const msg = [
		`\n\n[truncate-output: dropped ${droppedLines} lines / ${info.chars - limit} chars`,
		`showing first ${headLines} of ${info.lines} lines at ${limit.toLocaleString()} char limit —`,
		"narrow the grep/find/range if you need more]",
	].join(" ");

	return { output: head + msg, dropped: droppedLines };
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ truncate-output", display: true }); } catch {} });

	pi.on("tool_result", async (event) => {
		if (event.toolName === "edit" || event.toolName === "write") return;
		const content = event.content;
		if (!Array.isArray(content)) return;

		const limit = LIMITS[event.toolName] ?? DEFAULT_LIMIT;

		let changed = false;
		const out = content.map((block) => {
			if (block?.type !== "text" || typeof block.text !== "string") return block;

			let text = block.text;
			if (event.toolName === "bash") text = stripAnsi(text);

			const { output, dropped } = truncate(text, limit);
			if (dropped === 0) return block;

			changed = true;
			return { ...block, text: output };
		});

		if (changed) return { content: out };
	});
}
