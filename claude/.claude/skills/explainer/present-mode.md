# Present mode (required)

Every explainer ships with a presentation mode: a `▶` button beside the theme toggle (and the `P` key) turns the scroll page into a keyboard-driven slide deck. Use it to walk a room through the explainer without losing any of the page's interactivity.

## How it behaves

- `P` or the `▶` button enters the deck starting at the slide that corresponds to the current scroll position — so you can scroll to any section in narrative mode and press `P` to jump straight into it. `Esc` exits and restores the page exactly (scroll position included). `F` toggles fullscreen.
- `→` / `↓` / `Space` / `PageDown` advance — **fragments first, then the next slide**. `←` / `↑` / `PageUp` go back. `Home` / `End` jump.
- A pill HUD (prev / `n ⁄ N` / next) fades out after 3s idle and wakes on mouse move; a 2px accent progress hairline sits at the bottom.
- Slides **adopt the live DOM nodes** declared in their manifest and give them back on exit. Steppers, rails, play buttons, and theme toggling all keep working inside a slide — never duplicate content into the deck.
- An auto-fit pass scales each slide's stage down (never up) to fit the viewport. Below a `0.6` floor the text stops being projectable, so the slide instead keeps the floor scale, anchors to the top, and **scrolls vertically** — that is the escape hatch for one tall artifact, not licence to cram a section.

## Composing the slide manifest

The deck is declared as `initPresent([...])` at the end of the page script — one object per slide. **Never map sections to slides 1:1.** Recompose:

- A short section (heading + one artifact) → adopt the whole `<section>`; the editorial two-column layout and section number carry over.
- A long section → split it across slides. Add `id`s at the split points in the HTML, give later slides a synthesized `kicker` (e.g. `'04 · Preparing for X'`) and optional `title` so the chapter context survives the split.
- An interactive widget → its own slide, with a `steps` driver so arrow keys play it.
- A widget plus its full section heading is usually too tall — adopt only the widget (e.g. `'#walkthrough .stepper'`) and synthesize the title.
- Budget each slide to render at scale ≥ 0.75 on a 1600×900 window. Widgets that measure pixels at runtime (e.g. a needle positioned via `getBoundingClientRect`) misalign under scaling — keep those slides light enough to render at scale 1.
- **Stepper steps set the scale budget, not the section.** When `clickSteps` drives a stepper, `fit()` measures the stage *after each step is rendered*. If one step is too tall (a diagram + long code block + prose in one step), the slide scales below the floor and becomes unreadable. The fix is to split that step in the `steps` data array — you cannot target an individual step state from `pick`, so the split must happen in the data.
- **Rail-tab steps with varying content heights will rescale the slide on every click.** When a `clickSteps`-driven slide renders different amounts of content per tab (2 rows vs 9 rows), each step change triggers `refit()` with a new `offsetHeight`, causing the whole slide to rescale and font size to shift. Fix: pre-measure the worst-case height across all steps on first slide entry and cache it on the slide object (`s._maxH`), so `fit()` always uses the same reference height. The resize handler should clear `_maxH` so it remeasures for the new viewport. Additionally: (1) suppress row animations inside `.pr-stage` (`.pr-stage .afile { animation: none !important }`) so tab switches are instant; (2) do not call `refit()` in `next()`/`prev()` for `_maxH`-stabilised slides; (3) if the content area changes height between tabs, pin it with `.pr-stage .my-container { min-height: Xpx; align-content: start }`.
- **Steppers with genuinely variable-height steps** (prose + code that grows and shrinks per step) need a different strategy. Adding `minScale: 0.85` to the slide object tells `fit()` to floor the scale at 0.85 for that slide specifically — font size never changes between steps, and when a step is too tall the whole slide scrolls (`pr-scroll`) at that scale instead of shrinking the text. `refit()` is called on each step advance for `minScale` slides so `marginBottom` stays correct. Slides without `minScale` continue to use `_maxH` with the global `MIN_SCALE` floor.

Slide object fields:

| Field | Meaning |
|---|---|
| `pick` | Array of selectors; each first match is adopted into the slide, in order. |
| `kicker` / `title` | Synthesized header for slides cut out of a larger section. |
| `layout` | `'wide'` (1320px stage — screenshots), `'diagram'` (`.arch-svg` fills the stage). Default stage is 1100px. |
| `steps` | `{ count, go(i) }` fragment driver. `go(0)` is the slide's entry state; entering backward applies `go(count - 1)`. |
| `minScale` | Number (e.g. `0.85`). Floors the scale at this value for this slide; the slide scrolls rather than shrinking text. Use for steppers with variable-height step content. |

Three ways to drive fragments:

