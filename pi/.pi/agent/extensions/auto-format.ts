/**
 * auto-format — run the right formatter on every file the agent edits/writes.
 *
 * Deterministic (tool_result hook), so it doesn't depend on the model remembering to format.
 * Project-agnostic: Ruby → rubocop (prefers a ./bin/rubocop wrapper), JS/TS/CSS/JSON/MD → prettier,
 * Go → gofmt, Rust → rustfmt. Each project's own formatter config is found from the edited file's path.
 *
 * clippy is intentionally NOT here: it's a crate-level linter (compiles the whole crate, slow),
 * wrong to run on every edit. Use the `/clippy` command below for an on-demand lint-fix.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync } from "node:fs";
import { join, extname } from "node:path";

function formatterFor(file: string, cwd: string): { cmd: string; args: string[] } | null {
	switch (extname(file).toLowerCase()) {
		case ".rb": {
			const wrapper = join(cwd, "bin", "rubocop");
			return existsSync(wrapper)
				? { cmd: wrapper, args: ["-a", file] }
				: { cmd: "rubocop", args: ["-a", file] };
		}
		case ".go":
			return { cmd: "gofmt", args: ["-w", file] };
		case ".rs":
			return { cmd: "rustfmt", args: [file] };
		case ".js": case ".jsx": case ".ts": case ".tsx":
		case ".css": case ".scss": case ".less":
		case ".json": case ".md": case ".yaml": case ".yml": case ".html":
			return { cmd: "npx", args: ["--no-install", "prettier", "--write", file] };
		default:
			return null;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ auto-format", display: true }); } catch {} });

	pi.on("tool_result", async (event, ctx) => {
		if (event.isError) return;
		if (event.toolName !== "edit" && event.toolName !== "write") return;
		const path = event.input?.path;
		if (typeof path !== "string") return;
		const fmt = formatterFor(path, ctx.cwd);
		if (!fmt) return;
		try {
			const r = await pi.exec(fmt.cmd, fmt.args, { cwd: ctx.cwd, timeout: 30_000 });
			if (r.code === 0) {
				try { ctx.ui.setStatus("format", `🧹 ${fmt.cmd.split("/").pop()} ${path.split("/").pop()}`); } catch { /* */ }
			}
		} catch { /* formatter not installed — skip silently */ }
	});

	pi.registerCommand("clippy", {
		description: "Run `cargo clippy --fix` on the current Rust crate (crate-level, on demand)",
		handler: async (_args, ctx) => {
			ctx.ui.notify("clippy: running cargo clippy --fix…", "info");
			try {
				const r = await pi.exec("cargo", ["clippy", "--fix", "--allow-dirty", "--allow-staged"], { cwd: ctx.cwd, timeout: 300_000 });
				ctx.ui.notify(r.code === 0 ? "clippy: done" : `clippy: exit ${r.code}`, r.code === 0 ? "info" : "warning");
			} catch (e) {
				ctx.ui.notify(`clippy failed: ${e instanceof Error ? e.message : String(e)}`, "error");
			}
		},
	});
}
