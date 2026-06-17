---
name: explainer
description: Create a standalone, self-contained interactive HTML explainer in an editorial style (deep navy canvas, one accent, hairlines, mono microtype) for a technical change, architecture decision, incident, data flow, or product behavior. Ships with Present mode (a keyboard-driven slide deck). Works in any project, any stack. Use when the user says "explainer", "create an explainer", "explain this visually", "make a shareable page", "interactive explainer", "write this up as a page", or "turn this into an explainer".
---

# Explainer

Create a standalone interactive HTML explainer for a topic the user gives (a technical change, architecture decision, incident, data flow, or product behavior). The output is a single `.html` file with inline CSS/JS and no external dependencies — shareable as one file, works offline.

This skill is stack-agnostic. The design language and component kit have nothing to do with any particular codebase.

## The reference kit travels with this skill

Read these before drafting. They hold the verbatim rules and copy-paste blocks; this file is just the workflow.

- **`references/engineering-foundation-explainer.html`** — the canonical worked example. It demonstrates the design language and every device. **Read it before building.** When a rule is unclear, copy what that file does; do not invent.
- **`design-language.md`** — the banned→replacement table, the device set, tokens, typography, motion. Read this first; it is what separates refined explainers from generated-looking ones.
- **`components.md`** — copy-paste CSS/HTML for every device (ledgers, inspect panels, flags, dot plots, loop circuits, gate flows, butterfly maps, annotated geometry), screenshots, code highlighting, responsive rules, and the interactive-demo machinery (animated diagrams, cursor timelines, conflict-resolution demos).
- **`present-mode.md`** — the built-in slide deck every explainer ships with: CSS, the JS kit, and how to compose the slide manifest.

The Present-mode and live-demo kits are complete and self-contained. (The original author referenced a second worked example for those; it is not bundled — the inline kits replace it.)

## Tone and voice

Explainers are educational documents, not marketing pages. Write in plain, direct English that a new team member or external reviewer can follow without prior context.

- **No hype.** Avoid words like "revolutionary", "seamless", "effortless", "powerful", "unlock", "leverage", "transform", "unprecedented", "cutting-edge", "next-generation". If a sentence sounds like it could appear on a landing page, rewrite it.
- **No editorial theatrics.** Avoid rhetorical questions, dramatic paragraph openers ("Imagine a world where..."), and fake urgency ("the stakes could not be higher"). Start with the fact.
- **Concrete before abstract.** State what the system does, then why it matters. Never the reverse.
- **Short sentences.** Break complex thoughts into two sentences. One idea per paragraph.
- **Name things by what they do.** Use "the sync engine queues pending changes" not "our resilient synchronization layer orchestrates outbound mutations". Prefer function names and file paths over invented proper nouns.
- **Educational, not promotional.** The reader should learn something they can use. Every section should leave them better informed than they started.

## First steps

Before writing anything, scan the project for source material, then use **AskUserQuestion** to ask two focused questions in one call:

1. **Source material.** Check the obvious places first — `docs/`, `README*`, `ARCHITECTURE*`, ADRs/design docs, `openspec/`, or the actual source files the topic touches. Then ask: "I found `<X>` / I didn't find docs on this — is it documented somewhere I should read, or would you rather describe it directly?"
2. **Screenshots.** "Do you have any screenshots or UI recordings to include? (Attach them, or say no.)"

Keep the questionnaire to those two. Do not ask about audience, tone, or outline — infer those from the topic and produce a first draft. The user steers from there.

If the user says source files exist, scan them before writing. If they attach images, embed them as base64 data URIs (see the Screenshots section in `components.md`).

After gathering input:

- If the user did not provide an output path, save to `explainers/<topic>-explainer.html` in the current project (create the `explainers/` dir if needed).
- Do not commit the generated explainer unless the user explicitly asks.

## Content structure

Use this default outline unless the topic calls for something else:

1. **Hero** — one-sentence conclusion, 2–3 key facts, location in the product if it is a UI feature, and the screenshot showcase if images were provided.
2. **Issue / background** — why this exists or what was broken.
3. **Attempts** — why earlier approaches failed (toggle tabs).
4. **End-to-end flow** — stepper through the sequence.
5. **Interaction** — small live simulation of the key behavior with play/speed controls.
6. **Storage / data model** — tables, records, payloads, boundaries.
7. **What's next** — lifecycle, risks, open questions, issue link.

Compress or reorder sections freely when the topic does not need all of them. Narrative flow matters more than completeness.

### Refactoring / architecture explainer — reference skeleton

For "we restructured X" topics, this arc is a fast start — change or drop any section to taste.