```js
// 1. Walk existing tabs/dots — one press per button
{ pick: ['#shape'], steps: clickSteps('#rail .rail-btn') }

// 2. Reveal items one by one (adds .pr-frag / .pr-on)
{ pick: ['#problem'], steps: fragSteps('#problem .mini-list > li') }

// 3. Call page functions directly (same script scope)
{ pick: ['#heroDiagram'], layout: 'diagram',
  steps: { count: 8, go: (i) => showSeq(i - 1) } } // step 0 = idle state
```

## Markup

Add the toggle right after the theme toggle:

```html
<button class="present-toggle" id="presentToggle" type="button" aria-label="Present (P)" title="Present (P)">▶</button>
```

## CSS (paste as-is)

```css
/* ── Present mode ── */
.present-toggle{position:fixed;top:24px;right:80px;z-index:100;width:44px;height:44px;border:1px solid var(--border);border-radius:50%;background:var(--surface);color:var(--text-dim);cursor:pointer;display:grid;place-items:center;transition:all .4s var(--ease-out-expo);font-size:14px}
.present-toggle:hover{border-color:var(--accent);color:var(--accent);transform:scale(1.1)}
body.presenting{overflow:hidden}
body.presenting .theme-toggle,body.presenting .present-toggle{z-index:300}
.pr-deck{position:fixed;inset:0;z-index:200;background:var(--bg);display:none;outline:none}
.pr-deck::before{content:'';position:absolute;top:-220px;right:-220px;width:600px;height:600px;border-radius:50%;background:radial-gradient(circle,var(--accent-dim),transparent 70%);opacity:.25;pointer-events:none}
body.presenting .pr-deck{display:block}
.pr-slide{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;padding:56px 48px 96px;opacity:0;visibility:hidden;transition:opacity .45s var(--ease-out-expo),visibility 0s linear .45s}
.pr-slide.active{opacity:1;visibility:visible;transition:opacity .45s var(--ease-out-expo) .05s,visibility 0s}
.pr-stage{width:min(1100px,94vw);transform-origin:center center}
.pr-slide.pr-scroll{align-items:flex-start;overflow-y:auto}
.pr-slide[data-layout="wide"] .pr-stage{width:min(1320px,96vw)}
.pr-slide[data-layout="diagram"] .arch-svg{max-width:100%}
.pr-stage>*+*{margin-top:28px!important}
.pr-stage>:first-child{margin-top:0!important}
.pr-stage>.pr-title{margin-top:14px!important}
.pr-stage section{padding:0!important}
.pr-stage section::before{display:none!important}
.pr-stage .hero{min-height:0!important;padding-bottom:0!important}
.pr-kicker{font-family:var(--mono);font-size:.7rem;letter-spacing:.18em;text-transform:uppercase;color:var(--text-dim);display:flex;align-items:center;gap:12px}
.pr-kicker::before{content:'';width:40px;height:1px;background:var(--accent)}
.pr-title{font-size:clamp(1.6rem,3vw,2.6rem);font-weight:700;letter-spacing:-0.02em}
.pr-hud{position:fixed;left:50%;bottom:28px;transform:translateX(-50%);z-index:300;display:none;align-items:center;gap:4px;padding:6px;border:1px solid var(--border);border-radius:100px;background:color-mix(in srgb,var(--surface) 88%,transparent);backdrop-filter:blur(12px);transition:opacity .4s ease}
body.presenting .pr-hud{display:flex}
.pr-hud.idle{opacity:0;pointer-events:none}
.pr-hud button{appearance:none;border:0;background:transparent;color:var(--text-dim);width:36px;height:36px;border-radius:50%;cursor:pointer;font-size:.95rem;display:grid;place-items:center;transition:all .3s var(--ease-out-expo)}
.pr-hud button:hover:not(:disabled){background:var(--accent-dim);color:var(--accent)}
.pr-hud button:disabled{opacity:.3;cursor:default}
.pr-count{font-family:var(--mono);font-size:.72rem;color:var(--text-dim);padding:0 10px;min-width:64px;text-align:center}
.pr-progress{position:fixed;left:0;bottom:0;height:2px;width:100%;z-index:300;display:none;background:color-mix(in srgb,var(--border) 60%,transparent)}
body.presenting .pr-progress{display:block}
.pr-progress i{display:block;height:100%;width:0;background:linear-gradient(90deg,var(--accent-dim),var(--accent));transition:width .45s var(--ease-out-expo)}
.pr-deck .pr-frag{opacity:0;transform:translateY(14px);transition:opacity .5s var(--ease-out-expo),transform .5s var(--ease-out-expo)}
.pr-deck .pr-frag.pr-on{opacity:1;transform:none}
@media(max-width:900px){.present-toggle{display:none}}
/* Restore desktop layouts inside the deck at any browser zoom level.
   CMD+/CMD- shrinks the CSS viewport and triggers responsive breakpoints,
   collapsing grids to single-column. These overrides defeat that.
   Add one line per multi-column device the page actually uses. */
.pr-stage .hero-grid{grid-template-columns:1fr minmax(300px,0.46fr)}
.pr-stage .pair-grid,.pr-stage .compare-grid{grid-template-columns:1fr 1fr}
.pr-stage .inspect-grid{grid-template-columns:minmax(0,1fr) minmax(280px,.8fr)}
.pr-stage .pyr-grid{grid-template-columns:minmax(0,1.1fr) minmax(250px,.9fr)}
.pr-stage .maturity-grid{grid-template-columns:minmax(0,.9fr) 1fr}
.pr-stage .loop-track{flex-direction:row}
.pr-stage .artifact{margin-top:28px!important}
```

