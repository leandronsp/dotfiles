# Codebase Exploration Tools for AI Agents

The problem: Claude Code agents explore codebases by running 20-60+ sequential grep/find/read calls. A scout phase alone can take 22 tool calls, a plan phase 24 more, and a stress-test phase 61+. That's 107+ calls to understand a single repo.

Better tools exist. Here's what works.

## The Stack

### 1. repomix -- repo to single file (the big win)

**22.7k GitHub stars. npm install -g repomix.**

Packs an entire codebase into one AI-friendly file. The `--compress` flag uses tree-sitter to extract only structural elements (method signatures, class definitions, module exports), drastically reducing tokens while preserving the full map.

```bash
repomix --compress                      # compressed: signatures and structure only
repomix --compress --style markdown     # markdown output
repomix --include "lib/**/*.rb"         # scoped to specific dirs
repomix --include "src/**/*.ts"         # selective packing
```

One call replaces an entire scout phase. This is essentially what aider's "repo map" does internally.

**Replaces:** 15-30 sequential grep/find/read calls for initial codebase exploration.

### 2. grep-ast -- grep with AST context

**332 stars, but battle-tested inside aider (42k stars). pip install grep-ast.**

Grep that shows matching lines plus their enclosing function, class, or module. Instead of getting line 47 in isolation, you see the full structural context.

```bash
grep-ast "SimpleCov.start" .           # recursive, respects .gitignore
grep-ast -i "auth" src/                # case-insensitive with AST context
grep-ast "Process.pid" lib/            # see which function uses Process.pid
```

One grep-ast call gives what takes 3-5 sequential calls with regular grep: find match, read surrounding lines, figure out enclosing function, understand the context.

**Replaces:** 3-5 sequential grep + read calls per search query.

### 3. ast-grep -- structural code search

**13.2k stars. brew install ast-grep or cargo install ast-grep.**

Grep but matching AST patterns instead of text. Write a code pattern with `$WILDCARDS` and it finds all structurally matching code regardless of formatting or whitespace.

```bash
ast-grep -p 'def $NAME(self, $$$):' -l python        # all Python methods
ast-grep -p '$A.connection.disconnect' -l ruby        # structural match
ast-grep -p 'function $NAME($$$ARGS) { $$$ }' -l js  # all JS functions
ast-grep -p '$A.map($FN)' -l ts                       # all .map() calls
ast-grep --json -p '$PATTERN' -l rust                  # JSON for programmatic use
```

**Replaces:** Multiple regex greps that try to account for formatting variations.

### 4. universal-ctags -- full symbol index

**7.1k stars. brew install universal-ctags.**

Parses source code and outputs a structured index of every symbol (functions, classes, methods, variables, modules) with locations. Supports 100+ languages. JSON output for machine consumption.

```bash
ctags -R --output-format=json --fields=+Kn -f - .        # JSON dump, all symbols
ctags -R --output-format=json --kinds-all='*' -f - src/   # all symbol kinds
ctags -R -x --sort=no .                                    # human-readable cross-reference
```

Note: macOS ships with BSD ctags (limited). You need `brew install universal-ctags` for JSON output.

**Replaces:** 10-20 grep calls looking for class/method/function definitions.

### 5. rtk -- CLI proxy for token compression

**16.1k GitHub stars. brew install rtk.**

Rust binary that sits between the AI agent and shell commands, compressing outputs by 60-90%. Filters noise, groups similar items, truncates redundancy, and deduplicates repeated lines. Covers 100+ commands: git, grep, test runners, linters, docker, package managers, and more.

```bash
rtk init -g                     # install hook for Claude Code (auto-rewrites bash commands)
rtk ls .                        # compact directory tree
rtk read file.rs                # smart file reading
rtk read file.rs -l aggressive  # signatures only (strips bodies)
rtk git status                  # compact status
rtk git diff                    # condensed diff
rtk test cargo test             # failures only (-90%)
rtk grep "pattern" .            # grouped search results
rtk gain                        # show token savings stats
```

The auto-rewrite hook transparently intercepts Bash tool calls (`git status` → `rtk git status`). The agent never sees the rewrite, just gets compressed output. Note: Claude Code built-in tools (Read, Grep, Glob) bypass the hook — use shell commands or explicit `rtk` calls for those.

Complementary to repomix: repomix compresses the codebase for initial exploration, rtk compresses **all command output** throughout the entire session.

**Replaces:** Raw command output that wastes 60-90% of tokens on noise, boilerplate, and redundancy.

### 6. tokei -- codebase orientation

**14.1k stars. brew install tokei or cargo install tokei.**

