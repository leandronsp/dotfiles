---
name: review
description: "Multi-agent code review. Spawns parallel security, performance, and quality reviewers, then a red team auditor, then presents findings for the user to judge. Accepts a prompt, GitHub/Linear issue URL, PRD file path, or no args. Use when: review, code review, review this PR, review my changes, review against spec, check my work, security review, quality check."
---

# Review

Multi-agent code review pipeline with parallel specialized reviewers, red team audit, and user judgment.

## Usage

- `/skill:review` - asks what to review
- `/skill:review <prompt>` - review current changes against the prompt
- `/skill:review <url>` - review against a GitHub/Linear issue
- `/skill:review <path>` - review against a PRD/spec file

## Workflow

### Phase 1: Understand the review target

**No arguments:** Ask the user: "What should I review? You can describe it, paste an issue URL, or point me to a spec file."

**Wait for the user's response.**

**Prompt:** Use it as the review context directly.

**URL:** Fetch the issue content:

- GitHub issue URL (contains `github.com`):
  ```bash
  gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'
  ```
- GitHub PR URL (contains `/pull/`):
  ```bash
  gh pr view <number> --json title,body --jq '.title + "\n\n" + .body'
  ```
- Linear issue URL or identifier:
  ```bash
  lineark issues read <identifier>
  ```

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

Spawn a scout agent to map the areas touched by the diff:

```
subagent({
  agent: "scout",
  task: "Map the codebase areas touched by these changed files. Return: architecture, patterns, conventions, test structure, error handling, project rules from CLAUDE.md/AGENTS.md.\n\nChanged files:\n{diff_stat}"
})
```

Store the scout output as `{scout_context}`.

### Phase 4: Parallel review

Spawn all 3 reviewers in parallel. Each gets the diff, scout context, and review context.

**CRITICAL**: All 3 must be in the same subagent call so they run concurrently.

```
subagent({
  tasks: [
    {
      agent: "security-reviewer",
      task: "Review this PR for security issues.\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
    },
    {
      agent: "performance-reviewer",
      task: "Review this PR for performance issues.\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
    },
    {
      agent: "quality-reviewer",
      task: "Review this PR for quality issues (design, testing, DDD, SOLID, clean code).\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
    }
  ],
  agentScope: "both"
})
```

Store the three reports as `{security_report}`, `{performance_report}`, `{quality_report}`.

### Phase 5: Red team audit

Spawn the review auditor with all three reports:

```
subagent({
  agent: "review-auditor",
  task: "Audit these three code review reports. Verify findings against actual code, check for false positives, blind spots, contradictions, and severity miscalibration. Check findings against project rules in CLAUDE.md/AGENTS.md.\n\n## Review Context\n{review_context}\n\n## Security Review\n{security_report}\n\n## Performance Review\n{performance_report}\n\n## Quality Review\n{quality_report}",
  agentScope: "both"
})
```

Store as `{audit_report}`.

### Phase 6: Judge

This is you (the main agent), not a subagent. Synthesize everything:

1. Read all 3 review reports and the audit report
2. For each finding across all reports:
   - Was it flagged as false positive by the auditor? Drop it
   - Was its severity adjusted by the auditor? Use the adjusted severity
   - Was it verified as high-confidence by the auditor? Mark it
3. Add any blind spots the auditor found as new findings
4. Deduplicate (same file:line across reviewers)
5. Tag each finding with source: `[security]`, `[performance]`, `[quality]`, `[audit]`

Present the consolidated review:

```markdown
## Code Review: {branch name}

**Diff:** {files changed}, {insertions}+, {deletions}-
**Reviewers:** security, performance, quality + red team audit

### Critical
- [{source}] **{title}** at `{file}:{line}`
  {description}
  **Test (RED first):** {failing test that proves the issue}
  **Fix:** {minimal fix}

### High
- ...

### Medium
- ...

### Low
- ...

### Good patterns
- {what's done well, acknowledged by reviewers}

### Audit notes
- {false positives removed and why}
- {blind spots found}
- {severity adjustments made}

**Verdict:** {Critical/High found → "Needs fixes" | Only Medium/Low → "Clean with suggestions" | Nothing → "Ship it"}
```

### Phase 7: User choice

If verdict is "Needs fixes" or "Clean with suggestions":

> **What next?**
>
> **a)** Write full report to `docs/reviews/{branch-name}.md`
> **b)** Address findings (TDD, RED first, baby steps)

**Option a:** Write the report to `docs/reviews/{branch-name}.md`. Include all findings, audit notes, and a cost/usage summary if available.

**Option b:** Build a prioritized fix list from critical → high → medium. Work through them one at a time. Every fix starts with a failing test. Baby steps. One concern per commit.

If verdict is "Ship it": congratulate and stop.

## Principles

- TDD strictly. Every fix suggestion starts with the failing test (RED first)
- Baby steps. One fix at a time. Don't bundle
- Stack-agnostic. Works on Ruby, Elixir, Rust, JS, Bash, whatever the project uses
- Project-aware. Reviewers read CLAUDE.md/AGENTS.md and review against project conventions
- Adversarial audit. The red team exists to kill bad findings, not to add noise