## JS kit (paste at the end of the page script, then call `initPresent`)

```js
/* ── Present mode ── */
function fragSteps(selector){
  var items = Array.prototype.slice.call(document.querySelectorAll(selector));
  items.forEach(function(el){ el.classList.add('pr-frag'); });
  return {
    count: items.length + 1,
    go: function(i){ items.forEach(function(el, k){ el.classList.toggle('pr-on', k < i); }); }
  };
}
function clickSteps(selector){
  var count = document.querySelectorAll(selector).length;
  return {
    count: count,
    go: function(i){ var b = document.querySelectorAll(selector)[i]; if(b) b.click(); }
  };
}
function initPresent(slides){
  var btn = document.getElementById('presentToggle');
  if(!btn) return;
  var deck = null, hud, countEl, barEl, prevBtn, nextBtn;
  var adopted = [], cur = 0, step = 0, savedScroll = 0, hudTimer = null;

  function stepCount(s){ return s.steps ? s.steps.count : 1; }
  function presenting(){ return document.body.classList.contains('presenting'); }

  function build(){
    deck = document.createElement('div');
    deck.className = 'pr-deck'; deck.tabIndex = -1;
    deck.setAttribute('role', 'region'); deck.setAttribute('aria-label', 'Presentation');
    slides.forEach(function(s){
      var sl = document.createElement('section');
      sl.className = 'pr-slide';
      if(s.layout) sl.dataset.layout = s.layout;
      var stage = document.createElement('div');
      stage.className = 'pr-stage';
      if(s.kicker){ var k = document.createElement('div'); k.className = 'pr-kicker'; k.textContent = s.kicker; stage.appendChild(k); }
      if(s.title){ var t = document.createElement('h2'); t.className = 'pr-title'; t.textContent = s.title; stage.appendChild(t); }
      sl.appendChild(stage);
      deck.appendChild(sl);
      s._slide = sl; s._stage = stage;
    });
    hud = document.createElement('div'); hud.className = 'pr-hud';
    prevBtn = hudButton('←', 'Previous'); nextBtn = hudButton('→', 'Next');
    countEl = document.createElement('span'); countEl.className = 'pr-count';
    hud.appendChild(prevBtn); hud.appendChild(countEl); hud.appendChild(nextBtn);
    barEl = document.createElement('div'); barEl.className = 'pr-progress';
    barEl.appendChild(document.createElement('i'));
    document.body.appendChild(deck);
    document.body.appendChild(hud);
    document.body.appendChild(barEl);
    prevBtn.addEventListener('click', prev);
    nextBtn.addEventListener('click', next);
  }
  function hudButton(label, name){
    var b = document.createElement('button');
    b.type = 'button'; b.textContent = label; b.setAttribute('aria-label', name);
    return b;
  }

  function adopt(){
    slides.forEach(function(s){
      (s.pick || []).forEach(function(sel){
        var node = document.querySelector(sel);
        if(!node) return;
        adopted.push({ el: node, parent: node.parentNode, next: node.nextSibling });
        s._stage.appendChild(node);
        if(node.classList.contains('reveal')) node.classList.add('in', 'is-visible');
        node.querySelectorAll('.reveal').forEach(function(r){ r.classList.add('in', 'is-visible'); });
      });
    });
  }
  function restore(){
    for(var i = adopted.length - 1; i >= 0; i--){
      adopted[i].parent.insertBefore(adopted[i].el, adopted[i].next);
    }
    adopted = [];
  }

  // Scale the stage down (never up) so adopted content always fits the viewport.
  // Below MIN_SCALE text stops being readable from the back of a room, so
  // tall content keeps the floor scale and the slide scrolls vertically instead.
  var MIN_SCALE = 0.6;
  function fit(s){
    var availW = s._slide.clientWidth - 96;
    var availH = s._slide.clientHeight - 152;
    var scale = Math.min(1, availW / s._stage.offsetWidth, availH / s._stage.offsetHeight);
    var scrolls = scale < MIN_SCALE;
    if(scrolls) scale = MIN_SCALE;
    s._slide.classList.toggle('pr-scroll', scrolls);
    s._stage.style.transformOrigin = scrolls ? 'top center' : 'center center';
    // transform does not shrink the layout box — collapse the leftover so
    // the scroll height matches what is visually there.
    s._stage.style.marginBottom = scrolls ? (-(1 - scale) * s._stage.offsetHeight) + 'px' : '';
    s._stage.style.transform = scale < 1 ? 'scale(' + scale + ')' : 'none';
  }
  function refit(){
    var s = slides[cur];
    requestAnimationFrame(function(){ fit(s); s._slide.scrollTop = 0; });
  }

  function syncHud(){
    var s = slides[cur];
    countEl.textContent = (cur + 1) + ' / ' + slides.length;
    barEl.firstChild.style.width = (((cur + 1) / slides.length) * 100) + '%';
    prevBtn.disabled = cur === 0 && step === 0;
    nextBtn.disabled = cur === slides.length - 1 && step === stepCount(s) - 1;
  }
  function show(i, dir){
    cur = i;
    var s = slides[i];
    slides.forEach(function(o, j){
      o._slide.classList.toggle('active', j === i);
      o._slide.setAttribute('aria-hidden', j === i ? 'false' : 'true');
    });
    step = dir < 0 ? stepCount(s) - 1 : 0;
    if(s.steps) s.steps.go(step);
    syncHud();
    refit();
  }
  function next(){
    var s = slides[cur];
    if(s.steps && step < s.steps.count - 1){ step++; s.steps.go(step); syncHud(); refit(); }
    else if(cur < slides.length - 1){ show(cur + 1, 1); }
  }
  function prev(){
    var s = slides[cur];
    if(s.steps && step > 0){ step--; s.steps.go(step); syncHud(); refit(); }
    else if(cur > 0){ show(cur - 1, -1); }
  }

  function enter(){
    if(!deck) build();
    savedScroll = window.scrollY;
    adopt();
    document.body.classList.add('presenting');
    btn.textContent = '✕'; btn.setAttribute('aria-label', 'Exit presentation (Esc)');
    show(0, 1);
    deck.focus();
    wakeHud();
  }
  function exit(){
    document.body.classList.remove('presenting');
    btn.textContent = '▶'; btn.setAttribute('aria-label', 'Present (P)');
    slides.forEach(function(s){ s._slide.classList.remove('active'); });
    restore();
    window.scrollTo(0, savedScroll);
  }
  function toggle(){ if(presenting()){ exit(); } else { enter(); } }

  function wakeHud(){
    if(!hud) return;
    hud.classList.remove('idle');
    clearTimeout(hudTimer);
    hudTimer = setTimeout(function(){ hud.classList.add('idle'); }, 3000);
  }

  btn.addEventListener('click', toggle);
  window.addEventListener('resize', function(){ if(presenting()) refit(); });
  window.addEventListener('mousemove', function(){ if(presenting()) wakeHud(); });
  window.addEventListener('keydown', function(e){
    var t = e.target;
    if(t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.isContentEditable)) return;
    if(!presenting()){
      if(e.key === 'p' || e.key === 'P'){ toggle(); e.preventDefault(); }
      return;
    }
    switch(e.key){
      case 'ArrowRight': case 'ArrowDown': case ' ': case 'PageDown': next(); e.preventDefault(); break;
      case 'ArrowLeft': case 'ArrowUp': case 'PageUp': prev(); e.preventDefault(); break;
      case 'Home': show(0, 1); e.preventDefault(); break;
      case 'End': show(slides.length - 1, 1); e.preventDefault(); break;
      case 'Escape': exit(); break;
      case 'f': case 'F':
        if(document.fullscreenElement){ document.exitFullscreen(); }
        else if(document.documentElement.requestFullscreen){ document.documentElement.requestFullscreen(); }
        break;
      case 'p': case 'P': toggle(); break;
    }
  });
}
```

## Worked manifest

```js
// Slide manifest — recomposes the page; never a blind section-per-slide map.
initPresent([
  { pick: ['#top'] },                                                  // hero = title slide
  { pick: ['#problem'], steps: fragSteps('#problem .mini-list > li') },// reveal pains one by one
  { pick: ['#rule'], steps: fragSteps('#rule tbody tr') },             // table rows as fragments
  { pick: ['#shape'], steps: clickSteps('#rail .rail-btn') },          // arrows walk the rail tabs
  { kicker: '04 · Preparing for X', pick: ['#boundaryHead', '#boundaryLede', '#bdDiagram'] },
  { kicker: '04 · Preparing for X', title: 'The boundary, in code', pick: ['#authzCode'] },
  { kicker: '05 · Walkthrough', title: 'Adding an entity, step by step',
    pick: ['#walkthrough .stepper'], steps: clickSteps('#entDots .step-dot') },
  // …
]);
```
