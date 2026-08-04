---
name: smoke
description: Discovery before building. Reproduce and observe real behavior, collect evidence, close a mini bag of 1-3 small issues. Use when the ask is fuzzy: a vague bug, "is this at parity?", a feature idea, "migrate X". Feeds /step or /pair, which ride the bag.
---

# Smoke

Lean method: observe real behavior → evidence → small bag → ride. Smoke is the first half.
/step (agent drives) or /pair (the human drives) rides the bag. The bag closes, the human picks.
Never both halves in one breath.

## Loop

1. **Pick the smallest slice** of the fuzzy thing: one field, one screen, one endpoint, one flow.
2. **Establish the source of truth.** Parity: the reference implementation. Bug: the reproduction.
   New feature: current behavior plus the human's stated expectation.
3. **Smoke it for real.** Drive the running app (browser, CLI, API). Click everything in the
   slice, both sides when comparing. Capture evidence: screenshots, log lines, data checks.
   When the UI is ambiguous, verify against the data layer before claiming anything.
4. **Report.** Behavior/parity table plus gaps, severity-ordered. Each gap: actual vs expected,
   with its evidence. The report is the deliverable of this phase, not a plan.
5. **Close the bag.** 1-3 issues, each one deliverable (one PR), shaped from evidence with
   scenario ACs (Actual/Expected). Use the project's issue skill or tracker conventions if one
   exists; otherwise write `.smoke/<slug>.md` in the project root. Stop. The human picks.

## Rules

- Evidence over reading code. Code explains; the running app decides.
- A gap without a reproduction is a hypothesis. Label it as such.
- A finding that becomes a fix carries its reproduction into an automated test during the ride,
  in whatever test layer the stack uses. Smoke never writes the test; it hands the reproduction.
- The bag never extends beyond the next slice or two. No roadmaps, no backlog farming.
- Destructive smoke actions use throwaway data you created; leave found data alone.
- Record automation gotchas discovered while driving the app (frames, selectors, dialogs) in the
  report so the ride replays the reproduction cheaply.
