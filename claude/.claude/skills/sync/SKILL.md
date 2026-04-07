---
name: sync
description: "Detect project stack, create/update project-level agents, skills, and rules based on user-level templates + stack best practices. Idempotent. Use when: sync, forge, tune, setup agents, configure project, init project, bootstrap, prepare project."
---

# Sync

Detect the project stack and create/update `.claude/` config (agents, skills, rules) based on user-level templates specialized for the detected stack. Idempotent. Safe to run again.

## Usage

- `/sync` - detect stack, sync everything
- `/sync agents` - only sync agents
- `/sync skills` - only sync skills
- `/sync rules` - only sync rules

## Phase 1: Detect Stack

```bash
ls mix.exs Gemfile Cargo.toml package.json go.mod pyproject.toml build.gradle pom.xml 2>/dev/null
```

Read existing `CLAUDE.md`, `.claude/` directory, `README.md`.

Identify: language, framework, test framework, build commands, linter/formatter, key dependencies.

Present to user:

> **Detected stack:**
> - Language: {language} {version}
> - Framework: {framework} {version}
> - Test: {test_framework}
> - Linter: {linter}
> - Key deps: {deps}
>
> Confirm? (or correct me)

**Wait for confirmation.**

## Phase 2: Gather Knowledge

Search the web for stack-specific best practices:

- `"{framework} code review checklist {year}"`
- `"{framework} security best practices"`
- `"{framework} performance anti-patterns"`

Read user-level templates from `~/.claude/agents/` and `~/.claude/skills/`.
Read any existing project-level files to know what's already there.

## Phase 3: Create/Update Agents

```bash
mkdir -p .claude/agents
```

For each user-level agent (`scout`, `quality-reviewer`, `security-reviewer`, `performance-reviewer`, `review-auditor`):

1. Read user-level `~/.claude/agents/{name}.md`
2. Read existing `.claude/agents/{name}.md` if it exists
3. Generate project-level version:
   - Same structure and principles from user-level
   - Add stack-specific sections (language idioms, framework patterns, anti-patterns)
   - Add project context from `CLAUDE.md` if available
   - Description prefix: `[ProjectName]`
   - Same model as user-level
4. **If file exists and differs, show diff. Ask before overwriting**
5. If identical, skip

Also create a `plan-reviewer` agent if one doesn't exist.

## Phase 4: Create/Update Skills

```bash
mkdir -p .claude/skills/{commit,dev,review,po}
```

For each user-level skill (`commit`, `dev`, `review`, `po`):

1. Read user-level `~/.claude/skills/{name}/SKILL.md`
2. Read existing project-level version if it exists
3. Generate project-level version:
   - Same workflow structure from user-level
   - Replace generic commands with stack-specific:

| Stack | Test command | Pre-commit | Linter |
|-------|-------------|------------|--------|
| Elixir/Phoenix | `mix test` | `mix precommit` or `mix format && mix compile --warnings-as-errors && mix test` | `mix format` |
| Ruby/Rails | `bundle exec rspec` | `rubocop -a && bundle exec rspec` | `rubocop` |
| Rust | `cargo test` | `cargo fmt && cargo clippy && cargo test` | `cargo fmt` |
| JS/TS (Node) | `npm test` or `jest` | `prettier --write . && npm test` | `prettier` / `eslint` |
| Go | `go test ./...` | `gofmt -w . && go vet ./... && go test ./...` | `gofmt` |
| Python | `pytest` | `ruff check --fix && pytest` | `ruff` / `black` |

   - Add project-specific workflow from `CLAUDE.md`
   - Description prefix: `[ProjectName]`
4. **If file exists and differs, show diff. Ask before overwriting**
5. If identical, skip

## Phase 5: Create/Update Rules

```bash
mkdir -p .claude/rules
```

Generate rule files based on detected stack. Each rule:

```yaml
---
description: {what this rule covers}
globs: ["{file patterns}"]
alwaysApply: false
---
```

**Rules to generate per stack:**

### Elixir/Phoenix
- `elixir.md` — globs: `["lib/**/*.ex", "test/**/*.exs"]` — idioms, Phoenix/LiveView patterns, anti-patterns
- `testing.md` — globs: `["test/**/*", "lib/**/*"]` — ExUnit conventions, TDD
- `git.md` — no globs — commit format, staging rules

### Ruby/Rails
- `ruby.md` — globs: `["app/**/*.rb", "lib/**/*.rb"]` — Rails patterns, service objects, thread safety
- `testing.md` — globs: `["spec/**/*"]` — RSpec conventions, factories
- `git.md` — no globs

### Rust
- `rust.md` — globs: `["src/**/*.rs"]` — ownership patterns, error handling, unsafe rules
- `testing.md` — globs: `["tests/**/*.rs", "src/**/*.rs"]` — test conventions
- `git.md` — no globs

### JS/TS
- `typescript.md` — globs: `["src/**/*.{ts,tsx,js,jsx}"]` — React/Node patterns, type safety
- `testing.md` — globs: `["**/*.test.{ts,tsx,js,jsx}", "**/*.spec.{ts,tsx,js,jsx}"]` — Jest/Vitest conventions
- `git.md` — no globs

### Go / Python / Other
- Similar pattern: language rule + testing rule + git rule

Include web-searched best practices in rule content. Be specific, not generic.

**If rule files exist and differ, show diff. Ask before overwriting.**

## Phase 6: CLAUDE.md Check

Read existing `CLAUDE.md`. Check for these sections:

- **Skills table** — listing available `/skill` commands
- **Agents table** — listing custom agents and their purpose
- **Rules table** — listing rules and their file scope
- **Commands section** — how to run tests, lint, build
- **Pipeline diagram** — `/po -> /dev -> /review -> /commit --pr`

For each missing section, propose an addition. Show the proposed content.

**Wait for approval before modifying CLAUDE.md.** Never overwrite existing content.

## Phase 7: Report

```markdown
## Sync Report

### Created
- `.claude/agents/scout.md` — [ProjectName] scout with {stack} specifics
- ...

### Updated
- `.claude/skills/commit/SKILL.md` — added {stack} test command
- ...

### Skipped (already up to date)
- `.claude/rules/git.md`
- ...

### Manual action needed
- [ ] Review CLAUDE.md additions
```

## Idempotency

- Read before write. Compare existing with generated
- If identical, skip
- If different, show diff and ask
- Never delete. Only create or update
- Preserve custom content in existing files
