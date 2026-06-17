# Component library

Copy-paste blocks, extracted verbatim from the worked example — if these drift from `references/engineering-foundation-explainer.html`, the example wins.

## Base & shell

```css
*{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth;-webkit-font-smoothing:antialiased}
body{background:var(--bg);color:var(--text);font-family:var(--sans);font-size:16px;line-height:1.6;overflow-x:hidden}
.shell{max-width:1100px;margin:0 auto;padding:0 clamp(24px,5vw,80px);position:relative;z-index:1}
section{padding:clamp(72px,10vh,130px) 0;position:relative}
section+section::before{content:'';position:absolute;top:0;left:clamp(24px,5vw,80px);right:clamp(24px,5vw,80px);height:1px;background:linear-gradient(90deg,transparent,var(--border-strong) 20%,var(--border-strong) 80%,transparent)}
.eyebrow{font-family:var(--mono);font-size:.68rem;text-transform:uppercase;letter-spacing:.15em;color:var(--text-dim)}
.block-head{display:flex;justify-content:space-between;align-items:baseline;gap:16px;flex-wrap:wrap;margin-bottom:18px}
.data-stamp{font-family:var(--mono);font-size:.6rem;letter-spacing:.12em;text-transform:uppercase;color:var(--text-faint)}
.muted-note{margin-top:10px;font-size:.82rem;color:var(--text-dim)}
.artifact{margin-top:72px}
```

`block-head` pairs an eyebrow with a right-aligned `data-stamp`. **Stamp every hand-counted dataset** (file tallies, subjective scores): `counts as of 11 Jun 2026`. Honest beats evergreen-looking.

## Hero

Kicker, display headline (`em` for the accent word), lede, optional glossary hint. No chips, no badges:

```html
<div class="hero-kicker">Project · Topic</div>
<h1 class="display">Short<br>punchy <em>claim</em></h1>
<p class="lede">One- or two-sentence thesis.</p>
<p class="gloss-hint">New to the stack? <button class="term" data-term="gloss">Dotted terms</button> open a plain-English definition.</p>
```

## Status flags & dots — the only status grammar

```css
/* Status flags — dot + mono microtext, the only status grammar on the page */
.flag{display:inline-flex;align-items:center;gap:7px;font-family:var(--mono);font-size:.62rem;letter-spacing:.12em;text-transform:uppercase;white-space:nowrap}
.flag i{width:5px;height:5px;border-radius:50%;flex-shrink:0}
.flag.done{color:var(--success)}.flag.done i{background:var(--success)}
.flag.progress{color:var(--warning)}.flag.progress i{background:var(--warning)}
.flag.next{color:var(--accent)}.flag.next i{background:var(--accent)}
.flag.gap{color:var(--error)}.flag.gap i{background:var(--error)}
```

Usage: `<span class="flag done"><i></i>also in CI</span>`. **Mark exceptions, not the default** — if 17 of 22 items are active, active rows carry nothing; only ◐ partial and ○ upcoming rows get a flag, and the section sub states the default once.

## Glossary terms (for readers new to the domain)

Mark jargon once per neighbourhood; define in one `GLOSSARY` map (`{term:{t:title,d:plain-English definition}}`); a single shared popover element. Open on click (delegated — terms also appear in JS-rendered panels), close on Esc / outside-click / scroll; position centered under the button, clamped to the viewport, flipped above when out of room; `aria-expanded` on the open term.

```css
/* Glossary terms */
.term{appearance:none;background:none;border:0;padding:0;font:inherit;color:inherit;cursor:help;text-decoration:underline dotted color-mix(in srgb,var(--accent) 60%,transparent);text-underline-offset:3px;text-decoration-thickness:1px}
.term:hover,.term:focus-visible,.term[aria-expanded="true"]{color:var(--accent);text-decoration-style:solid;outline:none}
.gloss-pop{position:absolute;z-index:240;width:min(330px,calc(100vw - 32px));background:var(--surface);border:1px solid var(--border-strong);border-radius:12px;padding:16px 18px;box-shadow:0 12px 40px rgba(0,0,0,.35);opacity:0;pointer-events:none;transition:opacity .2s ease,transform .2s ease;transform:translateY(4px)}
.gloss-pop.open{opacity:1;pointer-events:auto;transform:none}
.gloss-pop-term{font-family:var(--mono);font-size:.68rem;letter-spacing:.12em;text-transform:uppercase;color:var(--accent);margin-bottom:8px}
.gloss-pop-body{font-size:.84rem;color:var(--text-dim);line-height:1.6}
.gloss-pop-body a{color:var(--accent)}
```

## Grouped ledger + filter rail + inspect panel — the workhorse

List rows render from a data array; selection (mouseenter, click, focus, Enter/Space) drives the panel; the filter rail shows/hides groups:

