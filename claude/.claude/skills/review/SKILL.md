---
name: review
description: "Multi-agent code review. Spawns parallel security, performance, and quality reviewers, then a red team auditor, then presents findings for the user to judge. Accepts a prompt, GitHub/Linear issue URL, PRD file path, or no args. Use when: review, code review, review this PR, review my changes, review against spec, check my work, security review, quality check."
---

# Review

Multi-agent code review pipeline with parallel specialized reviewers, red team audit, and user judgment.

## Usage

- `/review` - asks what to review
- `/review <prompt>` - review current changes against the prompt
- `/review <url>` - review against a GitHub/Linear issue
- `/review <path>` - review against a PRD/spec file

## Workflow

### Phase 1: Understand the review target

**No arguments:** Ask the user: "What should I review? You can describe it, paste an issue URL, or point me to a spec file."

**Prompt:** Use it as the review context directly.

**URL:** Fetch the issue content:

- GitHub issue: `gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'`
- GitHub PR: `gh pr view <number> --json title,body --jq '.title + "\n\n" + .body'`
- Linear: `lineark issues read <identifier>`

**File path:** Read the file content as review context.

Store the resolved context as `{review_context}`.

### Phase 2: Get the diff

```bash
git diff main...HEAD
```

If empty, try `git diff HEAD~1`. If still empty, tell the user there's nothing to review and stop.

Store as `{diff}`. Also get the stat:

```bash
git diff main...HEAD --stat
```

### Phase 3: Scout

Launch the `scout` agent:

> Map the codebase areas touched by these changed files. Return: architecture, patterns, conventions, test structure, error handling, project rules from CLAUDE.md/AGENTS.md.
>
> Changed files:
> {diff_stat}

Store as `{scout_context}`.

### Phase 4: Parallel review

Launch **3 agents in parallel** (single message, 3 Agent tool calls):

- **`security-reviewer`**: "Review this PR for security issues.\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
- **`performance-reviewer`**: "Review this PR for performance issues.\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
- **`quality-reviewer`**: "Review this PR for quality issues (design, testing, DDD, SOLID, clean code).\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"

**CRITICAL**: All 3 in the **same message** so they run concurrently.

### Phase 5: Red team audit

Launch the `review-auditor` agent:

> Audit these three code review reports. Verify findings against actual code, check for false positives, blind spots, contradictions, and severity miscalibration.
>
> ## Review Context
> {review_context}
>
> ## Security Review
> {security_report}
>
> ## Performance Review
> {performance_report}
>
> ## Quality Review
> {quality_report}

### Phase 6: Judge

Synthesize everything (you, not a subagent):

1. Drop findings flagged as false positives by the auditor
2. Apply severity adjustments from the auditor
3. Mark high-confidence findings verified by the auditor
4. Add blind spots the auditor found as new findings
5. Deduplicate (same file:line across reviewers)
6. Tag each finding: `[security]`, `[performance]`, `[quality]`, `[audit]`

Present:

```markdown
## Code Review: {branch name}

**Diff:** {files changed}, {insertions}+, {deletions}-
**Reviewers:** security, performance, quality + red team audit

### Critical
- [{source}] **{title}** at `{file}:{line}`
  {description}
  **Test (RED first):** {failing test that proves the issue}
  **Fix:** {minimal fix}

### High / ### Medium / ### Low
- ...

### Good patterns
- {what's done well}

### Audit notes
- {false positives removed and why}
- {severity adjustments made}

**Verdict:** {Critical/High -> "Needs fixes" | Medium/Low only -> "Clean with suggestions" | Nothing -> "Ship it"}
```

### Phase 7: User choice

If verdict is not "Ship it":

> **What next?**
>
> **a)** Write full report to `docs/reviews/{branch-name}.md`
> **b)** Address findings (TDD, RED first, baby steps)

**Wait for the user to choose.**

**Option a:** Write the report file.

**Option b:** Prioritized fix list (critical -> high -> medium). One at a time. Every fix starts with a failing test.

If "Ship it": congratulate and stop.

## Principles

- TDD strictly. Every fix starts with RED first
- Baby steps. One fix at a time
- Stack-agnostic. Works on any project
- Project-aware. Reviewers check CLAUDE.md/AGENTS.md conventions
- Adversarial audit. Red team kills bad findings, not adds noise
