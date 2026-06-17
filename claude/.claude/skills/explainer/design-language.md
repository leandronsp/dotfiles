# Design language

Every explainer ships at the bar set by **`references/engineering-foundation-explainer.html`** — the canonical design-language reference. Read it before building. When a rule below is unclear, copy what that file does; do not invent.

The look is editorial, not dashboard: deep navy canvas, one cyan accent, hairline rules, mono microtype, generous whitespace. A finished page is **typography + hairlines + dots + the device set below** — nothing else. These rules exist so the bar is reachable mechanically, without taste calls: follow them literally.

## Banned → replacement

Hard rules, not taste. If a draft contains anything in the left column, replace it before showing the user.

| Never | Always instead |
|---|---|
| Emoji as iconography (🛡️ 🐹 🔗) | Mono step numbers (`01`…), status dots, plain typography |
| Bordered or tinted boxes ("cards") holding text | Grouped ledger + inspect panel; aside columns for short prose |
| Status pills, badges, lozenges, chips | `.flag` — 5px dot + mono uppercase microtext |
| Tinted background fills as status | Hairline border; **dashed = not yet**; **accent = selected / the subject** |
| Progress bars | Dot plot on one labelled qualitative spectrum |
| Boxed `<table>` | Ledger grid — mono microlabel header row + hairline rows |
| Text crammed inside SVG shapes | Empty geometry + hairline leader lines to outside labels |
| Hover-only or cursor-following tooltips | Anchored popover (hover + tap + focus) or a fixed detail panel |
| Centered multi-line text in containers | Left-aligned |
| Fixed-width step boxes; >6-step horizontal pipelines | Numbered ledger rows, or a journey track |
| A coloured mark on every item | Mark exceptions only; state the default once ("everything here is active unless flagged") |
| Pill-shaped filter tabs | Mono text rail with a funnel icon, dim counts, accent underline on active |
| Every diagram element in the same colour | One accent for subject/selection; dashed for absent/future; everything else quiet |
| Repeating in a diagram a label the prose already established | Diagrams carry signal, not echo |

**Exemptions:** interactive *controls* (play buttons, segmented controls, theme/present toggles) and *live-demo surfaces* (sim panes, payload/record panels) may keep borders and backgrounds — they are machinery, not content.

## The device set

Compose pages from these. Combining is fine; inventing beyond them needs a reason, and the invention must still be hairlines + mono microtype + dots.

1. **Grouped ledger** — the default for any list, table, or grid of ≥5 items. One-line rows under mono group headers.
2. **Inspect panel (master–detail)** — when ledger items or diagram segments carry prose. Hover/tap/focus selects; the panel swaps.
3. **Annotated geometry** — empty SVG shapes, labels leader-lined outside (the test pyramid).
4. **Node circuit / journey track** — sequences and cycles: numbered circles on a hairline; dashed return path for loops; vertical gate bars crossing a path for checkpoints.
5. **Butterfly coverage map** — two subjects guarding shared concerns; empty wing = honest absence.
6. **Dot plot** — scores or maturity as dots on one labelled spectrum, never bars.
7. **Flags & dots** — the page's only status grammar.
8. **Aside / ruled columns** — short prose and checklists behind a hairline left rule.

## Tokens

Dark (default):

```css
:root {
  color-scheme: dark;
  --bg:#06060a; --surface:#0e0e14; --surface-hover:#14141c;
  --border:#1e1e2e; --border-strong:#2a2a40;
  --text:#e8e8f0; --text-dim:#7a7a8c;
  --text-faint:#62627a; /* decorative/microtype only — not body text */
  --accent:#00d9ff; --accent-dim:#00d9ff33;
  --success:#00e676; --success-dim:#00e67622;
  --error:#ff5252; --error-dim:#ff525222;
  --warning:#ffd740; --warning-dim:#ffd74022;
  --violet:#b388ff; --violet-dim:#b388ff22;
  --mono:"SF Mono","Fira Code",ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,monospace;
  --sans:"Inter",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;
  --ease-out-expo:cubic-bezier(0.16,1,0.3,1); --ease-in-out:cubic-bezier(0.65,0,0.35,1);
}
[data-theme="light"] {
  color-scheme: light;
  --bg:#faf9f7; --surface:#ffffff; --surface-hover:#f5f4f2;
  --border:#e8e6e3; --border-strong:#d4d0ca;
  --text:#0a0a0f; --text-dim:#6b6b7b; --text-faint:#8e8e9a;
  --accent:#0066ff; --accent-dim:#0066ff18;
  --success:#00c853; --success-dim:#00c85318;
  --error:#d50000; --error-dim:#d5000018;
  --warning:#ffab00; --warning-dim:#ffab0018;
  --violet:#6200ea; --violet-dim:#6200ea18;
}
```

Verify both themes — `--*-dim` colours that read on navy can vanish on paper-white.

## Typography & layout

- Hero headline: `clamp(3rem, 8.5vw, 7.5rem)`, weight 800, letter-spacing `-0.04em`, line-height `0.92`.
- Section heads: `clamp(1.7rem, 3.5vw, 3rem)`, weight 700. Section subs: `--text-dim`, max-width `60ch`.
- Body: `1rem`, line-height `1.7`, `--text-dim`, max-width `60ch`. Detail text in devices: `.8–.92rem`.
- Microtype (eyebrows, group headers, flags, stamps): `var(--mono)`, `.58–.68rem`, uppercase, `.12–.16em` tracking.
- Shell: `max-width:1100px`, `padding:0 clamp(24px,5vw,80px)` — **content width ≈ 956px at full size. Before sizing any horizontal device, do the arithmetic: items × min-width + gaps must fit 956px, or it silently clips.**
- Grid blowout guard on every multi-column grid: `> * { min-width: 0 }`.
- Breakpoints: 900px (multi-column → single, tracks go vertical, leaders hide) and 720px (hero collapses, ledger headers hide, rows stack). Always include `@media (prefers-reduced-motion: reduce)` disabling all animation.
- Sticky side panels: `position: sticky; top: 48px`, released to `static` under 900px.
- **Vertical rhythm is hierarchical:** ~40px binds a section heading to its first block; **72px** (`.artifact{margin-top:72px}`) separates sibling artifacts inside a section; and every artifact opens with its own mono eyebrow (`Why the gaps exist`, `The gap ledger · 6 open`) so multi-artifact sections read as titled chapters, not piles. In Present mode, override artifacts back to the stage rhythm (`.pr-stage .artifact{margin-top:28px!important}`).
- **End the page with a bookend** — one `muted-note` line after the final artifact that echoes the hero claim ("That's the picture — further along than it feels, with every gap numbered"). A page that stops on a ledger reads truncated.

## Motion

- Scroll reveal: IntersectionObserver on `.reveal` → `opacity 0 / translateY(50px)` → visible over `.9s var(--ease-out-expo)`, staggered `.reveal-delay-1…6` (0.06s steps).
- Panel swap: re-trigger a single `pyrIn`-style keyframe (`opacity 0 / translateY(6px)`, .3s) by toggling a `.swap` class and forcing reflow (`void el.offsetWidth`).
- Two fixed radial-gradient orbs, `pointer-events:none`, slow float. Theme toggle: fixed 44px circle, top-right; Present toggle beside it.
