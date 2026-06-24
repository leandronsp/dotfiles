/**
 * monitor — generic background process supervisor.
 *
 * Tracks processes the agent (or skills) explicitly add. Each entry is
 * identified by a label + the command it runs. The widget shows live status
 * for all monitored processes. Configuration is in-memory only — no
 * project files, no defaults. Add a process, it shows up. Remove it, it
 * disappears.
 *
 * Commands:
 *   /monitor add <label> <cmd...>    Run cmd in background, watch it
 *   /monitor remove <label>          Kill watched process, drop it
 *   /monitor list                    Show all monitored processes
 *   /monitor logs <label>            Tail last 30 lines (if log: set)
 *
 * Optional: a label may include `log:path` to make /monitor logs work:
 *   /monitor add "backend|log:log/development.log" ./script/rails s
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { spawn, ChildProcess } from "node:child_process";

interface Watched {
	label: string;
	cmd: string;
	cwd: string;
	pid: number | null;
	log: string | null;
	proc: ChildProcess | null;
}

const POLL_SEC = 5;
const watched = new Map<string, Watched>();

async function checkAlive(pid: number | null): Promise<boolean> {
	if (pid == null) return false;
	try { process.kill(pid, 0); return true; } catch { return false; }
}

function renderWidget(pi: ExtensionAPI, ctx: any) {
	if (watched.size === 0) {
		try { ctx.ui.setWidget("monitor", ["monitor: (empty — /monitor add <label> <cmd>)"]); } catch { /* */ }
		return;
	}
	const parts: string[] = [];
	for (const w of watched.values()) {
		const ok = w.pid != null;
		parts.push(`${w.label} ${ok ? "✓" : "✗"}`);
	}
	try { ctx.ui.setWidget("monitor", [parts.join("  ·  ")]); } catch { /* */ }
}

async function tickAll(pi: ExtensionAPI, ctx: any) {
	for (const w of watched.values()) {
		const alive = await checkAlive(w.pid);
		if (w.pid != null && !alive) {
			try { ctx.ui.notify(`⚠ ${w.label} died (pid ${w.pid})`, "warning"); } catch { /* */ }
			w.pid = null;
		}
	}
	renderWidget(pi, ctx);
}

let pollHandle: ReturnType<typeof setInterval> | null = null;

function ensurePolling(pi: ExtensionAPI, ctx: any) {
	if (pollHandle || watched.size === 0) return;
	pollHandle = setInterval(() => tickAll(pi, ctx), POLL_SEC * 1000);
}

function stopPollingIfEmpty() {
	if (watched.size > 0) return;
	if (pollHandle) { clearInterval(pollHandle); pollHandle = null; }
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ monitor", display: true }); } catch {} });

	pi.on("session_shutdown", () => {
		for (const w of watched.values()) { try { w.proc?.kill("SIGTERM"); } catch { /* */ } }
		watched.clear();
		if (pollHandle) { clearInterval(pollHandle); pollHandle = null; }
	});

	pi.registerCommand("monitor", {
		description: "Generic process monitor: add, remove, list, logs",
		handler: async (args, ctx) => {
			const parts = args?.split(/\s+/)?.filter(Boolean) ?? [];
			const sub = parts[0];

			if (sub === "add" && parts.length >= 3) {
				const labelSpec = parts[1];
				const cmdParts = parts.slice(2);
				const [label, ...opts] = labelSpec.split("|");
				const log = opts.find((o) => o.startsWith("log:"))?.slice(4) ?? null;
				const cmdStr = cmdParts.join(" ");
				const proc = spawn("bash", ["-lc", cmdStr], { cwd: ctx.cwd, stdio: "pipe", detached: false });
				watched.set(label, { label, cmd: cmdStr, cwd: ctx.cwd, pid: proc.pid ?? null, log, proc });
				try { ctx.ui.notify(`monitor: watching ${label} (pid ${proc.pid})`, "info"); } catch { /* */ }
				renderWidget(pi, ctx);
				ensurePolling(pi, ctx);
				return;
			}

			if (sub === "remove" && parts[1]) {
				const w = watched.get(parts[1]);
				if (!w) { ctx.ui.notify(`monitor: no process labeled "${parts[1]}"`, "warning"); return; }
				try { w.proc?.kill("SIGTERM"); } catch { /* */ }
				watched.delete(parts[1]);
				try { ctx.ui.notify(`monitor: removed ${parts[1]}`, "info"); } catch { /* */ }
				renderWidget(pi, ctx);
				stopPollingIfEmpty();
				return;
			}

			if (sub === "list" || !sub) {
				if (watched.size === 0) { ctx.ui.notify("monitor: (empty)", "info"); return; }
				const lines: string[] = [];
				for (const w of watched.values()) {
					const alive = await checkAlive(w.pid);
					lines.push(`${w.label} ${alive ? "✓" : "✗"}  pid=${w.pid}  ${w.cmd}`);
				}
				pi.sendMessage({ customType: "monitor-list", content: lines.join("\n"), display: true });
				return;
			}

			if (sub === "logs" && parts[1]) {
				const w = watched.get(parts[1]);
				if (!w?.log) { ctx.ui.notify(`No log: spec for ${parts[1]}`, "warning"); return; }
				try {
					const r = await pi.exec("tail", ["-30", w.log], { cwd: w.cwd, timeout: 5_000 });
					const lines = r.stdout.trim() || "(empty)";
					pi.sendMessage({ customType: "monitor-logs", content: `${w.label} logs\n\`\`\`\n${lines}\n\`\`\``, display: true });
				} catch (e) {
					ctx.ui.notify(`Failed: ${e instanceof Error ? e.message : e}`, "error");
				}
				return;
			}

			ctx.ui.notify("Usage: /monitor add <label[|log:path]> <cmd...> | remove <label> | list | logs <label>", "info");
		},
	});

	// Empty widget on session start
	pi.on("session_start", (_event, ctx) => renderWidget(pi, ctx));
}
