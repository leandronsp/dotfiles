/**
 * vision-switch — switch to a vision model when an image is involved, revert at turn end.
 *
 * The ollama cloud coding default (glm-5.2:cloud) is text-only. Switch to a
 * vision model (minimax-m3:cloud) only for real images:
 *   1. image at turn start — attached (event.images) OR an image path in the prompt
 *      (clipboard paste writes /var/folders/.../pi-clipboard-*.png and puts the PATH in the prompt).
 *   2. a `read` of an image file mid-loop — e.g. a screenshot agent-browser saved.
 *
 * NOT for browser navigation: `agent-browser snapshot` returns a TEXT accessibility tree (buttons,
 * links, refs), which a text model reads fine. Only reading a screenshot needs vision.
 *
 * Revert strategy: revert on agent_end (turn end). A `revertedThisTurn` flag prevents the
 * tool_call handler from re-switching to vision AFTER agent_end has already reverted within the
 * same turn. The flag resets on each before_agent_start (new user message), so a new turn can
 * switch to vision again if it has an image.
 *
 * BUGFIX: pi persists the active model across sessions in the same project directory. If a previous
 * session was still on the vision model (e.g. agent_end hadn't fired yet when a new session started),
 * the new session would inherit minimax as its starting model. We force-reset to the default coding
 * model on session_start, before any agent turns run.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const VISION_PROVIDER = "ollama";
const VISION_MODEL = "minimax-m3:cloud";
const DEFAULT_PROVIDER = "ollama";
const DEFAULT_MODEL = "glm-5.2:cloud";
const IMAGE_PATH = /(?:^|\s)\/\S+\.(?:png|jpe?g|gif|webp|bmp|tiff)\b/i;
const IMAGE_EXT = /\.(?:png|jpe?g|gif|webp|bmp|tiff)$/i;

function promptHasImage(event: { images?: unknown[]; prompt?: string }) {
	if ((event.images?.length ?? 0) > 0) return true;
	return typeof event.prompt === "string" && IMAGE_PATH.test(event.prompt);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		// Force-reset to the default coding model. pi persists the active model across sessions —
		// if the previous session ended while on the vision model, this new session would inherit
		// it. Reset early, before any agent turns run.
		const current = ctx.model;
		if (current && current.provider === VISION_PROVIDER && current.id === VISION_MODEL) {
			const def = ctx.modelRegistry.find(DEFAULT_PROVIDER, DEFAULT_MODEL);
			if (def && await pi.setModel(def)) {
				try { ctx.ui.notify(`↩️  session start → ${DEFAULT_MODEL}`, "info"); } catch { /* no UI */ }
			}
		}
		try { pi.sendMessage({ customType: "boot", content: "✓ vision-switch", display: true }); } catch { /* */ }
	});

	let revertTo: { provider: string; id: string } | null = null;
	// Prevents tool_call from re-switching to vision after agent_end reverted within the same turn.
	// Reset on each before_agent_start (new user message) so a new turn can switch to vision again.
	let revertedThisTurn = false;

	async function switchToVision(ctx: any, why: string) {
		if (revertedThisTurn) return; // already reverted this turn — don't re-switch
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

	// New user message → reset the per-turn flag.
	// Image in prompt → switch to vision. No image → revert to coding model (if on vision).
	pi.on("before_agent_start", async (event, ctx) => {
		revertedThisTurn = false;
		if (promptHasImage(event)) {
			await switchToVision(ctx, "🖼️  image");
		}
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
		revertedThisTurn = true; // prevent tool_call from re-switching after this revert
		if (prev && (await pi.setModel(prev))) {
			try { ctx.ui.notify(`↩️  back to ${id}`, "info"); } catch { /* no UI */ }
		}
	});
}