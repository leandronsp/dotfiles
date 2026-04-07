---
name: commit
description: "Git commit with conventional commits, optional draft PR. Small, incremental, human-written messages. Never mentions AI, agents, or Claude. Use when: commit, commit this, save changes, git commit, stage and commit, create PR, open PR, draft PR."
---

# Commit

Small, incremental git commits following conventional commits. Optionally open a draft PR.

## Usage

- `/commit` - commit staged changes
- `/commit detailed` - multi-paragraph commit
- `/commit --pr` - commit + open/update a draft PR

## Commit Format

```
<type>(<scope>): <short description>
```

**Types:** `feat`, `fix`, `refactor`, `test`, `chore`, `docs`
**Scope:** optional, module or area name (e.g. `feat(auth): add token refresh`)

## Modes

### Quick (default)

Single-line commit message.

```bash
git commit -m "feat(auth): add token refresh"
```

### Detailed (`detailed` or when the change is significant)

Multi-paragraph for milestone features, non-obvious fixes, architectural changes.

Output the proposed message as plain text for review. **Do NOT run `git commit` until the user approves.**

```bash
git commit -m "feat(auth): add token refresh on expiry

Tokens are now refreshed automatically when they expire.
Refresh failures fall back to re-authentication instead of
silently failing the request."
```

## Commit Rules

1. **Stage explicitly** — `git add <files>`, never `git add -A` or `git add .`
2. **Concise** — present tense imperative ("add" not "added")
3. **Lowercase** after prefix
4. **No AI mentions** — never reference Claude, AI, agents, copilot, or assistants
5. **No Co-Authored-By** — never add Co-Authored-By trailers
6. **No emojis** in commit messages
7. **Human voice** — write like a developer wrote it by hand
8. **Small commits** — one logical change per commit. During TDD: commit after each RED-GREEN-REFACTOR cycle

## Pre-commit

Before committing, run the project's test suite. Check what's available:

```bash
# Try common test commands
make test 2>/dev/null || mix test 2>/dev/null || cargo test 2>/dev/null || bundle exec rspec 2>/dev/null || npm test 2>/dev/null
```

Check the diff before staging:

```bash
git diff
git diff --staged
```

## Commit Examples

```
test(auth): add token expiration edge cases
feat(api): add webhook endpoint for events
fix(worker): handle nil payload on retry
refactor(store): extract state operations into module
docs(readme): add setup instructions for local dev
chore(ci): add type checking to CI pipeline
```

---

## Draft PR (`--pr`)

When called with `--pr`, commit any pending changes first, then open or update a draft PR.

### PR Workflow

#### 1. Ensure feature branch

```bash
git branch --show-current
```

**Never commit to `main`/`master` unless explicitly requested.** If on main, create a feature branch:

```bash
git checkout -b <type>/<short-name>
```

Branch naming follows the commit type: `feat/`, `fix/`, `refactor/`, `test/`, `chore/`, `docs/`.

Commit any uncommitted changes before proceeding.

#### 2. Gather context

```bash
git log main..HEAD --oneline 2>/dev/null || git log master..HEAD --oneline
git diff main...HEAD --stat 2>/dev/null || git diff master...HEAD --stat
```

#### 3. Identify source issue

Check conversation context, branch name, or commit messages for issue references (GitHub `#N` or Linear `TEAM-N`). If found, link it in the PR body with a closing keyword.

#### 4. Check if PR already exists

```bash
gh pr view --json number,title,body 2>/dev/null
```

#### 5. Write PR description

Show the proposed title and body to the user. **Wait for approval before creating.**

### PR Title Format

```
<type>: <short description>
```

Same rules as commits: lowercase, imperative, under 70 chars.
If a Linear ID is available: `TEAM-123 - <type>: <short description>`

### PR Body

Two sections only. No checklists, no file lists, no templates.

```markdown
<issue_url>

### Background

1-2 paragraphs explaining the problem and the high-level approach.
Write naturally, like explaining to a colleague.

### Key Decisions

1. **Decision title**: brief explanation of the choice.
2. **Another decision**: what was done, stated as a fact.
```

Link the issue URL on its own line (no "Closes" keyword). Omit if no source issue. Omit Key Decisions if there are none worth mentioning (small fixes).

#### 6. Create or update

**New PR:**

```bash
gh pr create --draft --title "<title>" --body "<body>"
```

**Existing PR:**

```bash
gh pr edit --title "<title>" --body "<body>"
```

Push the branch first if needed:

```bash
git push -u origin $(git branch --show-current)
```

Report the PR URL to the user.

### PR Style

- **Fluid prose** in Background. Natural writing, not robotic
- **Key Decisions stated as facts.** Say what you did, one sentence each. No justifying what you avoided or why alternatives were worse
- **No implementation details in decisions.** Don't explain how the code works, just the architectural choice
- **No file lists or changelogs.** GitHub shows that in "Files changed"
- **No AI mentions.** Never reference agents, Claude, copilot, or AI assistance
- **No em dashes, en dashes, or double dashes.** Use colons, commas, or periods
- **No "Closes" keyword.** Just link the issue URL on its own line
- **Human voice.** Write like a developer wrote it
