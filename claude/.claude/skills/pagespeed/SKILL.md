---
name: pagespeed
description: Run PageSpeed audit against a URL. Requires a URL argument. Use when the user says "pagespeed", "check performance", "audit the blog", "run lighthouse", "test page speed", or wants to catch performance issues.
---

# PageSpeed Audit

Run a performance audit against a given URL using browser metrics. Catches performance and SEO issues.

ARGUMENTS: required URL (e.g. `https://leandronsp.com`). If no argument is provided, **stop and ask the user** for the URL. Never default to localhost or any other URL.

## What to measure

Use `agent-browser` to open the page and extract metrics via JavaScript Performance API. Test both the index page and one article page.

### Step 1: Open and wait for load

```bash
agent-browser open <url>
agent-browser wait --load networkidle
```

### Step 2: Extract Core Web Vitals and page metrics

```bash
agent-browser eval "JSON.stringify({
  // Navigation timing
  timing: (() => {
    const nav = performance.getEntriesByType('navigation')[0];
    return {
      dns: Math.round(nav.domainLookupEnd - nav.domainLookupStart),
      tcp: Math.round(nav.connectEnd - nav.connectStart),
      ttfb: Math.round(nav.responseStart - nav.requestStart),
      domContentLoaded: Math.round(nav.domContentLoadedEventEnd - nav.startTime),
      load: Math.round(nav.loadEventEnd - nav.startTime),
      domInteractive: Math.round(nav.domInteractive - nav.startTime),
      transferSize: nav.transferSize,
      encodedBodySize: nav.encodedBodySize,
      decodedBodySize: nav.decodedBodySize
    };
  })(),
  // Resource counts and sizes
  resources: (() => {
    const entries = performance.getEntriesByType('resource');
    const byType = {};
    entries.forEach(e => {
      const t = e.initiatorType;
      byType[t] = byType[t] || { count: 0, size: 0 };
      byType[t].count++;
      byType[t].size += e.transferSize || 0;
    });
    return { total: entries.length, byType };
  })(),
  // DOM stats
  dom: {
    elements: document.querySelectorAll('*').length,
    images: document.images.length,
    scripts: document.scripts.length,
    stylesheets: document.styleSheets.length,
    externalRequests: performance.getEntriesByType('resource').filter(e => !e.name.includes(location.hostname)).length
  }
})"
```

### Step 3: Check for common issues

Run these checks and flag any that fail:

```bash
# Check: no external fonts (system font stack only)
agent-browser eval "document.querySelectorAll('link[rel=stylesheet][href*=fonts]').length === 0"

# Check: no render-blocking JS
agent-browser eval "document.querySelectorAll('script:not([async]):not([defer]):not([type=\"application/ld+json\"])').length"

# Check: images have dimensions
agent-browser eval "[...document.images].filter(i => !i.width || !i.height).map(i => i.src)"

# Check: meta description exists
agent-browser eval "!!document.querySelector('meta[name=description]')?.content"

# Check: canonical URL exists
agent-browser eval "!!document.querySelector('link[rel=canonical]')?.href"
```

### Step 4: Repeat for one article page

Pick the first article link from the index and run the same checks.

## Thresholds

Flag as issues:

| Metric | Good | Warning | Bad |
|--------|------|---------|-----|
| TTFB | <200ms | 200-600ms | >600ms |
| DOM Content Loaded | <500ms | 500-1500ms | >1500ms |
| Load | <1000ms | 1-3s | >3s |
| DOM elements | <500 | 500-1500 | >1500 |
| Transfer size (page) | <50KB | 50-200KB | >200KB |
| External requests | 0 | 1-3 | >3 |
| Scripts (non-async) | 0 | 1 | >1 |

Note: localhost will be faster than production due to zero network latency. The goal is to catch regressions and obvious issues.

## Output

Present results as a table per page tested:

```
## Index (https://example.com)

| Metric              | Value   | Status |
|---------------------|---------|--------|
| TTFB                | 12ms    | OK     |
| DOM Content Loaded  | 45ms    | OK     |
| Load                | 89ms    | OK     |
| Transfer size       | 62KB    | WARN   |
| DOM elements        | 312     | OK     |
| External requests   | 0       | OK     |
| Render-blocking JS  | 0       | OK     |
| External fonts      | no      | OK     |
| Meta description    | yes     | OK     |
| Canonical URL       | yes     | OK     |

Resources: 3 total (1 img, 1 script, 1 css)
```

End with a summary: PASS (all OK), WARN (some warnings), or FAIL (any bad).
