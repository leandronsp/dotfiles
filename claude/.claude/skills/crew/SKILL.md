---
name: crew
description: "Team-lead orchestration of a multi-unit goal with PERSISTENT agents — spawn one agent per track, keep it alive across units, talk to it by message instead of re-briefing from scratch. Wrapper over the /goal stop-hook: crew is the engine, /goal is the safety net. Use when the user says: crew, run this goal, roda o goal, orquestra isso, sai do loop, trabalha autônomo a noite, agentes persistentes, or hands over a contract of several units to execute without check-ins. NOT for in-loop work — that is /smoke, /step, /walk, /commit."
---

# Crew

You are the team lead of a small persistent crew. The user leaves the loop; you run the goal
end to end and they read one honest report when they return. The whole design fights two
failure modes measured in practice: **cold-start waste** (a fresh agent re-reading the corpus
costs ~10-15 min per unit, 25-30% of its time) and **doc slop** (specs that repeat what code
already says, flooding every agent's context).

`/goal` itself is only a session stop-hook: it blocks the session from ending until a condition
holds. It has no orchestration. Crew IS the orchestration; suggest the user set
`/goal <one-line condition>` before leaving as the safety net, and rely on background waiters
to keep the loop moving.

## State — three lean files, nothing else

- **Contract** (`docs/design/<goal>.md`, ~40 lines): decisions, units per track, the
  do-not-absorb list. Executed units collapse to one line each. If the project has no docs
  convention, create just this file.
- **Log** (`docs/progress/GOAL.md`, append-only): one entry per unit, ≤35 lines — what changed
  (before→then with measured numbers), decisions with the why, findings, suite count, commit
  hash. The log entry is the spec of what the unit built.
- **Conventions** (`docs/HANDOFF.md` or CLAUDE.md): non-negotiables and known pitfalls. Append
  new pitfalls the moment a unit trips one.

**Code + log = spec.** When a spec paragraph becomes code, delete the paragraph. Never ask an
agent to "read everything" — point at named entries.

## The crew — persistent, one per track

Split the goal into **tracks** by bounded context / phase (units inside a track depend on each
other; tracks barely touch). v1 runs tracks **sequentially** on the shared tree — parallel
worktrees need per-track databases and an integration lane; that is a v2 with its infra built
first, not an improvisation.

Spawn ONE named agent per track (`Agent` tool with `name:`, model per project convention).
First message is the only rich brief (~40 lines): mission, the 5-10 facts it needs inline,
pointers to specific log entries, the conventions file, the unit list, and its commit-phrase
protocol. Every next unit is a **delta message** via `SendMessage`: "unit N: <5 lines of new
facts + what to build + the exact commit phrase>". The agent already knows the codebase — that
is the point of keeping it alive.

**Recycle the agent** (finish it, spawn fresh) only when: (a) the track changes bounded
context; (b) its context degrades — it forgets conventions, re-asks answered questions, or
quality drops; (c) you need fresh eyes: an agent that wrote the code will not find its own
stale assumptions. On recycle, the log entries are the handoff — that is why they exist.

**Recycle patience, learned the hard way:** an agent can read and plan for 10-15 minutes
before its first write, and a productive agent may never answer messages at all — silence is
not death. Before recycling, probe for a heartbeat (fresh mtimes/untracked files) at least
twice, ~10 minutes apart. If you do spawn a replacement, its brief must say the predecessor
may still be alive and to STOP and report if the tree shows a concurrent writer — that one
clause is what turns a double-spawn from a corrupted tree into a clean handback. And on any
ownership change, message BOTH agents — the one gaining the tree and the one losing it: a
late-waking predecessor that still believes it owns the track is the same collision, inverted.

## The loop, per unit

1. **Dispatch** the delta message with a unique commit phrase (never reusable in docs commits).
2. **Arm a waiter**: background `until git log --oneline -1 | grep -q "<phrase>"; do sleep 30;
   done`. The waiter re-invokes you when the unit lands; never poll by hand.
3. **Verify with your own measurement** when it lands — you are the lead, not a relay:
   read the log entry, run your own queries/curl against the claims, eyeball one screenshot.
   Numbers that do not match send a correction message to the same agent, not a new spawn.
4. **Accept**: note findings that change later units; carry them into the next delta message.
5. Repeat. Between units, fix small cross-unit defects inline yourself (RED first) instead of
   burning an agent on a one-clause change. But the commit phrase signals the UNIT landing,
   not the agent's disengagement — an agent often keeps working after it (an extra test, the
   evidence commit). Open your window only after the agent goes idle, or announce the window
   to it first; otherwise you are the concurrent writer its brief tells it to stop for.

## Budgets — quality is the gate, slop is not

- RED proof on **structural points only** (≤5 per unit), not an exhaustive sweep per branch.
- Full check/lint gate **once** per unit, before its commit. Scoped tests during work.
- Log entry ≤35 lines. Browser evidence at **phase gates**, not every unit.
- Unit sized to ~30 min of agent work. A unit trending past double that is mis-scoped: stop it,
  split it, message the halves.
- Decisions the user must make: apply the stated default, label it in the log, stack it for the
  morning report. Never block the night on a question; never bury a decision either.

## Closing

When the last unit lands: final phase-gate verification (full check + browser evidence +
console conference), then the report the user wakes up to — per phase, before→then with
measured numbers, the decision stack with defaults taken, and what is deliberately open.
Update the conventions file's state section. Hand back to in-loop work: from here it is
/smoke, /step, /walk, /commit again.
