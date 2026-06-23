/**
 * guardrails — block dangerous bash and writes to protected paths before they run.
 *
 * Deterministic speed bumps (tool_call block), not a sandbox: a determined model can phrase
 * around them. The point is to stop the obvious foot-guns (rm -rf, force-push, editing .env)
 * without a human in the loop. Run a blocked command yourself if you really mean it.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const DANGER_BASH: RegExp[] = [
	/\brm\s+-[a-z]*r[a-z]*f/i,                 // rm -rf / -rfv
	/\brm\s+-[a-z]*f[a-z]*r/i,                 // rm -fr
	/\brm\s+(-\w+\s+)*-r\s+(-\w+\s+)*-f\b/i,   // rm -r -f (separate flags)
	/\bgit\s+push\b[^|;&]*--force(?!-with-lease)/i, // force-push (allow --force-with-lease)
	/\bgit\s+reset\s+--hard\b/i,
	/\b(mkfs\b|dd\s+if=)/i,
	/:\s*\(\)\s*\{.*\}\s*;\s*:/,               // fork bomb
	/>\s*\/dev\/sd[a-z]/i,
];

const PROTECTED_PATH = /(^|\/)(\.env(\.\w+)?$|\.git\/|secrets?\/|credentials|.*\.pem$|.*id_rsa)/i;

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ guardrails", display: true }); } catch {} });

	pi.on("tool_call", async (event) => {
		if (event.toolName === "bash") {
			const cmd = String((event.input as { command?: unknown })?.command ?? "");
			const hit = DANGER_BASH.find((re) => re.test(cmd));
			if (hit) return { block: true, reason: `guardrails: blocked a dangerous command (matched ${hit}). Run it yourself if you really intend to.` };
		}
		if (event.toolName === "edit" || event.toolName === "write") {
			const path = String((event.input as { path?: unknown })?.path ?? "");
			if (PROTECTED_PATH.test(path)) return { block: true, reason: `guardrails: refusing to modify protected path "${path}". Edit it by hand if needed.` };
		}
	});
}