```css
/* What's in place — grouped scan list + sticky inspect panel */
.filter-rail{display:flex;gap:20px;flex-wrap:wrap;align-items:center;margin-bottom:24px;font-family:var(--mono);font-size:.65rem;letter-spacing:.14em;text-transform:uppercase}
.filter-rail-icon{color:var(--text-faint);flex-shrink:0;margin-bottom:5px}
.filter-rail button{appearance:none;background:none;border:0;padding:0 0 5px;font:inherit;letter-spacing:inherit;text-transform:inherit;color:var(--text-dim);cursor:pointer;border-bottom:1px solid transparent;transition:all .25s ease}
.filter-rail button:hover{color:var(--text)}
.filter-rail button.active{color:var(--accent);border-bottom-color:var(--accent)}
.filter-rail button span{opacity:.5;margin-left:3px}
.inspect-legend{display:inline-flex;gap:22px;margin-left:auto;margin-bottom:5px;font-family:var(--mono);font-size:.62rem;letter-spacing:.12em;text-transform:uppercase;color:var(--text-dim);flex-wrap:wrap}
.inspect-legend span{display:inline-flex;align-items:center;gap:8px}
.dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}
.dot.active{background:var(--success)}
.dot.partial{background:linear-gradient(90deg,var(--warning) 50%,transparent 50%);border:1px solid var(--warning)}
.dot.upcoming{border:1px solid var(--accent);background:transparent}
.inspect-grid{display:grid;grid-template-columns:minmax(0,1fr) minmax(280px,.8fr);gap:56px;align-items:start}
.inspect-list{min-width:0}
.inspect-group{font-family:var(--mono);font-size:.62rem;letter-spacing:.16em;text-transform:uppercase;color:var(--text-faint);padding:28px 0 10px;border-bottom:1px solid var(--border)}
.inspect-list .inspect-group:first-child{padding-top:0}
.inspect-row{display:flex;align-items:center;gap:14px;padding:11px 2px;border-bottom:1px solid var(--border);cursor:pointer;outline:none}
.inspect-row-name{font-size:.92rem;color:var(--text);font-weight:400;line-height:1.4;transition:color .25s ease}
.inspect-row.flagship .inspect-row-name{font-weight:600}
.inspect-row-flag{margin-left:auto;padding-left:12px;display:inline-flex;align-items:center;gap:7px;font-family:var(--mono);font-size:.58rem;letter-spacing:.12em;text-transform:uppercase;white-space:nowrap}
.inspect-row-flag.partial{color:var(--warning)}
.inspect-row-flag.upcoming{color:var(--accent)}
.inspect-row:hover .inspect-row-name,.inspect-row:focus-visible .inspect-row-name,.inspect-row.sel .inspect-row-name{color:var(--accent)}
.inspect-side{position:sticky;top:48px}
.inspect-detail{border-left:1px solid var(--border-strong);padding-left:28px}
.inspect-eyebrow{font-family:var(--mono);font-size:.65rem;letter-spacing:.14em;text-transform:uppercase;margin-bottom:10px}
.inspect-eyebrow.active{color:var(--success)}
.inspect-eyebrow.partial{color:var(--warning)}
.inspect-eyebrow.upcoming{color:var(--accent)}
.inspect-title{font-size:1.15rem;font-weight:700;margin-bottom:10px;color:var(--text);line-height:1.4}
.inspect-body{font-size:.88rem;color:var(--text-dim);line-height:1.7}
.inspect-body code{font-family:var(--mono);font-size:.85em;color:var(--accent)}
.inspect-pills{margin-top:18px;display:flex;gap:16px;flex-wrap:wrap}
.inspect-detail.swap>*{animation:pyrIn .3s var(--ease-out-expo)}
```

```html
<div class="filter-rail" id="filters">
  <svg class="filter-rail-icon" width="13" height="13" viewBox="0 0 16 16" aria-hidden="true"><path d="M1.5 2.5h13L10 8.6V13l-4 1.8V8.6L1.5 2.5z" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linejoin="round"/></svg>
  <button class="active" data-key="all">All <span>22</span></button>
  <button data-key="quality">Code Quality <span>6</span></button>
  <span class="inspect-legend"><!-- rides the rail line, right-aligned -->
    <span><i class="dot partial"></i>partially in place</span>
    <span><i class="dot upcoming"></i>upcoming</span>
  </span>
</div>
<div class="inspect-grid">
  <div class="inspect-list" id="list"><!-- rendered from data --></div>
  <div class="inspect-side" id="side">
    <div class="inspect-detail" id="detail" aria-live="polite">
      <div class="inspect-eyebrow"></div><h4 class="inspect-title"></h4>
      <p class="inspect-body"></p><div class="inspect-pills"></div>
    </div>
  </div>
</div>
```

JS contract (see `references/engineering-foundation-explainer.html` for the full version):

- Row: `tabindex=0`, `role=button`; flagship items get `font-weight:600`.
- `select(id)`: toggle `.sel`, fill eyebrow (`Category · Status`, class-coloured), title (may contain `term` buttons), body (innerHTML), flags; re-trigger `.swap`; close any open glossary popover.
- `filter(key)`: show/hide groups; if the selected row becomes hidden, select the filtered group's first item; selecting a hidden row programmatically resets the filter to All.
- **Mobile:** on selection under 900px, move the panel node directly *under the selected row* (accordion feel); restore it to the side column above 900px (and while presenting). `resize` re-places it.

## Header ledgers (replaces every `<table>`)

