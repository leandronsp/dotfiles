/**
 * vision-switch — auto-use a vision model when an image comes in, revert when it doesn't.
 *
 * pi only sends an image to a model that accepts image input; the opencode-go coding
 * defaults (deepseek-v4-pro, mimo-v2.5-pro) are text-only. An image reaches a turn two ways:
 *   1. attached as an image block       → event.images is populated
 *   2. clipboard paste / explicit path  → pi writes the image to /var/folders/.../pi-clipboard-*.png
 *      and puts the PATH in the prompt TEXT (event.images stays empty) — this is the common case
 * Either way, on a text-only model we switch to a vision model for the turn, then revert on
 * the next image-less turn. Automatic — nothing to remember, no OCR fallback rabbit-hole.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const VISION_PROVIDER = "opencode-go";
const VISION_MODEL = "minimax-m3";
const IMAGE_PATH = /(?:^|\s)\/\S+\.(?:png|jpe?g|gif|webp|bmp|tiff)\b/i;

function turnHasImage(event: { images?: unknown[]; prompt?: string }) {
	if ((event.images?.length ?? 0) > 0) return true;
	return typeof event.prompt === "string" && IMAGE_PATH.test(event.prompt);
}

export default function (pi: ExtensionAPI) {
	let revertTo: { provider: string; id: string } | null = null;

	pi.on("before_agent_start", async (event, ctx) => {
		const model = ctx.model;
		const hasImage = turnHasImage(event);

		// Image on a text-only model → switch to the vision model for this turn.
		if (hasImage && !model?.input?.includes("image")) {
			const vision = ctx.modelRegistry.find(VISION_PROVIDER, VISION_MODEL);
			if (!vision) return;
			revertTo = model ? { provider: model.provider, id: model.id } : null;
			if (await pi.setModel(vision)) {
				try { ctx.ui.notify(`🖼️  image → ${VISION_MODEL}`, "info"); } catch { /* no UI */ }
			} else {
				revertTo = null;
			}
			return;
		}

		// No image and we're still on the vision model we switched to → revert.
		if (!hasImage && revertTo && model?.id === VISION_MODEL) {
			const prev = ctx.modelRegistry.find(revertTo.provider, revertTo.id);
			const id = revertTo.id;
			revertTo = null;
			if (prev && (await pi.setModel(prev))) {
				try { ctx.ui.notify(`↩️  back to ${id}`, "info"); } catch { /* no UI */ }
			}
		}
	});
}
