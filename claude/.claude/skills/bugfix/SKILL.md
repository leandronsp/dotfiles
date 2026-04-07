---
name: bugfix
description: "Bug hunter. Reproduces bugs with failing tests (RED), then fixes with TDD. Accepts a prompt, issue URL, or bug description. Simpler than /dev, focused solely on fixing bugs. Use when: bugfix, fix bug, debug, broken, regression, failing, doesn't work, something's wrong, fix this."
---

# Bugfix

Bug hunter. Reproduces the bug with a failing test, then fixes it with strict TDD. Focused and surgical — no feature work, just fix and move on.

## Usage

- `/bugfix` — asks what's broken
- `/bugfix <prompt>` — fix from description
- `/bugfix <url>` — fix from GitHub/Linear issue
- `/bugfix <path>` — fix from bug report file

## Workflow

### Phase 1: Understand the Bug

**No arguments:** Ask: "What's broken? Describe the bug, paste an issue URL, or point me to a report."

**Wait for the user's response.**

**Prompt:** Use as bug description.

**URL:** Fetch:
- GitHub: `gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'`
- Linear: `lineark issues read <identifier>`

**File path:** Read the file.

Restate the bug back to the user in your own words:

> My understanding: {what's broken, when it happens, expected vs actual behavior}
>
> Is that right? Anything else I should know?

**Wait.** Confirm understanding before proceeding.

### Phase 2: Scout the Bug

Explore the codebase to understand the area where the bug lives:

- Read the relevant source files
- Read existing tests for that area
- Trace the data/control flow where the bug occurs
- Check git log for recent changes that might have introduced it

Report findings:

> Here's what I found:
>
> - **Where it happens:** {file(s), function(s), line(s)}
> - **Root cause hypothesis:** {what I think is wrong and why}
> - **Existing test coverage:** {what's tested, what's missing}
> - **Recent changes:** {any suspicious recent commits, or "nothing recent"}
>
> Does this match what you're seeing?

**Wait.** The user may have more context.

### Phase 3: Reproduce with a Failing Test

**This is the most important phase. Do not skip. Do not rush.**

The goal: write a test that **fails right now** because of the bug. This test proves the bug exists.

Rules for the reproduction test:
- It must fail for the **right reason** (the actual bug, not a setup error)
- It must be **minimal** — test only the broken behavior, nothing else
- It must describe the **expected** behavior (what should happen when fixed)
- Name it clearly: `test "description of correct behavior that is currently broken"`

> Reproduction test:
>
> ```
> {test_code}
> ```
>
> This proves: {what broken behavior it captures}
> Expected: {what should happen}
> Actual: {what happens now}
>
> Write it?

**Wait.** The user may adjust the test or the approach.

Write the test. Run it. **Confirm RED.**

> 🔴 RED — {error message or assertion failure}
>
> The bug is now captured in a test. Proceeding to fix.

**If the test passes (GREEN unexpectedly):** The test doesn't reproduce the bug. Don't proceed. Investigate:
- Is the test targeting the right scenario?
- Is the bug environment-specific?
- Are we missing a specific input or state?

Adjust and try again. **Persist until you have a failing test.** Ask the user for help if stuck after 3 attempts.

### Phase 4: Fix (GREEN)

Write the **minimum code** to make the failing test pass. No more.

- Don't refactor unrelated code
- Don't add features
- Don't fix other bugs you find (note them for later)
- Stay surgical

Run tests. **Confirm GREEN.**

> 🟢 GREEN — Bug fix verified. {n} tests passing.

If the fix is non-obvious, explain briefly:

> The fix: {one-line explanation of what changed and why}

### Phase 5: Check for Collateral

Run the **full test suite** (not just the new test):

```bash
# Try project test commands
make test 2>/dev/null || mix test 2>/dev/null || cargo test 2>/dev/null || npm test 2>/dev/null
```

If other tests break:
- The fix introduced a regression → adjust the fix
- The other tests were wrong → note it, fix them too with the same RED-GREEN approach

> Full suite: {pass/fail}. {details if any breakage}

### Phase 6: Refactor (if needed)

Only if the fix is ugly or the area needs cleanup:
- Clean up, run tests, confirm GREEN
- Keep it minimal — this is a bugfix, not a rewrite

### Phase 7: Commit

Stage only the changed files. Commit with:

```
fix(<scope>): <what was fixed>
```

If multiple tests were needed (complex bug), that's fine — commit them together as one logical fix.

---

## Multiple Bugs

If the input describes multiple bugs:

1. List them
2. Ask the user which to tackle first
3. Fix one at a time, full cycle each (reproduce → fix → verify)
4. Commit each fix separately

---

## Pairing Modes

By default, bugfix runs in **solo mode** (Phase 3 through 7 autonomously with checkpoints).

The user can request pairing at any point:

- **"you drive"** — Claude writes tests and code, user navigates
- **"I'll drive"** — User writes, Claude navigates (questions, coaches, runs tests)
- **"vibe"** / **"just fix it"** — Claude goes fully autonomous, reports back when done

### Driver Mode (Claude drives)

Same as solo but with checkpoints at every step. Wait for user approval before advancing.

### Navigator Mode (User drives)

Claude's job:
- Suggest what the reproduction test should assert
- Run tests and report RED/GREEN
- Ask questions: "What if the input is nil?" "Does this happen with all users or just some?"
- Point out when a test doesn't actually reproduce the bug
- Never write code unless asked

### Autonomous Mode

Run the full cycle without stopping. Report at the end:

> **Bug fixed.**
>
> - Reproduction test: `{test_file}:{line}`
> - Fix: `{file}:{line}` — {one-line description}
> - Tests: {n} passing, 0 failing
> - Commit: `{commit_hash}`

---

## Iron Rules

1. **No fix without a failing test.** The test must prove the bug exists before you touch production code
2. **Persist on RED.** If you can't reproduce it in a test, dig deeper. Don't skip to the fix
3. **Minimum fix.** Smallest change that makes the test pass. No scope creep
4. **Run full suite.** Fixes must not break other things
5. **One bug at a time.** Don't batch
6. **Ask when stuck.** If you can't reproduce after 3 attempts, ask the user for more context
7. **Note but don't fix** other bugs you discover along the way. Stay focused
