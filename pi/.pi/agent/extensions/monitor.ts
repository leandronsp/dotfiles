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
import { Type } from "@sinclair/typebox";
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

async function findPid(pi: ExtensionAPI, port: number): Promise<number | null> {
	try {
		const r = await pi.exec("lsof", ["-ti", `:${port}`, "-sTCP:LISTEN"], { timeout: 3_000 });
		const pid = parseInt(r.stdout.trim(), 10);
		return Number.isFinite(pid) ? pid : null;
	} catch {
		return null;
	}
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

	// ── Tool (callable by the agent) ─────────────────────────────

	pi.registerTool({
		name: "monitor",
		label: "Monitor",
		description: "Add or remove a background process from the monitor widget. Use when starting dev servers or any long-running command that should be watched.",
		promptGuidelines: [
			"After starting a background server (bash with run_in_background:true), call monitor with the process label and the port it listens on. The monitor will show live status in the widget.",
			"Use label|log:path notation to enable log tailing: monitor(label: \"backend|log:log/development.log\", port: 3000).",
		],
		parameters: Type.Object({
			label: Type.String({ description: "Short name for the process. Add |log:path for log support (e.g. backend|log:log/development.log)" }),
			port: Type.Optional(Type.Number({ description: "TCP port this process listens on" })),
			command: Type.Optional(Type.String({ description: "Shell command to spawn and monitor (runs in background). Mutually exclusive with port." })),
			logs: Type.Optional(Type.Boolean({ description: "If true, tail the last 30 lines of the monitored process log (requires label|log:path)" })),
		}),
		async execute(_id, params, _signal, _upd, ctx) {
			const { label, port, command, logs } = params;
			const labelOnly = label.split("|")[0];
			const logPath = label.split("|").find((o: string) => o.startsWith("log:"))?.slice(4) ?? null;

			if (logs) {
				const w = watched.get(labelOnly);
				const path = logPath ?? w?.log;
				if (!path) {
					return { content: [{ type: "text" as const, text: `No log configured for ${labelOnly}. Use label|log:path when registering.` }], details: {} };
				}
				try {
					const cwd = w?.cwd ?? ctx.cwd;
					const r = await pi.exec("tail", ["-30", path], { cwd, timeout: 5_000 });
					const lines = r.stdout.trim() || "(empty)";
					return { content: [{ type: "text" as const, text: `${labelOnly} logs:\n\`\`\`\n${lines}\n\`\`\`` }], details: {} };
				} catch (e) {
					return { content: [{ type: "text" as const, text: `Failed: ${e instanceof Error ? e.message : e}` }], details: {} };
				}
			}

			let pid: number | null = null;

			if (command) {
				const proc = spawn("bash", ["-lc", command], { cwd: ctx.cwd, stdio: "pipe", detached: false });
				pid = proc.pid ?? null;
			}

			if (port != null) {
				pid = await findPid(pi, port);
			}

			if (pid == null) {
				return {
					content: [{ type: "text" as const, text: port != null ? `No process found on port ${port}. Is the server running?` : "Command failed to start." }],
					details: {},
				};
			}

			watched.set(labelOnly, { label: labelOnly, cmd: command ?? `port ${port}`, cwd: ctx.cwd, pid, log: logPath, proc: null });
			renderWidget(pi, ctx);
			ensurePolling(pi, ctx);
			return {
				content: [{ type: "text" as const, text: `Monitoring ${labelOnly} (pid ${pid}${port != null ? `, port ${port}` : ""})` }],
				details: {},
			};
		},
	});
}
