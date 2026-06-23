import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { writeFileSync, unlinkSync } from "fs";

const TMUX_PANE = process.env.TMUX_PANE;
const STATUS_FILE = TMUX_PANE ? `/tmp/pi-tmux-status-${TMUX_PANE.replace("%", "")}` : null;

function writeStatus(_pi: ExtensionAPI, ctx: any) {
	if (!STATUS_FILE) return;

	const modelId = ctx.model?.id || "no-model";
	const shortModel = modelId.replace("claude-", "").replace(/-\d{8}$/, "");

	const usage = ctx.getContextUsage();
	const ctxPct = usage?.percent != null ? `${Math.round(usage.percent)}%` : "—";

	writeFileSync(STATUS_FILE, `${shortModel} · ctx:${ctxPct}`, "utf-8");
}

function cleanStatus() {
	if (!STATUS_FILE) return;
	try { unlinkSync(STATUS_FILE); } catch {}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ tmux-status", display: true }); } catch {} });
	pi.on("session_start", (_event, ctx) => {
		// Empty footer — all info goes to tmux
		ctx.ui.setFooter((_tui, _theme, _footerData) => ({
			invalidate() {},
			render(_width: number): string[] { return []; },
		}));

		// Write initial status
		writeStatus(pi, ctx);
	});

	// Update after each turn (new tokens/cost)
	pi.on("turn_end", (_event, ctx) => {
		writeStatus(pi, ctx);
	});

	// Update on model change
	pi.on("model_select", (_event, ctx) => {
		writeStatus(pi, ctx);
	});

	// Cleanup on exit
	pi.on("session_shutdown", () => {
		cleanStatus();
	});
}
