/**
 * project-skills — load the repo's .claude/skills natively, portable and launch-independent.
 *
 * pi auto-discovers project skills under <cwd>/.pi/skills, but our repos keep skills in
 * .claude/skills (shared with Claude Code — the portable home). On resources_discover this
 * contributes the nearest .claude/skills, walking up from cwd so it works from any subdir or
 * worktree. Replaces the old `pi --skill` shell wrapper (no launch-time flag needed).
 *
 * Note: a project skill with the same name as a user skill in ~/.claude/skills (e.g. both
 * named `browser`) will collide — pi resolves the project one for that repo.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync } from "node:fs";
import { join, dirname } from "node:path";

function findSkills(start: string): string | null {
	let dir = start;
	for (;;) {
		const candidate = join(dir, ".claude", "skills");
		if (existsSync(candidate)) return candidate;
		const parent = dirname(dir);
		if (parent === dir) return null;
		dir = parent;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ project-skills", display: true }); } catch {} });

	pi.on("resources_discover", async (event) => {
		const dir = findSkills(event.cwd);
		if (!dir) return;
		return { skillPaths: [dir] };
	});
}
