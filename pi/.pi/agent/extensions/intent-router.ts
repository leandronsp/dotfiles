/**
 * intent-router — deterministic tool routing from prompt patterns.
 *
 * Skills are model-driven (the model loads them when it judges the task matches). For
 * "ALWAYS use tool X when I mention Y" you don't want to rely on that judgement — you want
 * the harness to guarantee it. So on every turn this scans the prompt for known references
 * and appends a short directive telling the model which CLI/skill to reach for. It nudges;
 * it does not run anything. Extend by adding to ROUTES.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const ROUTES: { name: string; test: RegExp; hint: string }[] = [
	{
		name: "linear",
		test: /\blinear\.app\//i,
		hint: "Linear link detected — read it with the `lineark` CLI (`lineark issues read <id>`), not the web or an MCP.",
	},
	{
		name: "github",
		test: /\bgithub\.com\//i,
		hint: "GitHub link detected — use the `gh` CLI (`gh pr view <n>`, `gh issue view <n>`, `gh api ...`) instead of fetching the web page.",
	},
	{
		name: "browser",
		test: /\b[\w.-]*localhost(:\d+)?\b|\b(navega\w*|abre a (p[aá]gina|url)|testa no browser|open the page|navigate to)\b/i,
		hint: "Local app / navigation request — use the browser skill (the `agent-browser` CLI) to open and test the page.",
	},
];

export default function (pi: ExtensionAPI) {
	pi.on("session_start", () => { try { pi.sendMessage({ customType: "boot", content: "✓ intent-router", display: true }); } catch {} });
	pi.on("before_agent_start", async (event, ctx) => {
		const prompt = typeof event.prompt === "string" ? event.prompt : "";
		if (!prompt) return;
		const hits = ROUTES.filter((r) => r.test.test(prompt));
		if (hits.length === 0) return;
		try { ctx.ui.setStatus("router", `🧭 ${hits.map((h) => h.name).join(", ")}`); } catch { /* no UI */ }
		const block = `\n\n<tool-routing>\n${hits.map((h) => `- ${h.hint}`).join("\n")}\n</tool-routing>`;
		return { systemPrompt: event.systemPrompt + block };
	});
}
