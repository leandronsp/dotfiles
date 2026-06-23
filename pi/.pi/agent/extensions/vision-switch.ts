/**
 * vision-switch — route vision work to a vision model automatically, revert when done.
 *
 * The opencode-go coding defaults (deepseek-v4-pro, mimo-v2.5-pro) are text-only. Two
 * vision triggers switch the session to a vision model (minimax-m3):
 *   1. Image at turn start — attached (event.images) OR an image path in the prompt
 *      (clipboard paste writes /var/folders/.../pi-clipboard-*.png and puts the PATH in
 *      the prompt, so event.images is empty — the common case). One-shot: revert at agent_end.
 *   2. Browser/screenshot activity — a `tool_call` running `agent-browser` (the browser
 *      skill) or a Chrome DevTools MCP tool. Sticky: stays on the vision model across the
 *      whole browsing flow (screenshots arrive mid-loop and need vision), reverts on the
 *      first turn that does no browser work.
 *
 * Revert rule: we go back to the prior model at agent_end UNLESS this turn used the browser.
 * A manual /model switch drops our state so we never fight the user.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const VISION_PROVIDER = "opencode-go";
const VISION_MODEL = "minimax-m3";
const IMAGE_PATH = /(?:^|\s)\/\S+\.(?:png|jpe?g|gif|webp|bmp|tiff)\b/i;

function turnHasImage(event: { images?: unknown[]; prompt?: string }) {
	if ((event.images?.length ?? 0) > 0) return true;
	return typeof event.prompt === "string" && IMAGE_PATH.test(event.prompt);
}

function isBrowserCall(event: { toolName?: string; input?: unknown }) {
	const name = event.toolName ?? "";
	if (name === "bash") {
		const input = event.input as { command?: string } | undefined;
		const cmd = typeof input?.command === "string" ? input.command : JSON.stringify(input ?? {});
		return /\bagent-browser\b/.test(cmd);
	}
	return /chrome.?devtools|take_screenshot|navigate_page|take_snapshot/i.test(name);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ vision-switch", display: true }); } catch {} });
	let revertTo: { provider: string; id: string } | null = null;
	let browserThisTurn = false;

	async function switchToVision(ctx: any, why: string) {
		const model = ctx.model;
		if (model?.input?.includes("image")) return; // already vision-capable — nothing to do
		const vision = ctx.modelRegistry.find(VISION_PROVIDER, VISION_MODEL);
		if (!vision) return;
		if (!revertTo && model) revertTo = { provider: model.provider, id: model.id };
		if (await pi.setModel(vision)) {
			try { ctx.ui.notify(`${why} → ${VISION_MODEL}`, "info"); } catch { /* no UI */ }
		} else {
			revertTo = null;
		}
	}

	pi.on("before_agent_start", async (event, ctx) => {
		browserThisTurn = false;
		if (turnHasImage(event)) await switchToVision(ctx, "🖼️  image");
	});

	pi.on("tool_call", async (event, ctx) => {
		if (!isBrowserCall(event)) return;
		browserThisTurn = true;
		await switchToVision(ctx, "🌐 browser");
	});

	pi.on("agent_end", async (_event, ctx) => {
		// Manual switch away from our vision model → drop state, don't fight the user.
		if (ctx.model?.id !== VISION_MODEL) { revertTo = null; return; }
		if (!revertTo || browserThisTurn) return; // nothing to revert, or browsing is ongoing
		const prev = ctx.modelRegistry.find(revertTo.provider, revertTo.id);
		const id = revertTo.id;
		revertTo = null;
		if (prev && (await pi.setModel(prev))) {
			try { ctx.ui.notify(`↩️  back to ${id}`, "info"); } catch { /* no UI */ }
		}
	});
}