Counts lines of code, comments, and blanks per language. Sub-second execution.

```bash
tokei .                # full breakdown by language
tokei . --sort code    # sorted by lines of code
```

Not a grep replacement, but useful as a first call to understand what you're dealing with.

**Replaces:** Manual file counting and language guessing.

## Before and After (with rtk)

### Before: 107+ tool calls across 3 phases

```
Scout phase (22 calls, 3 min):
  - grep for patterns across the repo
  - find files by name
  - read files one by one
  - more greps for related patterns

Plan phase (24 calls, 4.5 min):
  - re-read the same files
  - more greps to confirm findings
  - search for edge cases

Stress-test phase (61+ calls, 24 min):
  - re-explore the entire codebase from scratch
  - sequential grep -r calls through Bash
  - find commands for file discovery
  - re-read files already read twice
```

### After: ~8 tool calls, single phase (all outputs compressed by rtk)

```
1. tokei .                              # orientation (1 call, <100ms)
2. repomix --compress                   # full structure map (1 call, few seconds)
3. Read the PRD                         # (1 call)
4. 3-5 targeted grep-ast/ast-grep      # specific questions only
```

With `rtk init -g`, every Bash call in the session is automatically compressed. The 8 calls above plus all subsequent git, test, and lint commands use 60-90% fewer tokens.

The stress-test agent should receive the plan + the repomix output and validate logic. It should never re-explore the codebase.

## Key Insight: Aider's Repo Map

Aider (42k stars) solved this problem with a graph-ranked repo map:

1. Parse all files with tree-sitter to extract symbols
2. Build a cross-reference graph (which symbols reference which)
3. Rank symbols by reference frequency (PageRank-style)
4. Fit the most important symbols into a configurable token budget

The underlying tech: tree-sitter for parsing + grep-ast for contextual display + graph ranking for relevance. Not available as a standalone tool, but `repomix --compress` approximates it well enough.

## Tradeoff Analysis

### rtk

**Pros:**
- Passive — zero change to agent behavior, transparent compression
- Rust single binary, no runtime dependencies, claims <10ms overhead
- 100+ supported commands out of the box
- Built-in analytics (`rtk gain`) to measure actual savings
- 16k stars, active development

**Cons:**
- **Extra abstraction layer.** If rtk over-compresses or filters something relevant, the agent makes decisions on incomplete information. Debugging gets harder — "what did the agent actually see?"
- **Unexpected output formats.** Agent expects format X from `git diff`, rtk returns format Y. Can break skills that parse command output
- **External dependency.** One more binary to maintain. If rtk has a bug, every session is affected
- **Young version (0.34).** API may change, edge case bugs likely
- **Pi integration untested.** `rtk proxy ${command}` via spawnHook needs validation for pipes, heredocs, multiline commands

**Verdict:** Real token savings, but risk of losing information that matters. Run for 1-2 weeks with `rtk gain` to validate before relying on it.

### repomix

**Pros:**
- One call replaces 15-30 sequential exploration calls
- `--compress` uses tree-sitter — extracts only structural elements
- Flexible scoping with `--include`
- Approximates aider's repo map concept

**Cons:**
- **Token cost of the output itself.** Large repos, even compressed, can be 20-50k tokens. You pay to read everything, including what's irrelevant to the task
- **Noise.** Includes files irrelevant to the current task. A targeted scout with grep can be more surgical
- **Node dependency** (npm global)
- **Goes stale.** If you edit files during the session, the repomix from the start is outdated
- **Not all repos benefit.** Small repos don't need it. Huge monorepos overflow context even compressed

**Verdict:** Good for medium repos (5-50k LOC) on initial exploration tasks. For reviewing a specific PR, overkill — the diff + touched files is enough.

### grep-ast

**Pros:**
- Automatic AST context (see the enclosing function/class for each match)
- Battle-tested inside aider (42k stars)

**Cons:**
- **Python dependency** (pip install, virtualenv management)
- **Slower than rg.** Tree-sitter parsing on every file adds overhead
- **The agent already does this.** When rg finds something, the agent reads the surrounding context. Two calls instead of one, but reliable and predictable
- **Marginal gain.** Saves 1-2 calls per search. Over 5 searches, that's 5-10 calls. Doesn't transform the session

**Verdict:** Nice to have. Not worth the complexity of another Python dependency.

### ast-grep

**Pros:**
- Structural search is powerful for refactors and reviews
- Rust, fast
- Expressive patterns with wildcards

**Cons:**
- **Learning curve.** Agent needs to know pattern syntax (`$NAME`, `$$$ARGS`). Requires skill instructions
- **Niche.** Useful in ~10% of cases. For "find where this method is called", `rg` is enough
- **Variable language support.** Not all tree-sitter grammars are equally mature

