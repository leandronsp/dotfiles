/**
 * Web Tools Extension — agent-browser powered
 *
 * Three tools for models without built-in web access:
 *   web_search   — search via DuckDuckGo HTML (fallback: Google via agent-browser)
 *   web_fetch    — fetch URL content via real browser (JS, SPA, auth OK)
 *   web_snapshot — structured accessibility tree of a page
 *
 * Uses agent-browser (Chromium) — handles JS-rendered pages, cookies, redirects.
 * Much more reliable than curl+pandoc. No API keys needed.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";

const AGENT_BROWSER = "agent-browser";
const MAX_TEXT_CHARS = 30_000;

// ── agent-browser helpers ──────────────────────────────────────────────

async function ab(
	pi: ExtensionAPI,
	args: string[],
	timeout = 20_000,
): Promise<{ stdout: string; stderr: string; ok: boolean }> {
	const result = await pi.exec(AGENT_BROWSER, args, { timeout });
	return { stdout: result.stdout, stderr: result.stderr, ok: result.code === 0 };
}

async function abOpen(pi: ExtensionAPI, url: string, timeout = 15_000): Promise<boolean> {
	const r = await ab(pi, ["open", url], timeout);
	return r.ok;
}

async function abEval(pi: ExtensionAPI, js: string, timeout = 10_000): Promise<string> {
	const r = await ab(pi, ["eval", js], timeout);
	return r.ok ? r.stdout.trim() : "";
}

async function abSnapshot(pi: ExtensionAPI, timeout = 10_000): Promise<string> {
	const r = await ab(pi, ["snapshot"], timeout);
	return r.ok ? r.stdout.trim() : "";
}

async function abGetText(pi: ExtensionAPI, selector = "body", timeout = 10_000): Promise<string> {
	const r = await ab(pi, ["get", "text", selector], timeout);
	return r.ok ? r.stdout.trim() : "";
}

async function abClose(pi: ExtensionAPI) {
	await ab(pi, ["close"], 5_000);
}

// ── Search engines ─────────────────────────────────────────────────────

interface SearchResult {
	title: string;
	url: string;
	snippet: string;
}

async function searchDdgHtml(pi: ExtensionAPI, query: string): Promise<SearchResult[]> {
	const url = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
	if (!(await abOpen(pi, url, 15_000))) return [];

	const js = `
		JSON.stringify(
			Array.from(document.querySelectorAll('.result__body')).map(r => ({
				title: (r.querySelector('.result__a')?.textContent || '').trim(),
				url: r.querySelector('.result__url')?.textContent?.trim()
					|| r.querySelector('.result__a')?.href || '',
				snippet: (r.querySelector('.result__snippet')?.textContent || '').trim()
			})).filter(r => r.title && r.url)
		)
	`;

	const raw = await abEval(pi, js, 10_000);
	try {
		return JSON.parse(raw).slice(0, 10);
	} catch {
		return [];
	}
}

async function searchGoogle(pi: ExtensionAPI, query: string): Promise<SearchResult[]> {
	// Google blocks automated access. Try with agent-browser anyway.
	const url = `https://www.google.com/search?q=${encodeURIComponent(query)}&hl=en`;
	if (!(await abOpen(pi, url, 15_000))) return [];

	const js = `
		JSON.stringify(
			Array.from(document.querySelectorAll('div.g')).map(r => {
				const a = r.querySelector('a');
				const h3 = r.querySelector('h3');
				return {
					title: (h3?.textContent || '').trim(),
					url: a?.href || '',
					snippet: (r.querySelector('.VwiC3b, .lEBKkf, span.aCOpRe')?.textContent || '').trim()
				};
			}).filter(r => r.title && r.url && r.url.startsWith('http'))
		)
	`;

	const raw = await abEval(pi, js, 10_000);
	try {
		return JSON.parse(raw).slice(0, 10);
	} catch {
		return [];
	}
}

async function searchWeb(pi: ExtensionAPI, query: string): Promise<SearchResult[]> {
	// Primary: DuckDuckGo HTML (no JS needed)
	let results = await searchDdgHtml(pi, query);
	if (results.length > 0) return results;

	// Fallback: Google via real browser
	results = await searchGoogle(pi, query);
	if (results.length > 0) return results;

	// Last resort: DDG Lite via curl (fast, always works)
	const curlResult = await pi.exec("curl", [
		"-sL", "--max-time", "10",
		"-H", "User-Agent: Mozilla/5.0 (compatible; pi-agent/1.0)",
		`https://lite.duckduckgo.com/lite?q=${encodeURIComponent(query)}`,
	], { timeout: 15_000 });

	if (curlResult.stdout.trim()) {
		// Crude parse of DDG Lite HTML
		const text = curlResult.stdout
			.replace(/<[^>]+>/g, "\n")
			.replace(/&amp;/g, "&")
			.replace(/&lt;/g, "<")
			.replace(/&gt;/g, ">")
			.replace(/&quot;/g, '"')
			.replace(/\n{3,}/g, "\n\n")
			.trim();

		const lines = text.split("\n").map(l => l.trim()).filter(Boolean);
		const results: SearchResult[] = [];
		let current: Partial<SearchResult> = {};

		for (const line of lines) {
			if (line.startsWith("http://") || line.startsWith("https://")) {
				current.url = line;
			} else if (!current.title) {
				current.title = line;
			} else if (!current.snippet) {
				current.snippet = line;
				if (current.title && current.url) {
					results.push({ title: current.title, url: current.url, snippet: current.snippet || "" });
					current = {};
				}
			}
		}
		if (current.title && current.url && results.length === 0) {
			results.push({ title: current.title, url: current.url, snippet: current.snippet || "" });
		}
		return results.slice(0, 10);
	}

	return [];
}

// ── Extension ──────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "web_search",
		label: "Web Search",
		description: [
			"Search the web using DuckDuckGo (via agent-browser).",
			"Falls back to Google then DDG Lite if needed. Returns titles, URLs, and snippets.",
		].join(" "),
		promptSnippet: "Search DuckDuckGo (with Google fallback), returns titles/URLs/snippets",
		promptGuidelines: [
			"Use web_search when you need up-to-date information not in your training data.",
			"Use web_fetch on a promising result URL to read the full page content.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "Search query" }),
		}),
		async execute(_id, params, _signal, _onUpdate, _ctx) {
			try {
				const results = await searchWeb(pi, params.query);

				if (results.length === 0) {
					return {
						content: [{ type: "text", text: `No results for: ${params.query}` }],
						details: { query: params.query, results: [] },
					};
				}

				const formatted = results
					.map((r, i) => `${i + 1}. **${r.title}**\n   ${r.url}\n   ${r.snippet}`)
					.join("\n\n");

				return {
					content: [{ type: "text", text: formatted }],
					details: { query: params.query, results },
				};
			} finally {
				await abClose(pi);
			}
		},
	});

	function isPlainDataUrl(url: string): boolean {
		const lower = url.toLowerCase();
		// API endpoints, JSON, XML, raw data — no HTML
		return /\.(json|xml|yaml|yml|csv|txt|log|md)(\?|#|$)/.test(lower)
			|| /\/api\//.test(lower)
			|| /\b(webhook|graphql|rss|atom)\b/.test(lower);
	}

	async function curlFetch(pi: ExtensionAPI, url: string): Promise<string | null> {
		const result = await pi.exec("curl", [
			"-sL", "--max-time", "15",
			"-H", "User-Agent: Mozilla/5.0 (compatible; pi-agent/1.0)",
			"-H", "Accept: text/html,application/json,text/plain,*/*",
			url,
		], { timeout: 20_000 });
		return result.stdout.trim() || null;
	}

	pi.registerTool({
		name: "web_fetch",
		label: "Web Fetch",
		description: [
			"Fetch a URL and extract content.",
			"HTML pages → headless browser (Chromium via agent-browser). Handles JS, SPAs, cookies.",
			"API/JSON/XML/data endpoints → fast curl. No browser overhead.",
		].join(" "),
		promptSnippet: "Fetch URL content (browser for HTML, curl for API/data)",
		promptGuidelines: [
			"Use web_fetch after web_search to read full page content from a promising result.",
			"Prefer web_fetch over web_snapshot when you need the full article text.",
		],
		parameters: Type.Object({
			url: Type.String({ description: "URL to fetch" }),
		}),
		async execute(_id, params, _signal, _onUpdate, _ctx) {
			const url = params.url;

			// API/data endpoints: curl is faster and cleaner
			if (isPlainDataUrl(url)) {
				const text = await curlFetch(pi, url);
				if (!text) {
					return {
						content: [{ type: "text", text: `Empty response from: ${url}` }],
						details: { url },
					};
				}
				const truncated = text.length > MAX_TEXT_CHARS
					? text.slice(0, MAX_TEXT_CHARS) + `\n\n[Truncated: ${text.length - MAX_TEXT_CHARS} more chars]`
					: text;
				return {
					content: [{ type: "text", text: truncated }],
					details: { url, length: text.length, method: "curl" },
				};
			}

			// HTML pages: use real browser
			try {
				if (!(await abOpen(pi, url, 15_000))) {
					return {
						content: [{ type: "text", text: `Could not open: ${url}` }],
						details: { url },
					};
				}

				const text = await abGetText(pi, "body", 10_000);
				if (!text) {
					return {
						content: [{ type: "text", text: `No text content found at: ${url}` }],
						details: { url },
					};
				}

				const truncated = text.length > MAX_TEXT_CHARS
					? text.slice(0, MAX_TEXT_CHARS) + `\n\n[Truncated: ${text.length - MAX_TEXT_CHARS} more chars]`
					: text;

				return {
					content: [{ type: "text", text: truncated }],
					details: { url, length: text.length, method: "agent-browser" },
				};
			} finally {
				await abClose(pi);
			}
		},
	});

	pi.registerTool({
		name: "web_snapshot",
		label: "Web Snapshot",
		description: [
			"Open a URL in a headless browser and return the accessibility tree snapshot.",
			"Shows headings, buttons, links, form fields, and their states.",
			"Best for inspecting interactive pages, forms, and UI structure.",
		].join(" "),
		promptSnippet: "Get structured accessibility tree of a web page",
		promptGuidelines: [
			"Use web_snapshot to inspect a page's interactive structure (buttons, forms, links, states).",
			"Use web_fetch instead when you need the full article text content.",
		],
		parameters: Type.Object({
			url: Type.String({ description: "URL to snapshot" }),
		}),
		async execute(_id, params, _signal, _onUpdate, _ctx) {
			try {
				if (!(await abOpen(pi, params.url, 15_000))) {
					return {
						content: [{ type: "text", text: `Could not open: ${params.url}` }],
						details: { url: params.url },
					};
				}

				const tree = await abSnapshot(pi, 10_000);
				if (!tree) {
					return {
						content: [{ type: "text", text: `No content at: ${params.url}` }],
						details: { url: params.url },
					};
				}

				const truncated = tree.length > MAX_TEXT_CHARS
					? tree.slice(0, MAX_TEXT_CHARS) + `\n\n[Truncated: ${tree.length - MAX_TEXT_CHARS} more chars]`
					: tree;

				return {
					content: [{ type: "text", text: truncated }],
					details: { url: params.url, length: tree.length },
				};
			} finally {
				await abClose(pi);
			}
		},
	});
}
