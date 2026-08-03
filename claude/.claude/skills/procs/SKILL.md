---
name: procs
description: "Run and manage long-lived project processes (rails/puma, npm, mix phx.server, cargo run, docker compose, workers) in tu virtual terminals so the human and the agent watch the same screen. Use when: start the server, run the app locally, boot the stack, restart the backend, is it still running, why did it crash, show me the server log, stop the server, kill the process, tail the output."
---

# Long-lived processes in `tu`

`tu` ("terminal-use") is a headless virtual terminal with a background daemon. A process
started with `tu run` outlives the shell that spawned it, keeps a real PTY (so colors,
progress bars and readline prompts behave), and can be read back at any time with
`tu screenshot`. That is what makes it the right home for dev servers.

**Why this over `Bash(run_in_background)`:** a backgrounded Bash command writes to a file
only the agent reads, and the human has nothing to look at. A `tu` session is one screen
with a name, and `tu monitor --name backend` in the human's own terminal shows that exact
screen live. Same buffer, same scrollback, same crash. One source of truth, two viewers.

Everything below runs through the Bash tool. Output is JSON whenever stdout is not a TTY,
which is always the case for the agent.

## The loop

```
run  ->  wait for the readiness line  ->  work  ->  screenshot on trouble  ->  kill
```

Never report a server as "started" on the strength of `tu run` returning. `tu run` returns
the instant the process is spawned, long before it is listening. The readiness gate is
`tu wait`, and for a server the honest confirmation is the port.

## Commands

```bash
tu run --name <id> [--cwd <dir>] [--env K=V] [--size 200x50] -- <cmd> [args]
tu run --name <id> --shell 'cd x && FOO=1 exec ./bin/server'   # compound/env/glob
tu list                                    # [{name,pid,alive,exit_code,size}]
tu status --name <id>                      # same shape, one session; errors if unknown
tu screenshot --name <id>                  # {content, cursor, cols, rows}
tu scrollback --name <id> --lines 200      # {content} — history that scrolled off
tu wait --name <id> --text <regex> --timeout <ms>   # exit 0 match, exit 1 timeout
tu wait --name <id> --stable 1500                   # screen quiet for N ms
tu press --name <id> Ctrl+C                # signal the foreground process
tu kill --name <id>                        # kill process, drop session
tu monitor --name <id>                     # live view — this is the human's command
```

Read a screen as text:

```bash
tu screenshot --name backend | python3 -c "import sys,json;print(json.load(sys.stdin)['content'])"
```

## Naming is the interface

One process, one stable name, lowercase, the role not the command: `backend`, `frontend`,
`worker`, `db`, `test`. The human types `tu monitor --name backend`
without asking what you called it. Never `default`, never a name with a timestamp or a
branch in it, and never two names for the same role across a session.

## Starting a server

```bash
tu run --name backend --cwd /path/to/repo --env "PORT=3000" -- bin/server

tu wait --name backend --text "Listening on|Puma starting|localhost:3000" --timeout 90000
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/ || true
```

Rules that keep this honest:

- **Check the port before spawning.** `lsof -i :3000 -sTCP:LISTEN -n -P` — a second server
  on a bound port dies instantly and its session sits there looking alive-ish.
- **Boot timeouts are generous.** Rails 60-120s cold, esbuild/vite 5-15s, cargo/mix
  after a build much longer. A too-short `--timeout` reports failure on a healthy boot.
- **Match the readiness regex to the real line**, not to hope. Take it from a boot you
  have actually seen; `--text` is a regex, so alternate the plausible ones.
- **A `tu wait` timeout is a diagnosis, not a verdict.** Screenshot and read the error
  before saying the server failed. Nine times in ten the screen holds the answer:
  a missing migration, a port clash, a bundle out of date.

Compound commands need `--shell`, which wraps in `$SHELL -c`:

```bash
tu run --name frontend --shell --cwd /path/to/frontend 'npm run start'
tu run --name worker --shell --cwd /path/to/repo 'ENV=development ./bin/worker'
```

## Reading a running process

```bash
tu screenshot --name backend | python3 -c "import sys,json;print(json.load(sys.stdin)['content'])"
tu scrollback --name backend --lines 300 | python3 -c "import sys,json;print(json.load(sys.stdin)['content'])"
```

`screenshot` is the last screen (120x40 by default, so roughly the last 40 lines).
`scrollback` is the history. A stack trace that scrolled past lives in `scrollback`, not in
`screenshot` — reaching for the wrong one is the usual reason an agent declares a log
empty. For a chatty server, `--size 200x50` at spawn time buys a wider screen and fewer
wrapped lines.

## Restarting

```bash
tu kill --name backend
lsof -i :3000 -sTCP:LISTEN -n -P    # must come back empty before respawning
tu run --name backend ... && tu wait --name backend --text "Listening on" --timeout 90000
```

Graceful shutdowns (puma, phoenix) hold the port for seconds after the process dies.
Respawning into a still-bound port is how you end up with a session that looks alive and a
server that is not. Poll `lsof` until it is empty, then start.

`tu press --name backend Ctrl+C` sends the signal to the foreground process, which is what
you want for a server that cleans up on SIGINT (flushing a build cache, releasing a lock).
`tu kill` is the harder stop and also removes the session.

## Interactive processes

The PTY is real, so prompts work: `rails console`, `iex -S mix`, `psql`, a REPL.

```bash
tu run --name console --cwd /path/to/repo -- ./bin/console
tu wait --name console --text "irb|pry|>" --timeout 60000
tu type --name console "Model.count"
tu press --name console Enter
tu wait --name console --stable 1200
tu screenshot --name console | python3 -c "import sys,json;print(json.load(sys.stdin)['content'])"
```

`--stable` is the right wait when the output has no predictable marker: it waits for the
screen to stop changing rather than for a string.

## Hygiene

- `tu list` at the start of a session: adopt what is already running instead of spawning a
  duplicate. An `alive:false` entry with an `exit_code` is a crash worth reading before it
  is cleared.
- Kill what you started once the work is done, and leave alone what the human started.
- One `tu daemon` serves every session; it starts on demand. `tu daemon status` reports it
  and the live session count.
- `sleep` is never the answer. Every wait is `tu wait --text` or `tu wait --stable`.

## Telling the human where to look

When a process is up, say the name and the command, on one line:

```
backend up on :3000 — watch it with: tu monitor --name backend
```

That sentence is the whole point of the skill. The human attaches to the same screen the
agent is reading, so a disagreement about what the server is doing is settled by looking
rather than by describing.

## Reporting

Report what the screen says, never what it ought to say. If the process exited, give the
exit code from `tu status` and the last lines from `tu scrollback`. If a readiness wait
timed out, say so and paste the screen. "Started successfully" without a port check or a
matched readiness line is a guess.
