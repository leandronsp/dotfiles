---
name: cuke
description: "Run Cucumber scenarios with the right env vars and browser versions, then summarize the result. Handles FullFabric worktree env (COMPOSE_PROJECT_NAME, MONGO_TARGET, BUNDLE_GEMFILE) and Playwright browser drift. Use when: cuke, run cucumber, cucumber, run feature, run scenario, repro cucumber, cuke this, features/foo.feature."
---

# Cuke

Run a Cucumber scenario with the right env vars and Playwright browser. Report pass/fail with a short diagnosis on failure.

## Usage

- `/cuke` — ask which feature/scenario to run
- `/cuke <feature>` — run the whole file
- `/cuke <feature>:<line>` — run one scenario
- `/cuke <feature>:<line> --debug` — also dump the rendered HTML on failure to `/tmp/cuke_debug.html`

## Phase 1: Resolve target

If no argument: ask the user. Wait.

If the argument is a `.feature` path (with or without `:LINE`), proceed.

If the argument is a description ("the AI agents scoring scenarios"), grep `features/` for a matching `Scenario:` or `Feature:` line and confirm with the user before running.

## Phase 2: Detect environment

Run these in parallel:

```bash
git rev-parse --show-toplevel
ls GemfileCucumber 2>/dev/null
ls .worktrees 2>/dev/null || git rev-parse --git-dir
```

**FullFabric detection**: project has `GemfileCucumber`. If the working dir is under `.worktrees/`, the worktree env is required.

Set env vars:

| Var                       | When                                       | Value             |
| ------------------------- | ------------------------------------------ | ----------------- |
| `BUNDLE_GEMFILE`          | `GemfileCucumber` exists                   | `GemfileCucumber` |
| `COMPOSE_PROJECT_NAME`    | inside `.worktrees/` and main repo uses docker | `fullfabric`  |
| `MONGO_TARGET`            | inside `.worktrees/`                       | `docker compose`  |

If outside FullFabric: just `bundle exec cucumber` with whatever Gemfile is active. No special env.

## Phase 3: Verify Playwright browser (FullFabric)

The bundled `playwright` gem pins a specific Chromium revision. `bundle exec playwright install` sometimes fetches the wrong version. Symptom: scenario fails immediately with `browserType.launch: Executable doesn't exist`.

Check once before the first run:

```bash
ls ~/Library/Caches/ms-playwright/ 2>/dev/null | head -5
```

If the run fails on browser launch, fix with:

```bash
npx playwright install chromium-headless-shell
```

Do **not** run `bundle exec playwright install` — it has the version-drift bug.

## Phase 4: Run

```bash
<env vars> bundle exec cucumber <feature>:<line>
```

Stream output. If passing → done, one-line summary:

> ✓ N scenarios passing (Ms)

## Phase 5: Diagnose failures

If a scenario fails, classify before suggesting a fix. Common patterns:

### `Capybara::ElementNotFound`

The element is not on the page (or not yet). Three sub-causes:

1. **Marionette SPA needs hash fragment.** Pages like `/applications/templates/:id/applications` need `#:id` for the SPA router to load the resource. Symptom: page title is correct, but content region is empty (`<actions></actions><section></section>`). Fix: append `#:id` to the visit URL.
2. **Element renders after async cascade.** Use `expect(page).to have_css(selector)` (Capybara waits) before `find(selector).click`. Pattern in this codebase: `page.should have_css("#filters-and-actions-region #actions-region #...-dropdown #...-btn")` before clicking.
3. **Permission or feature flag missing.** The page renders chrome but content stays empty because the controller skipped data injection. Check both sides: user-level `Authorization::Role` feature AND the module/setting flag. The cucumber step `the "X" module is enabled` only enables the module; for feature flags use `the "Y" feature in the "X" module is enabled` (sets `modules.X.features.Y.enable`).

### Text matcher fails on visible-looking element

Symptom: `expected to find css "th" with text "Foo Score" but there were no matches. Also found "FOO SCORE SCO...".`

Cause: CSS `text-transform: uppercase` + `text-overflow: ellipsis` makes the visible text differ from the source. Capybara's `text:` filter matches *visible* text.

Fix: switch to a stable attribute selector (e.g. `data-column`, `data-testid`) instead of matching by text.

### Browser launch fails

See Phase 3. Run `npx playwright install chromium-headless-shell`.

### Database / connection errors

Usually means docker services aren't up. Check `docker ps | grep fullfabric`. Don't `mkdir`, `brew install`, or start local DBs — everything runs in docker.

## Debugging tactics

When you need to see what the page actually rendered before clicking, drop this into the step temporarily:

```ruby
File.write("/tmp/cuke_debug.html", page.evaluate_script("document.body.innerHTML"))
puts "==== URL: #{page.current_url} LEN: #{File.size('/tmp/cuke_debug.html')}"
```

Then `cat /tmp/cuke_debug.html | head -60` after the run. Remove the probe before committing.

`page.body` may return an early snapshot under the Playwright driver; `evaluate_script("document.body.innerHTML")` returns the live DOM.

## Iron rules

1. **Never commit cucumber changes without seeing the scenario pass locally.** CI is not the verification step.
2. **Never dismiss a CI failure as flake without local repro on the same branch.** Pull, run the scenario, then decide.
3. **No `mkdir`, no local DBs.** All services run in docker. If something looks missing, check `docker ps`.
4. **Strip debug probes** (`puts`, `File.write`, `sleep`) before committing.