```css
/* De-boxed ledger grids (gaps, bigger picture) */
.ledger-head{display:grid;gap:24px;padding:0 2px 10px;border-bottom:1px solid var(--border);font-family:var(--mono);font-size:.62rem;letter-spacing:.16em;text-transform:uppercase;color:var(--text-faint)}
.ledger-row{display:grid;gap:6px 24px;padding:13px 2px;border-bottom:1px solid var(--border);align-items:baseline}
.gaps-cols{grid-template-columns:minmax(0,1.5fr) minmax(0,.55fr) minmax(0,.62fr) 64px}
.compare-cols{grid-template-columns:minmax(0,.75fr) minmax(0,1fr) minmax(0,1.15fr)}
.ledger-title{font-size:.92rem;font-weight:600;color:var(--text)}
.ledger-sub{font-size:.82rem;color:var(--text-dim);line-height:1.5;margin-top:2px}
.ledger-sub code{font-size:.85em;font-family:var(--mono);color:var(--accent)}
.ledger-dim{font-size:.85rem;color:var(--text-dim)}
.ledger-flags{display:flex;flex-direction:column;gap:8px;align-items:flex-start}
.ledger-flags .flag{white-space:normal;text-align:left}
```

Comparison usage: dim the baseline column (`.ledger-dim`) and let the subject column carry colour via flags — the baseline literally looking grey is the argument. On mobile the header row hides; give orphaned dim cells a mono `::before` prefix (`typical:`).

## Numbered sequence ledger (pipelines, ordered steps)

```css
/* numbered gate ledger; order reads top-to-bottom */
.gate-list{margin-top:8px}
.gate-row{display:grid;grid-template-columns:36px 176px minmax(0,1fr) auto;gap:6px 16px;align-items:baseline;padding:10px 2px;border-bottom:1px solid var(--border)}
.gate-num{font-family:var(--mono);font-size:.62rem;letter-spacing:.12em;color:var(--text-faint)}
.gate-name{font-family:var(--mono);font-size:.78rem;font-weight:700;color:var(--text)}
.gate-desc{font-size:.85rem;color:var(--text-dim);line-height:1.5}
```

```html
<div class="gate-row">
  <span class="gate-num">01</span><span class="gate-name">lint</span>
  <span class="gate-desc">oxlint → ESLint + security plugin</span>
  <span class="flag done"><i></i>also in CI</span><!-- exceptions only -->
</div>
```

## Link ledger (roadmaps, grouped external links)

```css
/* What's next — grouped ledger of epic links */
.rm-group{display:flex;align-items:center;gap:9px;font-family:var(--mono);font-size:.62rem;letter-spacing:.16em;text-transform:uppercase;color:var(--text-faint);padding:28px 0 10px;border-bottom:1px solid var(--border)}
.rm-list .rm-group:first-child{padding-top:0}
.rm-group i{width:6px;height:6px;border-radius:50%;flex-shrink:0}
.rm-group.now i{background:var(--warning)}
.rm-group.beta i{background:var(--accent)}
.rm-group.ga i{background:var(--violet)}
.rm-row{display:flex;align-items:baseline;gap:16px;padding:12px 2px;border-bottom:1px solid var(--border);text-decoration:none}
.rm-row-title{font-size:.92rem;font-weight:600;color:var(--text);white-space:nowrap;transition:color .25s ease}
.rm-row-desc{font-size:.82rem;color:var(--text-dim);line-height:1.5;min-width:0}
.rm-row-ref{margin-left:auto;padding-left:12px;font-family:var(--mono);font-size:.62rem;letter-spacing:.1em;color:var(--text-faint);white-space:nowrap;transition:color .25s ease}
.rm-row:hover .rm-row-title,.rm-row:hover .rm-row-ref{color:var(--accent)}
```

Group headers carry a coloured phase dot (`<div class="rm-group now"><i></i>Now · 2</div>`); rows are `<a>` with title / desc / `Epic #25 ↗` ref. An item with no tracker yet is a `<div>` row whose ref is `<span class="flag next"><i></i>Epic TBD</span>`.

## Aside & ruled-emphasis columns (short prose, checklists, warnings)

```css
/* Editorial aside columns — hairline rule instead of boxes */
.pair-grid{display:grid;grid-template-columns:1fr 1fr;gap:44px;align-items:start}
.pair-grid>*{min-width:0}
.aside-col{border-left:1px solid var(--border-strong);padding-left:24px}
.aside-col .eyebrow{display:block;margin-bottom:14px}
.aside-col p{font-size:.9rem;color:var(--text-dim);line-height:1.65}
.aside-col p em{color:var(--text)}
.check-list{list-style:none;display:grid;gap:10px}
.check-list li{display:flex;gap:10px;font-size:.9rem;color:var(--text-dim)}
.check-list li>span{flex-shrink:0}
.check-list .yes{color:var(--success)}
.check-list .meh{color:var(--text-faint)}
```

`gap-why` is the replacement for tinted callout boxes: warning-ruled columns, `h3` in the warning colour, body in `--text-dim`.

## Dot plot (replaces every progress bar)

```css
/* Workflow maturity — dot plot on a single qualitative spectrum */
.maturity-grid{display:grid;grid-template-columns:minmax(0,.9fr) 1fr;gap:4px 32px;align-items:center;margin-top:8px}
.maturity-ends{grid-column:2;display:flex;justify-content:space-between;font-family:var(--mono);font-size:.58rem;letter-spacing:.12em;text-transform:uppercase;color:var(--text-faint);margin-bottom:4px}
.mat-label{font-size:.9rem;color:var(--text);padding:9px 0;line-height:1.45}
.mat-label code{font-size:.82em;font-family:var(--mono)}
.mat-track{position:relative;height:24px}
.mat-track::before{content:'';position:absolute;left:0;right:0;top:50%;height:1px;background:var(--border)}
.mat-track::after{content:'';position:absolute;right:0;top:50%;transform:translateY(-50%);width:1px;height:9px;background:var(--border-strong)}
.mat-tick{position:absolute;left:0;top:50%;transform:translateY(-50%);width:1px;height:9px;background:var(--border-strong)}
.mat-dot{position:absolute;top:50%;left:0;transform:translate(-50%,-50%);width:9px;height:9px;border-radius:50%;transition:left 1.1s var(--ease-out-expo)}
.mat-dot.full{background:var(--success)}
.mat-dot.high{background:var(--accent)}
.mat-dot.low{background:var(--error)}
```

