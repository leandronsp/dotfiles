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

### 5. tokei -- codebase orientation

**14.1k stars. brew install tokei or cargo install tokei.**

Counts lines of code, comments, and blanks per language. Sub-second execution.

```bash
tokei .                # full breakdown by language
tokei . --sort code    # sorted by lines of code
```

Not a grep replacement, but useful as a first call to understand what you're dealing with.

**Replaces:** Manual file counting and language guessing.

## Before and After

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

### After: ~8 tool calls, single phase

```
1. tokei .                              # orientation (1 call, <100ms)
2. repomix --compress                   # full structure map (1 call, few seconds)
3. Read the PRD                         # (1 call)
4. 3-5 targeted grep-ast/ast-grep      # specific questions only
```

The stress-test agent should receive the plan + the repomix output and validate logic. It should never re-explore the codebase.

## Key Insight: Aider's Repo Map

Aider (42k stars) solved this problem with a graph-ranked repo map:

1. Parse all files with tree-sitter to extract symbols
2. Build a cross-reference graph (which symbols reference which)
3. Rank symbols by reference frequency (PageRank-style)
4. Fit the most important symbols into a configurable token budget

The underlying tech: tree-sitter for parsing + grep-ast for contextual display + graph ranking for relevance. Not available as a standalone tool, but `repomix --compress` approximates it well enough.

## Installation

```bash
npm install -g repomix
pip install grep-ast
brew install ast-grep universal-ctags tokei
```
