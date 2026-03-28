---
name: browser
description: Browser automation via agent-browser CLI. Navigate, snapshot, screenshot, click, fill, type, wait, eval, pdf. Use for visual verification, smoke testing, form interaction, and page inspection. Trigger on phrases like "check the browser", "take a screenshot", "test the page", "what does it look like", "verify the UI", "browser test", "open the app".
---

# Browser Automation

Use `agent-browser` CLI for all browser interaction. Run commands via the Bash tool. This is NOT an MCP server.

## Pre-flight

Before testing, determine the app URL and port from project docs (CLAUDE.md, README, docker-compose, etc.). Ensure the app is running.

## Commands

```bash
agent-browser open <url>              # Navigate to URL
agent-browser snapshot                # Accessibility tree with clickable refs
agent-browser screenshot /tmp/ss.png  # Visual capture
agent-browser pdf /tmp/page.pdf       # Save as PDF
agent-browser click "<selector>"      # Click element
agent-browser fill "<selector>" "val" # Set input value directly
agent-browser type "<selector>" "val" # Simulate keystrokes (triggers JS events)
agent-browser hover "<selector>"      # Hover element
agent-browser wait "<selector>"       # Wait for element to appear
agent-browser eval "<js expression>"  # Run JavaScript in page context
```

## Selectors

- CSS: `.my-class`, `#my-id`, `[data-role='save']`
- Text: `button:text('Submit')`
- Ref from snapshot: `@42`
- Combined: `form#login input[name='email']`

## Workflow

1. `open` to navigate
2. `snapshot` to understand page structure (preferred for logic and finding selectors)
3. Interact: click, fill, type
4. `screenshot` to visually verify (preferred for visual checks)
5. Read the screenshot image to confirm

## Login Flows

When the app requires authentication:
1. Read project docs for login URL and credentials
2. `open` the login page
3. `snapshot` to find form fields
4. `fill` email/username and password fields
5. `click` the login/submit button
6. `wait` for redirect to dashboard/home
7. `screenshot` to confirm logged-in state

## Testing Patterns

### Happy path
1. Navigate to the feature
2. Perform the main user flow
3. Verify expected outcome (screenshot + snapshot)

### Forms
1. Fill all required fields
2. Submit
3. Verify success feedback (flash, redirect, new content)
4. Test with empty/invalid input
5. Verify error messages appear

### Edge cases
1. Empty states (no data, empty lists)
2. Long text, special characters, unicode
3. Missing resources (404 pages)
4. Rapid clicks, double submits

### Visual verification
1. Screenshot the page
2. Read the screenshot to check layout, styles, content
3. Check for broken images, misaligned elements, overflow

## Screenshot & Evidence

When validating, capture evidence with descriptive names:
```bash
agent-browser screenshot /tmp/login-success.png
agent-browser screenshot /tmp/form-validation-error.png
agent-browser screenshot /tmp/empty-state.png
```

## Console & Network

```bash
# Check for JS errors
agent-browser eval "window.__errors || 'no error tracking'"

# Check page title
agent-browser eval "document.title"

# Check current URL
agent-browser eval "window.location.href"

# Check element visibility
agent-browser eval "document.querySelector('.flash')?.textContent"
```

## Tips

- Use `snapshot` first to discover clickable elements and their refs
- Use `wait` before interacting with dynamically loaded content (SPAs, LiveView, React)
- Screenshots go to `/tmp/` with descriptive names
- `fill` sets value directly. `type` simulates keystrokes (use for inputs with JS handlers)
- `eval` returns the JS expression result. Use for reading page state, localStorage, cookies
- After form submissions or navigation, `wait` for the expected element before asserting
- When a page has multiple similar elements, use snapshot refs (`@N`) for precision