Axis ends are qualitative (`not started` → `strong`), never numeric — invented percentages read as false precision. Dots animate `left: 0 → data-width%` on reveal (and on slide entry in Present mode). Pair with a `data-stamp`.

## Node circuit (loops)

Numbered nodes on a hairline track, dashed return path, detail panel below:

```css
/* Loop diagram — numbered nodes on a circuit, detail panel below */
.loop-track{position:relative;display:flex;justify-content:space-between;margin:18px 0 0}
.loop-track::before{content:'';position:absolute;left:8.3%;right:8.3%;top:18px;height:1px;background:var(--border-strong)}
.loop-node{position:relative;flex:1;display:flex;flex-direction:column;align-items:center;gap:11px;cursor:pointer;outline:none}
.loop-node i{width:37px;height:37px;border-radius:50%;border:1px solid var(--border-strong);background:var(--bg);display:grid;place-items:center;font-family:var(--mono);font-style:normal;font-size:.62rem;letter-spacing:.06em;color:var(--text-dim);transition:all .25s ease}
.loop-node:hover i,.loop-node:focus-visible i{border-color:var(--text-dim);color:var(--text)}
.loop-node.sel i{border-color:var(--accent);color:var(--accent);box-shadow:0 0 0 4px var(--accent-dim)}
.loop-node.future i{border-style:dashed}
.loop-node-label{font-size:.8rem;font-weight:600;color:var(--text);text-align:center;line-height:1.35;max-width:124px;transition:color .25s ease}
.loop-node.future .loop-node-label{color:var(--text-dim)}
.loop-node.sel .loop-node-label{color:var(--accent)}
.loop-detail{border-left:1px solid var(--border-strong);padding-left:28px;margin-top:40px;min-height:96px}
.loop-detail-eyebrow{font-family:var(--mono);font-size:.65rem;letter-spacing:.14em;text-transform:uppercase;margin-bottom:8px;color:var(--success)}
.loop-detail-eyebrow.future{color:var(--warning)}
.loop-detail-title{font-size:1.05rem;font-weight:700;margin-bottom:6px;color:var(--text)}
.loop-detail-body{font-size:.88rem;color:var(--text-dim);line-height:1.7;max-width:64ch}
.loop-detail-body code{font-family:var(--mono);font-size:.85em;color:var(--accent)}
.loop-detail.swap>*{animation:pyrIn .3s var(--ease-out-expo)}
.loop-return{position:relative;height:24px;margin:14px 8.3% 0;border:1px dashed var(--border-strong);border-top:none;border-radius:0 0 14px 14px}
.loop-return-arrow{position:absolute;left:-5.5px;top:-10px;color:var(--text-faint);font-size:.8rem;line-height:1}
.loop-return-label{position:absolute;left:50%;bottom:0;transform:translate(-50%,50%);background:var(--bg);padding:0 14px;font-family:var(--mono);font-size:.62rem;letter-spacing:.16em;text-transform:uppercase;color:var(--text-faint);white-space:nowrap}
```

Nodes render from a data array (`{label, body, future?}`); `i` holds the mono number; `.future` nodes get a dashed circle and a warning eyebrow in the panel; the selected node gets the accent ring. The dashed `.loop-return` runs under the row with its label sitting **on** the line (solid `--bg` background) and an `↑` into node 1. Under 900px the track turns vertical and the return hides.

## Journey / gauntlet track (checkpoints on a path)

A horizontal SVG line with station dots and labels above (`working tree → commit → push → MR → main`), gates as short vertical bars crossing it, each labelled below in mono microtext. Active gates solid `--success`; the section's subject taller in `--accent`; a partial gate dashed `--warning`. One such diagram absorbs a whole "X runs first, then Y" paragraph.

```css
/* Gate flow — a change's path from working tree to main, through gates */
.gate-flow svg{width:100%;max-width:960px;display:block}
.gf-line{stroke:var(--border-strong)}
.gf-station{font-family:var(--sans);font-size:12.5px;font-weight:600;fill:var(--text)}
.gf-dot{fill:var(--text-faint)}
.gf-name{font-family:var(--mono);font-size:9.5px;font-weight:700;letter-spacing:.08em}
.gf-detail{font-family:var(--mono);font-size:9px;fill:var(--text-dim)}
```

## Butterfly coverage map (two subjects, shared concerns)