**Verdict:** Useful as a point tool, not as a default. Install, use when it makes sense, no extension or skill needed.

### universal-ctags

**Pros:**
- Full symbol index with locations, 100+ languages
- JSON output for machine consumption

**Cons:**
- **repomix `--compress` already does this better** for LLM context. ctags gives raw symbol lists without the structural relationships
- **macOS ships BSD ctags** — need to install universal-ctags separately
- **Large output.** Big repos produce massive symbol tables

**Verdict:** Superseded by repomix for agent use cases.

### Bash tools (rg, find, read) — the baseline

**Pros:**
- **Zero extra dependencies.** Already installed everywhere
- **Predictable.** Well-known output formats, no surprises
- **The agent already knows them.** No extra instructions, no learning curve
- **Debuggable.** You see exactly what the agent saw
- **Composable.** `rg pattern | head -20` — full control via pipes

**Cons:**
- **Verbose.** Many sequential calls to build context
- **Wasted tokens.** Raw output from `git status`, `cargo test` etc. full of noise
- **Slow on initial exploration.** 20+ calls to understand a new repo

**Verdict:** Reliable baseline. This is what works today.

## Benchmark: rtk on a real codebase (dotfiles repo)

Tested rtk 0.34.2 against plain commands on this dotfiles repository.

### Results by command

| Command | Plain (bytes) | rtk (bytes) | Saving | Quality |
|---------|-------------:|------------:|-------:|--------|
| `ls -la` (root) | 1,442 | 193 | **87%** | ✅ Excellent — clean, grouped by type |
| `git status` | 341 | 79 | **77%** | ✅ Excellent — all relevant info preserved |
| `grep 'spawnHook'` (4 hits) | 624 | 399 | **36%** | ✅ Good — grouped by file with line numbers |
| `grep 'local'` (122 hits) | 11,435 | 7,682 | **33%** | ✅ Good — grouped by file, more readable |
| `git log -10` | 3,792 | 2,568 | **32%** | ⚠️ Modest — truncates commit body |
| `git diff` (177 lines) | 10,486 | 7,652 | **27%** | ⚠️ Modest — keeps almost everything |
| `read Makefile` | 3,900 | 3,901 | **0%** | ❌ No savings on normal read |
| `read -l aggressive` (keymaps.lua) | 7,799 | 484 | **94%** | ✅ Excellent — signatures only |
| `smart` (heuristic summary) | — | ~30 | — | ❌ Useless — "General purpose code file" for everything |
| `find *.lua` (root) | 1,864 (38 files) | 14 (0 files) | — | ❌ **BUG** — found nothing |
| `find *.lua` (subdir) | — | compact | — | ✅ Works when pointed at specific dir |
| `find *.md` (root) | 30 files | 3 files | — | ❌ **BUG** — missed 27 of 30 files |

### Where it shines

- **`ls`** — 87% saving, clean output. Replaces `ls -la` easily
- **`git status`** — 77% saving, zero information loss
- **`read -l aggressive`** — 94% saving. Perfect for scout/exploration. Signatures only
- **`grep` grouped** — 33-36% saving with **more readable** output (grouped by file)
- **`git add/commit/push`** — expected ~90% (boilerplate removal)
- **test runners** — expected ~90% (failures only)

### Where it fails

- **`find`** — **loses files.** `rtk find *.md .` returns 3 files, plain `find` returns 30. Agent thinks files don't exist. Appears to skip nested dirs or dotfile-prefixed paths. **Deal-breaker for passive use.**
- **`smart`** — completely useless. Returns the same generic label for Lua, Makefile, Markdown
- **`read` (normal)** — zero saving. Returns the full file unchanged
- **`git diff`** — modest saving (27%). Not worth the risk of losing diff context
- **`git log`** — modest saving (32%). Truncates commit body but keeps a lot

## Integration: Claude Code vs Pi

### rtk

- **Claude Code:** `rtk init -g` patches `~/.claude/settings.json` with a bash hook. Transparent, native support.
- **Pi:** No native support. Requires a **selective spawnHook extension** (see below).

### repomix

- **Both Claude Code and Pi:** Lives as a **skill instruction**, not an extension. The agent needs to *decide* when to run `repomix --compress`. Add it to skills that do codebase exploration (scout, /dev, /review).
- Extensions intercept commands (infrastructure). Skills tell the agent what to do (behavior). repomix is behavior.

## Selective spawnHook for Pi

The `find` bug and zero-gain `read` make a blanket `rtk proxy ${command}` dangerous. The hook must be **selective** — only rewrite commands where rtk is proven reliable.

