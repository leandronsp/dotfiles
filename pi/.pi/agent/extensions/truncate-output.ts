/**
 * truncate-output — cap oversized tool output before it hits the context window.
 *
 * A runaway grep/find/cat/log can dump tens of thousands of tokens into context, burning the
 * opencode-go budget and crowding out useful context. This trims any single text block over
 * MAX_CHARS (tool_result hook), keeping the head and telling the model to narrow the search.
 * Edit/write results are left alone (they're small and meaningful).
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const MAX_CHARS = 30_000;

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ truncate-output", display: true }); } catch {} });

	pi.on("tool_result", async (event) => {
		if (event.toolName === "edit" || event.toolName === "write") return;
		const content = event.content;
		if (!Array.isArray(content)) return;

		let changed = false;
		const out = content.map((block) => {
			if (block?.type === "text" && typeof block.text === "string" && block.text.length > MAX_CHARS) {
				changed = true;
				const dropped = block.text.length - MAX_CHARS;
				return { ...block, text: `${block.text.slice(0, MAX_CHARS)}\n\n[truncate-output: dropped ${dropped} chars — narrow the grep/find/range if you need more]` };
			}
			return block;
		});

		if (changed) return { content: out };
	});
}