1. **Hero** — the one-line outcome + 2–3 facts, with a **TL;DR toggle** carrying "the one rule" and "what is unchanged" so detail is opt-in.
2. **The problem** — what was tangled before, concretely; the thing the refactor kills.
3. **The rule** — the single organizing principle the refactor introduces. Name it plainly.
4. **Anatomy** — the rule applied to one unit, interactive (rail/tabs) so the reader watches the shape repeat.
5. **A concern moved to a boundary** — when the refactor extracts a responsibility (auth, transport, …): a two-zone **boundary diagram** (each zone's role + what crosses, labelled both ways), then a **"where it's headed"** future-architecture flow if that concern becomes its own service.
6. **Stitching it together** — how the pieces compose into the deliverable (binaries, wiring) as a short **stepper**.
7. **Walkthrough: adding the next thing** — the payoff. Work **backwards from a concrete goal** ("starting tomorrow, how do I add X?"), one step per place that must change, ending in a **mental-model table** (the few invariants × where each lives). Concrete example first, the why second.
8. **Appendix: guardrails** — how the structure is kept from drifting (deterministic lint vs judged review).

Narrative principles that make the difference:

- **Concrete before abstract.** Show the diff/code for the real example, then one line of why. A practical maintainer trusts a worked example over an elegant description.
- **Work backwards from the goal** in the "how to extend" walkthrough — start from what the reader wants to be true, then the steps that make it true.
- **End on a mental model** — a small table the reader can hold in their head, not a recap paragraph.
- **Name things by what they do.** Avoid jargon that over-carries meaning or trips ESL readers (prefer "boundary" over "seam", "Role" over "PEP/PDP").
- **Keep the example consistent across steps.** If one step shows a typed constant and another a raw string for the same concept, say why or harmonize it — an unexplained mismatch reads as a mistake.
- **Diagrams carry signal, not echo** (see `components.md`).

## Interaction patterns

Pick interactions that make the topic easier to understand. The CSS/JS for each lives in `components.md`.

- **Animated architecture diagram** for any topic with a multi-step data flow.
- Stepper for sequence/data-flow explanations.
- Instant segmented controls instead of slow range sliders.
- Toggle tabs for failed attempts, alternatives, or before/after states.
- Small live payload/record panels for concrete data shape examples.
- DOM-append animations for step-by-step simulations (append rows, do not replace innerHTML).
- A dot plot on a qualitative spectrum for scores, maturity, or capacity comparisons (never bars).
- **Stepper for procedures and look-alike code.** When the topic is "how to add/extend X", or shows several similar constructors/presets/registry entries, use a click-through stepper (numbered dots + Prev/Next) that reveals ONE concept per step. Never dump a list of unexplained helpers and assume the reader infers the pattern.

### Progressive disclosure — minimise what is on screen

The reader should see only what the current step needs. A wall of code, or a table of look-alike entries, reads as ambiguous and overloads the reader. Instead:

- **One concept per step.** Decompose a procedure into a stepper: what the thing is → pick the variant → show the variant is tiny → register it → test it → done. Each step is a short paragraph plus at most one small code block.
- **Explain every named helper the first time it appears.** Opaque names erode confidence that "it's the same thing per case."
- **Stepper mechanics:** default to step 1; disable Prev/Next at the ends; mark visited dots done; re-run `highlightAll()` after injecting each step's code (set `pre.textContent` then highlight — never `innerHTML` raw code).
- Reach for a stepper over one long section whenever the content has ≥4 steps or ≥3 similar code variants.

## Implementation constraints

- Single `.html` file, inline CSS and JS, no external runtime dependencies.
- JavaScript must be small and readable.
- Works offline and is self-contained (images as base64, no CDN fonts — use the system stack).
- Semantic HTML where practical.
- No secrets, real customer data, or internal tokens. Synthetic example data only.

## Verification

After writing the HTML:

1. **Banned-vocabulary sweep.** Grep the file for emoji outside the approved glyphs (◐ ▶ ✕ ✓ — · ↑ → ↗ arrows), and for `pill|badge|chip|card` in class names, `<table`, and `prog-bar`. Any hit is a design violation — fix it before anything else.
2. **Validate JS:** extract the `<script>` body and run `node -e "new Function(require('fs').readFileSync('/tmp/s.js','utf8'))"` or equivalent.
3. **Overflow sweep at 1440 / 820 / 390.** With a headless browser, after forcing `.reveal` visible, walk `body *` and flag any element where `scrollWidth - clientWidth > 4` and `overflow-x` is not auto/scroll/hidden, plus page-level `documentElement.scrollWidth > clientWidth`. Text bleeding outside its box is the single most common defect — never ship without this sweep. (Expected exception: `::after` flow arrows positioned in a grid gap.)
4. **Click every interactive state once:** each filter tab/rail button (assert it shows > 0 items), each popover via real click *and* keyboard focus, both themes. While there, grep the file for `var(--` names not defined in `:root` — an undefined custom property fails silently.
5. **Walk Present mode end to end:** enter with the `▶` button, arrow through every slide and fragment to the end, then `Esc` and confirm the page is restored (including any filter state a tab-stepping slide changed). Watch for slides scaled below ~0.75 (split them), pixel-measuring widgets under scale, and console errors. Note: `scroll-behavior:smooth` makes `scrollIntoView` async — use `behavior:'instant'` in test scripts before sampling coordinates.
6. Confirm `git status --porcelain` so the user can see whether the file is tracked or untracked.

## Final response

Keep it short:

- File path created/updated.
- Main interactive pieces included.
- Slide count and how Present mode splits the sections.
- Whether screenshots were embedded.
- JS validation + Present walkthrough result.
- Tracked or untracked.
