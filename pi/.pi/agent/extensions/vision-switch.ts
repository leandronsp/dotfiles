/**
 * vision-switch — switch to a vision model only when an ACTUAL image is involved, revert after.
 *
 * The opencode-go coding defaults (mimo-v2.5-pro, deepseek-v4-pro) are text-only. Switch to a
 * vision model (minimax-m3) only for real images:
 *   1. image at turn start — attached (event.images) OR an image path in the prompt
 *      (clipboard paste writes /var/folders/.../pi-clipboard-*.png and puts the PATH in the prompt).
 *   2. a `read` of an image file mid-loop — e.g. a screenshot agent-browser saved.
 *
 * NOT for browser navigation: `agent-browser snapshot` returns a TEXT accessibility tree (buttons,
 * links, refs), which a text model reads fine. Only reading a screenshot needs vision. One-shot:
 * revert at agent_end so heavy code/debugging during a browser flow stays on the coding model.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const VISION_PROVIDER = "opencode-go";
const VISION_MODEL = "minimax-m3";
const IMAGE_PATH = /(?:^|\s)\/\S+\.(?:png|jpe?g|gif|webp|bmp|tiff)\b/i;
const IMAGE_EXT = /\.(?:png|jpe?g|gif|webp|bmp|tiff)$/i;

function promptHasImage(event: { images?: unknown[]; prompt?: string }) {
	if ((event.images?.length ?? 0) > 0) return true;
	return typeof event.prompt === "string" && IMAGE_PATH.test(event.prompt);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ vision-switch", display: true }); } catch { /* */ } });

	let revertTo: { provider: string; id: string } | null = null;

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

	// Image attached or pasted (path in the prompt) at turn start.
	pi.on("before_agent_start", async (event, ctx) => {
		if (promptHasImage(event)) await switchToVision(ctx, "🖼️  image");
	});

	// Reading an actual image file mid-loop (e.g. a screenshot). Browser navigation is text — skipped.
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "read") return;
		const path = String((event.input as { path?: unknown })?.path ?? "");
		if (IMAGE_EXT.test(path)) await switchToVision(ctx, "🖼️  screenshot");
	});

	// Revert when the turn finishes (one-shot vision).
	pi.on("agent_end", async (_event, ctx) => {
		if (ctx.model?.id !== VISION_MODEL) { revertTo = null; return; } // manual switch away — drop state
		if (!revertTo) return;
		const prev = ctx.modelRegistry.find(revertTo.provider, revertTo.id);
		const id = revertTo.id;
		revertTo = null;
		if (prev && (await pi.setModel(prev))) {
			try { ctx.ui.notify(`↩️  back to ${id}`, "info"); } catch { /* no UI */ }
		}
	});
}