### Allowlist (rewrite through rtk)

| Command prefix | Why | Expected saving |
|---|---|---:|
| `ls` | Clean, grouped output | ~87% |
| `git status` | Compact, zero info loss | ~77% |
| `git add` | Boilerplate → "ok" | ~92% |
| `git commit` | Boilerplate → "ok abc1234" | ~92% |
| `git push` | Boilerplate → "ok main" | ~90% |
| `git pull` | Boilerplate → summary | ~90% |
| `grep` / `rg` | Grouped by file, more readable | ~33% |
| `cargo test` | Failures only | ~90% |
| `npm test` / `vitest` | Failures only | ~90% |
| `pytest` | Failures only | ~90% |
| `cargo build` / `cargo clippy` | Errors only | ~80% |
| `docker ps` / `docker images` | Compact tables | ~80% |

### Passthrough (keep plain)

| Command | Why |
|---|---|
| `find` | **Loses files** — misses nested dirs, dotfile paths |
| `cat` / `read` / `head` / `tail` | Zero saving on normal read |
| `git diff` | Only 27% saving, risk of losing context |
| `git log` | Only 32% saving, modest gain |
| `cd` / `pwd` / `echo` / `mkdir` | No output to compress |
| Pipes / heredocs / multiline | Untested, risk of breaking |

### Extension implementation

```typescript
// ~/.pi/agent/extensions/rtk-proxy.ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { createBashTool } from "@mariozechner/pi-coding-agent";

// Commands where rtk is proven reliable and provides meaningful savings.
const RTK_ALLOWLIST = [
  /^ls\b/,
  /^git\s+status\b/,
  /^git\s+add\b/,
  /^git\s+commit\b/,
  /^git\s+push\b/,
  /^git\s+pull\b/,
  /^(rg|grep)\b/,
  /^cargo\s+(test|build|clippy)\b/,
  /^(npm|pnpm|yarn)\s+test\b/,
  /^(vitest|jest|pytest|rspec|rake\s+test)\b/,
  /^docker\s+(ps|images|compose\s+ps)\b/,
];

function shouldRewrite(command: string): boolean {
  const trimmed = command.trim();
  return RTK_ALLOWLIST.some((re) => re.test(trimmed));
}

export default function (pi: ExtensionAPI) {
  const cwd = process.cwd();

  const bashTool = createBashTool(cwd, {
    spawnHook: ({ command, cwd, env }) => ({
      command: shouldRewrite(command) ? `rtk proxy ${command}` : command,
      cwd,
      env,
    }),
  });

  pi.registerTool({
    ...bashTool,
    execute: async (id, params, signal, onUpdate, _ctx) => {
      return bashTool.execute(id, params, signal, onUpdate);
    },
  });
}
```

### How it works

1. Agent runs `git status` → spawnHook matches `/^git\s+status\b/` → rewrites to `rtk proxy git status` → agent sees compact output
2. Agent runs `find . -name '*.lua'` → no match → passes through unchanged → agent sees full results
3. Agent runs `cat Makefile` → no match → passes through → no savings but no risk
4. Agent runs `cargo test` → matches → `rtk proxy cargo test` → agent sees failures only

The allowlist is conservative. Add commands only after benchmarking them on real codebases.

## Recommendation

| Tool | Install? | Priority | Rationale |
|------|----------|----------|----------|
| **rtk** | Yes, with selective hook | High | Passive savings on allowlisted commands. ~77-90% on git/ls/test |
| **repomix** | Yes, use selectively | High | One call replaces scout phase. Best for medium repos, initial exploration |
| **ast-grep** | Install, don't integrate | Low | `brew install`, use manually when structural search is needed |
| **grep-ast** | Skip for now | — | Marginal gain, Python dependency |
| **universal-ctags** | Skip | — | repomix `--compress` covers this better |
| **tokei** | Optional | Low | One-liner orientation, but repomix/tree already cover it |
| **rg/find/read** | Keep as baseline | — | Reliable, predictable, zero surprises |

The biggest risk is trading **reliability for optimization**. A cheaper session that makes wrong decisions due to missing information costs more in the end. The selective spawnHook mitigates this by only rewriting commands with proven savings and no information loss.

## Installation

```bash
brew install rtk                              # CLI proxy (token compression)
npm install -g repomix                         # repo packer
brew install ast-grep tokei                    # structural search, stats (optional)
```

For Claude Code: `rtk init -g` and restart.
For Pi: add `~/.pi/agent/extensions/rtk-proxy.ts` to `settings.json` extensions array and restart.
