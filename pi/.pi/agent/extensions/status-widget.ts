/**
 * status-widget — persistent panel above the editor with live session state.
 *
 * Shows the current model, thinking level, context usage, and a vision indicator when the
 * active model accepts images (so you can see at a glance when vision-switch has routed you
 * to minimax-m3). Unlike notifications, a widget stays put. Updates on session start, model
 * switch, and each turn end.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ status-widget", display: true }); } catch {} });

	function render(ctx: any) {
		try {
			const id = ctx.model?.id ?? "no-model";
			const vision = ctx.model?.input?.includes("image") ? "  🖼️ vision" : "";
			let think = "";
			try { const lvl = pi.getThinkingLevel?.(); if (lvl) think = `  think:${lvl}`; } catch { /* */ }
			let pct = "";
			try { const u = ctx.getContextUsage?.(); if (u?.percent != null) pct = `  ctx:${Math.round(u.percent)}%`; } catch { /* */ }
			ctx.ui.setWidget("status", [`⚙ ${id}${think}${pct}${vision}`]);
		} catch { /* no UI */ }
	}

	pi.on("session_start", (_event, ctx) => render(ctx));
	pi.on("model_select", (_event, ctx) => render(ctx));
	pi.on("turn_end", (_event, ctx) => render(ctx));
}
