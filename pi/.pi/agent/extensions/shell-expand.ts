/**
 * shell-expand — expand `!{cmd}` in your prompt into the command's real output before the LLM
 * sees it. Deterministic (input transform). Lets you inline live context without copy-paste:
 *
 *   "review this diff: !{git diff --staged}"
 *   "why does !{ruby -v} differ from CI?"
 *
 * Runs your own typed input, so it's the same trust level as typing `!cmd` yourself.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const CMD = /!\{([^}]+)\}/g;

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ shell-expand", display: true }); } catch {} });

	pi.on("input", async (event, ctx) => {
		const text = event.text;
		if (typeof text !== "string") return;
		const matches = [...text.matchAll(CMD)];
		if (matches.length === 0) return;

		let result = text;
		for (const m of matches) {
			const cmd = m[1].trim();
			let out: string;
			try {
				const r = await pi.exec("bash", ["-lc", cmd], { cwd: ctx.cwd, timeout: 30_000 });
				out = (r.stdout || r.stderr || "").trimEnd() || "(no output)";
			} catch (e) {
				out = `[shell-expand error: ${e instanceof Error ? e.message : String(e)}]`;
			}
			result = result.replace(m[0], `\n\`\`\`\n$ ${cmd}\n${out}\n\`\`\`\n`);
		}

		return { action: "transform", text: result };
	});
}