```css
/* Coverage map — concerns on a center spine, subject A left, subject B right */
.lint-map{margin-top:72px}
.lm-intro{font-size:.9rem;color:var(--text-dim);line-height:1.7;max-width:60ch;margin-bottom:36px}
.lm-head,.lm-row{display:grid;grid-template-columns:1fr 210px 1fr;gap:0 18px;align-items:center}
.lm-head{align-items:baseline;margin-bottom:22px}
.lm-h{display:flex;flex-direction:column;gap:4px}
.lm-h code{font-family:var(--mono);font-size:.95rem;font-weight:700;color:var(--accent)}
.lm-h.right{align-items:flex-end;text-align:right}
.linter-scope{font-family:var(--mono);font-size:.6rem;letter-spacing:.12em;text-transform:uppercase;color:var(--text-faint)}
.lm-mid-label{text-align:center;font-family:var(--mono);font-size:.58rem;letter-spacing:.16em;text-transform:uppercase;color:var(--text-faint)}
.lm-row{min-height:46px}
.lm-cell{display:flex;align-items:center;gap:14px;font-size:.8rem;color:var(--text-dim);line-height:1.45}
.lm-cell code{font-family:var(--mono);font-size:.92em;color:var(--accent)}
.lm-left{justify-content:flex-end;text-align:right}
.lead{flex:1 0 26px;height:1px;background:var(--border)}
.lm-concern{text-align:center;font-family:var(--mono);font-size:.64rem;letter-spacing:.12em;text-transform:uppercase;color:var(--text-dim);line-height:1.5}
```

Row = left wing (right-aligned text + `.lead` hairline) / center `.lm-concern` / right wing. **Leave a wing empty where coverage genuinely doesn't exist** — the asymmetry is the signal — and explain why in a one-line `muted-note`. Open the map with an eyebrow that ties it to its context plus a one-sentence reading key. Mobile: rows stack, concern first, wings get mono prefixes, empty wings hide.

## Annotated geometry (the test-pyramid pattern)

```css
/* Test pyramid — annotated geometry left, detail panel right */
.pyr-grid{display:grid;grid-template-columns:minmax(0,1.1fr) minmax(250px,.9fr);gap:44px;align-items:center}
.pyr-grid svg{width:100%;max-width:560px;display:block}
.pyr-row{cursor:pointer;outline:none}
.pyr-shape{fill:var(--text);fill-opacity:.04;stroke:var(--border-strong);stroke-width:1;transition:all .25s ease}
.pyr-row:hover .pyr-shape,.pyr-row:focus-visible .pyr-shape{stroke:var(--text-dim)}
.pyr-row.sel .pyr-shape{stroke:var(--accent);fill:var(--accent);fill-opacity:.07}
.pyr-name{font-family:var(--sans);font-size:12.5px;font-weight:600;fill:var(--text);transition:fill .25s ease}
.pyr-row.sel .pyr-name{fill:var(--accent)}
.pyr-count{font-family:var(--mono);font-size:9.5px;fill:var(--text-dim)}
.pyr-leader{stroke:var(--border-strong);stroke-width:1}
.pyr-flag{font-family:var(--mono);font-size:8.5px;letter-spacing:.08em}
.pyr-detail{border-left:1px solid var(--border-strong);padding-left:28px}
.pyr-detail-eyebrow{font-family:var(--mono);font-size:.65rem;letter-spacing:.14em;text-transform:uppercase;margin-bottom:10px}
.pyr-detail-eyebrow.ci{color:var(--success)}
.pyr-detail-eyebrow.local{color:var(--warning)}
.pyr-detail-title{font-size:1.15rem;font-weight:700;margin-bottom:6px;color:var(--text)}
.pyr-detail-meta{font-family:var(--mono);font-size:.72rem;color:var(--text-dim);margin-bottom:14px}
.pyr-detail-body{font-size:.88rem;color:var(--text-dim);line-height:1.7}
.pyr-detail-body a{color:var(--accent)}
.pyr-detail.swap>*{animation:pyrIn .3s var(--ease-out-expo)}
@keyframes pyrIn{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}
```

Rules: shapes are **empty** (1px `--border-strong` stroke, 4–7% fill); names + counts hang off hairline leaders on one side, status dot + microflag on the other; selecting a layer (hover, tap, Tab+Enter — `<g tabindex="0" role="button">`) turns it accent and swaps the `border-left` detail panel beside it. Compute leader endpoints so labels never collide; widest label decides the viewBox margin. Copy the SVG geometry from `references/engineering-foundation-explainer.html` and adjust coordinates rather than deriving from scratch.

## Smaller pieces

- **TL;DR toggle:** native `<details>` reveal-upward summary pill — pill-shaped *buttons* are fine; pill-shaped *status* is not.
- **Micro-ledgers:** `fact-grid` (dt/dd rows), `timeline-item` rows, and `data-row` key-value rows are acceptable — they are already hairline rows. `issue-link` (bordered CTA link) is a control, exempt.
- **Interactive-demo machinery (exempt from the no-boxes rule):** segmented controls, `.play-btn`, sim panes, payload/record panels — keep borders and backgrounds; they are machinery.

## Code blocks

CSS — use these exact values. `pre-wrap` causes bad wrapping in narrow columns; `pre` + `overflow-x: auto` gives a scrollbar instead:

```css
.code-block pre {
  padding: 20px 16px;
  font-family: var(--mono);
  font-size: 0.80rem;
  line-height: 1.75;
  color: var(--text-dim);
  white-space: pre;
  overflow-x: auto;
}
```

**JSON highlighting** — include these CSS classes, then run `highlightCode()` on JSON blocks:

```css
.json-key    { color: var(--accent); }
.json-string { color: #98c379; }
.json-number { color: #d19a66; }
.json-bool   { color: #c678dd; }
.json-null   { color: var(--text-dim); }
```

**Go highlighting** — use a token-based `highlightGo()` that extracts comments and string literals into `\x00N\x00` placeholders *before* running keyword/type/number passes. This prevents the regex from matching inside span attribute values:

```js
function highlightGo(text) {
  let html = text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  const tokens = [];
  const tok = (cls, m) => { const i = tokens.length; tokens.push(`<span class="${cls}">${m}</span>`); return `\x00${i}\x00`; };
  // 1. Comments and strings first (highest priority — never re-processed)
  html = html.replace(/(\/\/[^\n]*)/g, m => tok('go-com', m));
  html = html.replace(/(\/\*[\s\S]*?\*\/)/g, m => tok('go-com', m));
  html = html.replace(/(`[^`\x00]*`)/g, m => tok('go-str', m));
  html = html.replace(/("(?:[^"\\\x00]|\\.)*")/g, m => tok('go-str', m));
  // 2. Keywords, types, numbers
  const kws = ['package','import','func','type','struct','interface','map','return','if','else','for','range','switch','case','default','var','const','go','defer','select','chan','nil','true','false'];
  html = html.replace(new RegExp(`\\b(${kws.join('|')})\\b`,'g'), '<span class="go-kw">$1</span>');
  const types = ['string','int','int64','bool','error','any','byte','float64','context','Context','len','make','new','append'];
  html = html.replace(new RegExp(`\\b(${types.join('|')})\\b`,'g'), '<span class="go-type">$1</span>');
  // Exclude digits adjacent to the \x00 token placeholders — otherwise this pass
  // wraps the placeholder indices, the restore step fails to match, and bare numbers leak.
  html = html.replace(/(?<!\x00)\b(\d+(?:\.\d+)?)\b(?!\x00)/g, '<span class="go-num">$1</span>');
  html = html.replace(/\bfunc\b\s+(\w+)\s*\(/g, m => m.replace(/(\w+)(?=\s*\()/, n => `<span class="go-fn">${n}</span>`));
  // 3. Restore placeholders
  return html.replace(/\x00(\d+)\x00/g, (_, i) => tokens[+i]);
}
```

**`highlightAll()`** — run once on init for static blocks. For any JS-rendered code block, re-run `highlightAll()` after replacing the DOM content. Use `pre.textContent = code` + `highlightAll()` rather than `innerHTML = highlightCode(code)` directly, so the guard (`pre.querySelector('span[class^="go-"]')`) can detect already-processed blocks and skip them.

## Screenshots

If the topic has a UI surface, screenshots are the fastest way to give readers the "aha" moment. Place them **immediately after the hero text**, before any numbered sections.

When the user attaches images: base64-encode each and embed as a `data:image/png;base64,...` URI so the file stays self-contained. Encode with Python: `base64.b64encode(open(path,'rb').read()).decode('ascii')`. If no screenshots are provided, skip the showcase entirely — do not use placeholder boxes.

```html
<!-- Full-width main screenshot -->
<div class="screenshot-main reveal reveal-delay-2">
  <div class="screenshot-frame">
    <img src="data:image/png;base64,..." alt="..." loading="lazy">
  </div>
  <p class="screenshot-caption">Short caption.</p>
</div>

<!-- Optional 2-up pair for detail shots -->
<div class="screenshot-pair reveal reveal-delay-3">
  <div><div class="screenshot-frame"><img ...></div><p class="screenshot-caption">...</p></div>
  <div><div class="screenshot-frame"><img ...></div><p class="screenshot-caption">...</p></div>
</div>
```

```css
.screenshot-frame {
  border: 1px solid var(--border);
  border-radius: 16px;
  overflow: hidden;
  background: #0d0d18;
  box-shadow: 0 0 0 1px var(--border), 0 32px 80px -16px rgba(0,0,0,0.5);
  transition: box-shadow 0.4s var(--ease-out-expo), border-color 0.4s var(--ease-out-expo), transform 0.4s var(--ease-out-expo);
  position: relative;
}
.screenshot-frame::before {
  content: '';
  position: absolute; top: 0; left: 0; right: 0; height: 1px;
  background: linear-gradient(90deg, transparent 5%, var(--accent-dim) 40%, var(--accent-dim) 60%, transparent 95%);
  opacity: 0.6; z-index: 1;
}
.screenshot-frame:hover {
  border-color: var(--border-strong);
  transform: translateY(-4px);
  box-shadow: 0 0 0 1px var(--border-strong), 0 48px 100px -20px rgba(0,217,255,0.1);
}
.screenshot-frame img { display: block; width: 100%; height: auto; }
.screenshot-main { margin-bottom: 16px; }
.screenshot-pair { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.screenshot-caption { margin-top: 12px; font-family: var(--mono); font-size: 0.72rem; color: var(--text-dim); letter-spacing: 0.04em; }
```

## Responsive (paste and extend per device used)

```css
@media(max-width:900px){
  .pair-grid{grid-template-columns:1fr}
  .lm-head{grid-template-columns:1fr 1fr}
  .lm-mid-label{display:none}
  .lm-row{grid-template-columns:1fr;gap:7px;min-height:0;padding:12px 0;border-bottom:1px solid var(--border)}
  .lm-concern{text-align:left;order:-1}
  .lead{display:none}
  .lm-left{justify-content:flex-start;text-align:left}
  .lm-cell:empty{display:none}
  .lm-left::before{content:'ts';font-family:var(--mono);font-size:.58rem;letter-spacing:.1em;text-transform:uppercase;color:var(--text-faint)}
  .lm-right::before{content:'go';font-family:var(--mono);font-size:.58rem;letter-spacing:.1em;text-transform:uppercase;color:var(--text-faint)}
  .loop-track{flex-direction:column;align-items:stretch;gap:18px}
  .loop-track::before{left:18px;right:auto;top:18px;bottom:18px;width:1px;height:auto}
  .loop-node{flex-direction:row;gap:14px}
  .loop-node-label{text-align:left;max-width:none}
  .loop-return{display:none}
  .gate-row{grid-template-columns:36px minmax(0,1fr) auto}
  .gate-num{grid-row:1;grid-column:1}
  .gate-name{grid-row:1;grid-column:2}
  .gate-row .flag{grid-row:1;grid-column:3}
  .gate-desc{grid-row:2;grid-column:2/4}
  .pyr-grid{grid-template-columns:1fr;gap:28px}
  .pyr-detail{padding-left:20px}
  .inspect-grid{grid-template-columns:1fr}
  .inspect-side{position:static}
  .inspect-detail{margin:14px 0 22px;padding-left:20px}
  .gap-why{grid-template-columns:1fr}
  .compare-cols{grid-template-columns:1fr}
  .compare-cols .ledger-dim::before{content:'typical: ';font-family:var(--mono);font-size:.58rem;letter-spacing:.1em;text-transform:uppercase;color:var(--text-faint)}
  .maturity-grid{grid-template-columns:1fr;gap:2px}
  .maturity-ends{grid-column:1}
  .mat-label{padding:12px 0 0}
}
@media(max-width:720px){
  .hero-grid{grid-template-columns:1fr}
  .hero-note{display:none}
  .rm-row{flex-direction:column;gap:3px}
  .rm-row-title{white-space:normal}
  .rm-row-ref{margin-left:0;padding-left:0}
  .ledger-head{display:none}
  .ledger-row{grid-template-columns:1fr}
}
@media(prefers-reduced-motion:reduce){
  *,*::before,*::after{animation:none!important;transition:none!important}
  .reveal{opacity:1;transform:none}
}
```

Present-mode zoom guard: every responsive collapse above needs a matching `.pr-stage` override restoring the desktop layout inside the deck (CMD− shrinks the CSS viewport and would otherwise collapse slides to mobile layouts). See `present-mode.md`.

## Interactive-demo machinery

These surfaces are exempt from the no-boxes rule — they are machinery, not content.

### Animated architecture diagram

Use this for hero sections that show a system with two or more components communicating. Replace the static SVG with a step-through sequence diagram.

1. Draw an SVG with named `<g class="seq-node" id="seqXxx">` groups for each component and `<g id="seqXxxFlow" class="seq-flow">` overlays for each arrow. Base arrows (static, dim) and animated flow overlays (hidden until activated) are separate elements.
2. The hero-grid right column becomes a dynamic annotation panel (`id="seqAnnot"`). On idle it shows the normal prose. On each step it fades to the step title + description.
3. Step dots (`class="seq-dot"`) sit below the SVG. The advance button cycles through steps and resets.

```css
.seq-node { transition: opacity 0.45s ease, filter 0.45s ease; }
#seqSvg.seq-running .seq-node { opacity: 0.12; }
#seqSvg.seq-running .seq-node[data-sl] { opacity: 1; }
[data-sl="accent"]  { filter: drop-shadow(0 0 8px var(--accent));  }
[data-sl="warning"] { filter: drop-shadow(0 0 8px var(--warning)); }
[data-sl="success"] { filter: drop-shadow(0 0 8px var(--success)); }
.seq-flow { opacity: 0; transition: opacity 0.3s ease; pointer-events: none; }
.seq-flow.seq-flowing { opacity: 1; }
@keyframes seqDash { to { stroke-dashoffset: -28; } }
.seq-flowing .seq-dash { animation: seqDash 0.55s linear infinite; }
.seq-dot.sact { background: var(--accent); box-shadow: 0 0 0 3px var(--accent-dim); }
.seq-dot.sdone { background: var(--success); }
```

JS: a `seqSteps[]` array (step label, color `accent|warning|success`, title, desc), parallel `seqNodeMap[]` and `seqFlowMap[]` arrays, and a `showSeq(index)` function that sets `data-sl` on active nodes and `seq-flowing` class on active flows, then fades the annotation panel. `index = -1` resets to idle.

SVG tips: use `class="seq-dash"` on lines inside flow groups; route internal backend connections along the right margin so they don't overlap other boxes; always include base (static, dim) arrows so the diagram is readable before interaction; label nodes with what is *new* there (stores, fields, differentiators), not labels the prose already established. Connector labels that sit on a line need a solid `background: var(--surface)` so the line doesn't slice the text.

Avoid: carousels that hide core info; animations where all nodes pulse at once; interactions that require dragging to understand a discrete state; decorative SVGs that reduce readability; **hover-only or mouse-following tooltips** — anchor the popover to the hovered element (centered, clamped, flipped as needed) and open on hover, click/tap (pinned), and focus; give SVG targets `tabindex="0"` and an `aria-label`, close on Esc and outside-click.

### Cursor timeline (incremental pull visualization)

For incremental sync or stream processing — a horizontal timeline with a draggable needle.

```css
.cursor-stage { border: 1px solid var(--border); border-radius: 16px;
  padding: 32px; background: var(--surface); min-height: 320px; }
.cursor-timeline { display: flex; align-items: center; justify-content: space-between;
  margin: 36px 8px 40px; font-family: var(--mono); font-size: 0.72rem; position: relative; }
.cursor-track { position: absolute; left: 0; right: 0; top: 5px; height: 2px;
  background: var(--border); z-index: 0; }
.cursor-track-pulled { position: absolute; left: 0; top: 5px; height: 2px;
  background: var(--success); z-index: 0; transition: width 0.5s var(--ease-out-expo); width: 0%; }
.cursor-station { display: flex; flex-direction: column; align-items: center; gap: 10px;
  position: relative; z-index: 1; flex-shrink: 0; }
.cursor-station-dot { width: 12px; height: 12px; border-radius: 50%;
  background: var(--border-strong); transition: all 0.5s var(--ease-out-expo); position: relative; }
.cursor-station-dot.pulled { background: var(--success); }
.cursor-station-dot.active { background: var(--accent); box-shadow: 0 0 0 5px var(--accent-dim); }
.cursor-needle { position: absolute; top: -10px; width: 28px; height: 28px; border-radius: 50%;
  background: var(--accent); color: var(--bg); display: grid; place-items: center;
  font-size: 0.65rem; font-weight: 800; box-shadow: 0 0 0 6px var(--accent-dim), 0 4px 16px rgba(0,217,255,0.25);
  transition: left 0.6s var(--ease-out-expo), opacity 0.3s ease; opacity: 0; z-index: 2; pointer-events: none; }
.cursor-needle.visible { opacity: 1; }
.cursor-legend { display: flex; gap: 20px; font-family: var(--mono); font-size: 0.7rem; color: var(--text-dim); }
.cursor-legend span { display: inline-flex; align-items: center; gap: 6px; }
.cursor-legend i { display: inline-block; width: 8px; height: 8px; border-radius: 50%; }
.cursor-panel { margin-top: 28px; min-height: 80px; }
.cursor-panel-line { font-family: var(--mono); font-size: 0.82rem; line-height: 1.7;
  color: var(--text-dim); transition: opacity 0.3s ease, transform 0.3s ease; }
.cursor-panel-line.new { animation: cursorPanelIn 0.4s var(--ease-out-expo) forwards; }
@keyframes cursorPanelIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
```

### Conflict-resolution demo (distributed systems)

A live walkthrough of actors writing conflicting values (e.g. HLC timestamps).

```css
.hlc-stage { border: 1px solid var(--border); border-radius: 16px; padding: 32px; background: var(--surface); }
.hlc-actors { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px; }
.hlc-actor { border: 1px solid var(--border); border-radius: 12px; padding: 20px;
  background: var(--bg); transition: border-color 0.5s var(--ease-out-expo), background 0.5s var(--ease-out-expo), opacity 0.5s ease; }
.hlc-actor.hlc-stored { border-color: color-mix(in srgb, var(--accent) 50%, var(--border)); background: var(--accent-dim); }
.hlc-actor.hlc-winner { border-color: color-mix(in srgb, var(--success) 50%, var(--border)); background: var(--success-dim); }
.hlc-actor.hlc-loser { border-color: color-mix(in srgb, var(--error) 40%, var(--border)); background: var(--error-dim); opacity: 0.55; }
.hlc-actor-name { font-family: var(--mono); font-size: 0.68rem; text-transform: uppercase;
  letter-spacing: 0.1em; color: var(--text-dim); margin-bottom: 10px; }
.hlc-actor-value { font-size: 1.1rem; font-weight: 700; color: var(--text); margin-bottom: 10px; }
.hlc-ts { font-family: var(--mono); font-size: 0.72rem; padding: 8px 12px;
  background: var(--surface); border-radius: 8px; border: 1px solid var(--border); line-height: 1.7; }
.hlc-ts-wall    { color: var(--accent); }
.hlc-ts-counter { color: var(--warning); }
.hlc-ts-actor   { color: var(--success); }
.hlc-server { border: 1px solid var(--border); border-radius: 12px; padding: 20px 24px;
  background: var(--bg); min-height: 100px; font-family: var(--mono);
  font-size: 0.78rem; line-height: 1.8; color: var(--text-dim); }
.hlc-log-line { animation: hlcLogIn 0.3s var(--ease-out-expo); }
@keyframes hlcLogIn { from { opacity: 0; transform: translateX(-8px); } to { opacity: 1; transform: translateX(0); } }
.hlc-verdict { margin-top: 14px; padding: 12px 18px; border-radius: 10px;
  font-family: var(--mono); font-size: 0.78rem; opacity: 0;
  transition: opacity 0.5s ease, transform 0.5s var(--ease-out-expo); transform: translateY(6px); }
.hlc-verdict.visible { opacity: 1; transform: translateY(0); }
.hlc-verdict.good { background: var(--success-dim); border: 1px solid color-mix(in srgb, var(--success) 40%, var(--border)); color: var(--success); }
.hlc-verdict.info { background: var(--accent-dim); border: 1px solid color-mix(in srgb, var(--accent) 40%, var(--border)); color: var(--accent); }
```

### Growth-phase tabs (dynamic payload panels)

For content with multiple phases or versions: a `.rail` of buttons that swap both prose and code panels.

- Render the rail buttons into a container. (`.rail`/`.rail-btn` are boxed *controls* — exempt machinery.)
- Maintain a `phases[]` array with `{label, sublabel, proseHTML, code}`.
- On click, replace the copy and payload content, then run `highlightAll()` on any new code blocks.
- Use `detail-grid` with `grid-template-columns: 0.8fr 1.2fr` when prose is left and code is right.
