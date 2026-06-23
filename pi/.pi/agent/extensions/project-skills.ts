/**
 * project-skills — load .claude/skills (project + user), portable and launch-independent.
 *
 * pi auto-discovers project skills under <cwd>/.pi/skills, but our repos keep skills in
 * .claude/skills (shared with Claude Code — the portable home). On resources_discover this
 * contributes both the nearest project .claude/skills (walking up from cwd) and the user
 * ~/.claude/skills, with the project path first so it wins name collisions.
 *
 * The user skills path must NOT also appear in settings.json's `skills` array, or pi
 * loads it first and project overrides silently lose every collision.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
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
		const paths: string[] = [];

		const projectDir = findSkills(event.cwd);
		if (projectDir) paths.push(projectDir);

		const userDir = join(homedir(), ".claude", "skills");
		if (existsSync(userDir)) paths.push(userDir);

		if (paths.length === 0) return;
		return { skillPaths: paths };
	});
}
