/**
 * vision-switch — auto-use a vision model when an image is attached, revert when it isn't.
 *
 * The default model (deepseek-v4-pro) is text-only, so pi can't send it an image. This
 * watches before_agent_start: a turn carrying an image on a text-only model switches to
 * a vision model for that turn, then reverts on the next image-less turn. Automatic —
 * nothing to remember. A manual switch away from the vision model cancels the pending
 * revert (the guard `model.id === VISION_MODEL` below), so it won't fight the user.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const VISION_PROVIDER = "opencode-go";
const VISION_MODEL = "minimax-m3";

export default function (pi: ExtensionAPI) {
	let revertTo: { provider: string; id: string } | null = null;

	pi.on("before_agent_start", async (event, ctx) => {
		const model = ctx.model;
		const hasImages = (event.images?.length ?? 0) > 0;

		// Image on a text-only model → switch to the vision model for this turn.
		if (hasImages && !model?.input?.includes("image")) {
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
		if (!hasImages && revertTo && model?.id === VISION_MODEL) {
			const prev = ctx.modelRegistry.find(revertTo.provider, revertTo.id);
			const id = revertTo.id;
			revertTo = null;
			if (prev && (await pi.setModel(prev))) {
				try { ctx.ui.notify(`↩️  back to ${id}`, "info"); } catch { /* no UI */ }
			}
		}
	});
}
