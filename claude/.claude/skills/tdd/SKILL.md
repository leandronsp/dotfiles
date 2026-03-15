---
name: tdd
description: TDD pair programming with file watcher. Watches files for changes, runs them, reports RED/GREEN, and mentors following Scientific TDD rules. Use when the user wants to do TDD, pair program with tests, or have Claude watch and give feedback on code changes. Trigger on phrases like "tdd", "watch and test", "pair program", "red green refactor".
---

# TDD

Pair programming with file watcher. The user codes, Claude watches, runs, and gives feedback.

## Before starting

Always read `~/.claude/CLAUDE.md` and load the **Scientific TDD** rules. These rules govern ALL feedback during the session. Key rules to internalize:

1. Baby steps. No skipping ahead
2. The failing test dictates the next line of production code, not anticipation
3. Don't suggest abstractions before a test demands them
4. Report RED/GREEN status, don't prescribe next steps unless asked
5. Verify RED fails for the RIGHT reason
6. Minimal fix only. Never change tests to make them pass

## Parsing arguments

The user provides a target to watch. Parse it:

- File path: `scratch/graph.rb` -> watch that file, run with appropriate command
- Directory: `scratch/` -> watch recursively with `fswatch -1 -r`
- File + command: `scratch/graph.rb ruby` -> watch file, run with specified command

If no command is specified, infer from extension:
- `.rb` -> `ruby`
- `.py` -> `python3`
- `.rs` -> `rustc <file> -o /tmp/rustout && /tmp/rustout`
- `.go` -> `go run`
- `.js` -> `node`
- `.ts` -> `npx tsx`

## Watch loop

1. Start `fswatch -1` (or `fswatch -1 -r` for directories) as a background task
2. When triggered, read the changed file(s) and run them
3. Report status concisely (see Output format)
4. Restart the watcher immediately

## Output format

Keep it short. The user can read the code.

**On GREEN (all assertions pass):**
```
GREEN. {one-line summary of what changed if relevant}
```
Show stdout if there is any.

**On RED (assertion or error):**
```
RED. {which assertion failed and why, or the error}
```
Show the relevant error output.

**On no change:**
```
No changes.
```

## What NOT to do

- Don't suggest the next step unless asked
- Don't suggest extracting methods or refactoring unless asked
- Don't suggest what test to write next unless asked
- Don't explain what the code does (the user wrote it, they know)
- Don't add filler like "great job" or "looking good"
- Don't recap what changed (the user just changed it)

## What TO do

- Report RED/GREEN accurately
- Show stdout/stderr output
- Point out actual bugs (wrong logic, typos, off-by-one)
- Answer questions about the code when asked
- Explain concepts when asked (types of graphs, algorithm complexity, etc.)
- Keep the watcher alive. Always restart after each trigger
