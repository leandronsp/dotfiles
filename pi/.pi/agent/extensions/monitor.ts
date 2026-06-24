/**
 * monitor — background process supervision for dev servers.
 *
 * Checks lsof on configured ports every few seconds, shows a persistent
 * status widget, and notifies on crash. Configure targets per project
 * via .pi/monitor.json or fall back to defaults.
 *
 * Commands:
 *   /monitor start       Start watching
 *   /monitor stop        Stop the watcher
 *   /monitor status      Show current status
 *   /monitor logs <name> Tail the log file for a target (if configured)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

interface Target {
	name: string;
	port: number;
	log?: string;
}

const DEFAULT_TARGETS: Target[] = [
	{ name: "backend", port: 3000, log: "log/development.log" },
	{ name: "marionette", port: 3001 },
	{ name: "react", port: 3002 },
];

const POLL_SEC = 5;

function loadTargets(cwd: string): Target[] {
	try {
		const cfg = join(cwd, ".pi", "monitor.json");
		if (existsSync(cfg)) return JSON.parse(readFileSync(cfg, "utf-8"));
	} catch { /* fall through */ }
	return DEFAULT_TARGETS;
}

async function checkPort(pi: ExtensionAPI, port: number): Promise<boolean> {
	try {
		const r = await pi.exec("lsof", ["-i", `:${port}`, "-sTCP:LISTEN", "-n", "-P"], { timeout: 3_000 });
		return r.code === 0 && r.stdout.trim().length > 0;
	} catch {
		return false;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ monitor", display: true }); } catch {} });

	let watcher: ReturnType<typeof setInterval> | null = null;
	let statuses: Record<string, boolean> = {};
	let targets: Target[] = [];

	function render(ctx: any) {
		const parts = targets.map((t) => {
			const up = statuses[t.name];
			const icon = up ? "✓" : "✗";
			const color = up ? "success" : "error";
			return ctx.ui.theme.fg(color, `${t.name} ${icon}`);
		});
		try { ctx.ui.setWidget("monitor", [parts.join("  ·  ")]); } catch { /* */ }
	}

	async function tick(ctx: any) {
		for (const t of targets) {
			const wasUp = statuses[t.name];
			const up = await checkPort(pi, t.port);
			statuses[t.name] = up;
			if (wasUp && !up) {
				try { ctx.ui.notify(`⚠ ${t.name} :${t.port} went down`, "warning"); } catch { /* */ }
			}
		}
		render(ctx);
	}

	function start(ctx: any) {
		if (watcher) return;
		targets = loadTargets(ctx.cwd);
		statuses = {};
		for (const t of targets) statuses[t.name] = false;
		tick(ctx);
		watcher = setInterval(() => tick(ctx), POLL_SEC * 1000);
		try { ctx.ui.notify(`monitor: watching ${targets.length} targets every ${POLL_SEC}s`, "info"); } catch { /* */ }
	}

	function stop(ctx: any) {
		if (watcher) { clearInterval(watcher); watcher = null; }
		try { ctx.ui.setWidget("monitor", undefined); } catch { /* */ }
		try { ctx.ui.notify("monitor: stopped", "info"); } catch { /* */ }
	}

	pi.on("session_shutdown", () => { if (watcher) clearInterval(watcher); });

	pi.registerCommand("monitor", {
		description: "Process supervisor: start, stop, status, logs",
		handler: async (args, ctx) => {
			const sub = args?.split(/\s+/).filter(Boolean) ?? [];

			if (sub[0] === "start") return start(ctx);
			if (sub[0] === "stop") return stop(ctx);

			if (sub[0] === "status") {
				if (!watcher) targets = loadTargets(ctx.cwd);
				for (const t of targets) {
					const up = await checkPort(pi, t.port);
					statuses[t.name] = up;
				}
				render(ctx);
				ctx.ui.notify(Object.entries(statuses).map(([k, v]) => `${k}: ${v ? "✓ up" : "✗ down"}`).join("  "), "info");
				return;
			}

			if (sub[0] === "logs" && sub[1]) {
				const t = targets.find((x) => x.name === sub[1]);
				if (!t?.log) { ctx.ui.notify(`No log configured for ${sub[1]}`, "warning"); return; }
				try {
					const r = await pi.exec("tail", ["-30", t.log], { cwd: ctx.cwd, timeout: 5_000 });
					const lines = r.stdout.trim() || "(empty)";
					pi.sendMessage({ customType: "monitor-logs", content: `## ${t.name} logs\n\`\`\`\n${lines}\n\`\`\``, display: true });
				} catch (e) {
					ctx.ui.notify(`Failed: ${e instanceof Error ? e.message : e}`, "error");
				}
				return;
			}

			ctx.ui.notify("Usage: /monitor start|stop|status|logs <name>", "info");
		},
	});

	// Auto-start on session start if .pi/monitor.json exists
	pi.on("session_start", (_event, ctx) => {
		if (existsSync(join(ctx.cwd, ".pi", "monitor.json"))) start(ctx);
	});
}
