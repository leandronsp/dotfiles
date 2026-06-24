/**
 * guardrails — deterministic tool-call gating (tool_call hook). Four lines of defense:
 *
 *   1. hard-block obviously destructive bash (rm -rf, force-push, mkfs, dd, fork bomb…)
 *   2. hard-block WRITES to protected paths (.env, .git/, secrets/, keys)
 *   3. block READING secrets (.env, credentials, keys) — so an injected web page has nothing to exfiltrate
 *   4. confirm network egress / pipe-to-shell (curl|sh, uploads, nc) — FAIL-CLOSED: no confirm = blocked
 *
 * 3 and 4 break the prompt-injection → exfiltration / RCE chain that untrusted web content can trigger.
 * Speed bumps, not a sandbox — a determined model can phrase around them; run blocked commands yourself.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const DANGER_BASH: RegExp[] = [
	/\brm\s+-[a-z]*r[a-z]*f/i,
	/\brm\s+-[a-z]*f[a-z]*r/i,
	/\brm\s+(-\w+\s+)*-r\s+(-\w+\s+)*-f\b/i,
	/\bgit\s+push\b[^|;&]*--force(?!-with-lease)/i,
	/\bgit\s+reset\s+--hard\b/i,
	/\b(mkfs\b|dd\s+if=)/i,
	/:\s*\(\)\s*\{.*\}\s*;\s*:/,
	/>\s*\/dev\/sd[a-z]/i,
];

// write-protected paths (don't let the agent modify these)
const PROTECTED_PATH = /(^|\/)(\.env(\.\w+)?$|\.git\/|secrets?\/|credentials|.*\.pem$|.*id_rsa)/i;

// secret paths (don't let an injected page read these to exfiltrate). .env.example/sample are allowed.
const SECRET_PATH = /(^|\/)(\.env(?!\.(?:example|sample|template|dist))(\.\w+)?$|credentials\b|.*\.pem$|id_rsa\b|\.aws\/|\.ssh\/|secrets?\/)/i;

// reading secrets via bash (cat/grep/etc. on .env, keys, credentials)
const SECRET_READ_CMD = /\b(cat|less|more|head|tail|bat|xxd|od|strings|grep|rg|awk|sed)\b[^|;&\n]*(\.env(?!\.(?:example|sample|template|dist))\b|\bid_rsa\b|\.pem\b|\bcredentials\b|\.aws\/|\.ssh\/|secrets?\/)/i;

// network egress / pipe-to-shell (the exfiltration / remote-code chain)
const EGRESS: RegExp[] = [
	/\|\s*(sh|bash|zsh|fish|python3?|node|ruby|perl)\b/i,                                                     // pipe to interpreter
	/\b(curl|wget)\b[^|;&\n]*\|\s*\S/i,                                                                        // curl … | something
	/\b(curl|wget)\b[^|;&\n]*(\s-d\b|--data|\s-F\b|--form|\s-T\b|--upload-file|-X\s*POST|--request\s+POST)/i,  // upload / POST
	/\bnc\b\s+\S+\s+\d+/i,                                                                                     // netcat
];

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ guardrails", display: true }); } catch { /* */ } });

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName === "bash") {
			const cmd = String((event.input as { command?: unknown })?.command ?? "");

			const danger = DANGER_BASH.find((re) => re.test(cmd));
			if (danger) return { block: true, reason: `guardrails: blocked a dangerous command (matched ${danger}). Run it yourself if you really intend to.` };

			if (SECRET_READ_CMD.test(cmd)) return { block: true, reason: "guardrails: refusing to read a secret/credential file (.env, keys, credentials). Read it yourself if intended." };

			if (EGRESS.some((re) => re.test(cmd))) {
				let ok = false;
				try { ok = await ctx.ui.confirm("⚠️  Network egress / pipe-to-shell", `Allow this command?\n\n${cmd}`); } catch { ok = false; }
				if (!ok) return { block: true, reason: "guardrails: egress / pipe-to-shell not confirmed — blocked (fail-closed). Run it yourself if intended." };
			}
			return;
		}

		if (event.toolName === "read") {
			const path = String((event.input as { path?: unknown })?.path ?? "");
			if (SECRET_PATH.test(path)) return { block: true, reason: `guardrails: refusing to read secret/credential file "${path}".` };
			return;
		}

		if (event.toolName === "edit" || event.toolName === "write") {
			const path = String((event.input as { path?: unknown })?.path ?? "");
			if (PROTECTED_PATH.test(path)) return { block: true, reason: `guardrails: refusing to modify protected path "${path}".` };
		}
	});
}
