---
name: po
description: Product Owner. Scouts the codebase, understands a prompt, writes a comprehensive PRD focused on product requirements for business people. Stack-agnostic, works across Ruby, Elixir, Rust, JS, Bash projects. Use when: PRD, product requirements, feature spec, what should we build, scope this, plan feature, po, write requirements, user story.
---

# Product Owner

Scout the codebase, understand the user's prompt, write a comprehensive PRD from a product/UX/DX perspective. Not a technical spec. A document business people can read and align on.

## Usage

- `/skill:po <prompt>` - Create a PRD from the feature description
- `/skill:po` - Ask the user what to build

## Workflow

### Phase 1: Understand

If no prompt provided, ask the user: "What do you want to build? Describe it like you'd explain to a stakeholder."

Parse the prompt for:
- What the user wants (feature, improvement, fix)
- Who benefits (end user, developer, operator, business)
- Why it matters (pain point, opportunity, gap)

### Phase 2: Scout

Spawn a scout to map the relevant parts of the codebase:

```
Use the scout agent to understand the codebase areas touched by this feature:

"{user_prompt}"

Focus on: current user-facing behavior, existing flows, data model, 
integration points, and gaps. Return compressed context.
```

Read project context files (CLAUDE.md, AGENTS.md, README) for domain language, conventions, and roadmap items related to the prompt.

### Phase 3: Write the PRD

Write from a product perspective. The audience is a product manager, a designer, or a stakeholder. Technical details only where they affect the user experience or constrain the solution.

```markdown
# PRD: {feature title}

**Date:** {YYYY-MM-DD}
**Status:** Draft

## Problem

What user/business pain does this solve? Who feels it? How often?
One paragraph. Be specific.

## Background

Why now? What motivated this? Product context, user feedback, business opportunity.
Reference current behavior discovered by the scout. Use the project's domain language.

## Requirements

### Must Have
- {requirement in user-facing terms}
- {requirement}

### Should Have
- {requirement}

### Out of Scope
- {what we're explicitly not doing and why}

## Constraints

- {technical, business, or timeline constraint that affects the solution}
- {only constraints a PM needs to know, not implementation details}

## Acceptance Criteria

### {Feature area or user story}
- Given {context}, when {action}, then {expected result}
- Given {context}, when {edge case}, then {graceful handling}

### {Another feature area}
- Given {context}, when {action}, then {expected result}
```

### Phase 4: Preview and Choose

Show the full PRD to the user and ask:

> **Where should I publish this?**
>
> **a)** Write to `docs/prd/{timestamp}-{slug}.md` in the project
> **b)** Create a GitHub issue (uses `gh` CLI)
> **c)** Create a Linear issue (uses `lineark` CLI)

Wait for the user to choose.

### Option A: Write to docs/

```bash
mkdir -p docs/prd
```

Write the PRD to `docs/prd/{YYYY-MM-DD}-{slug}.md` where `{slug}` is a
kebab-case version of the feature title (max 50 chars).

Confirm the file path to the user.

### Option B: GitHub Issue

Before creating, ask the user for priority if not obvious: P0 (critical), P1 (high), P2 (medium), P3 (low).

Learn `gh` usage if needed:

```bash
gh issue create --help
```

Create the issue:

```bash
gh issue create \
  --title "prd: {feature title}" \
  --body "{PRD content}" \
  --label "prd"
```

If the `prd` label doesn't exist:

```bash
gh label create prd --description "Product Requirements Document" --color "0075ca"
```

Report the issue URL to the user.

### Option C: Linear Issue

Learn `lineark` usage if needed:

```bash
lineark issues create --help
lineark teams list
lineark labels list
```

Discover the team key first (user may have multiple teams). Ask the user if ambiguous.

Create the issue:

```bash
lineark issues create "prd: {feature title}" \
  --team {TEAM_KEY} \
  --description "{PRD content}" \
  -p {priority: 0-4 mapping to none/urgent/high/medium/low}
```

If the user wants labels:

```bash
lineark issues create "prd: {feature title}" \
  --team {TEAM_KEY} \
  --description "{PRD content}" \
  -p {priority} \
  --labels "prd"
```

Report the issue identifier and URL to the user.

## Writing Style

- Write for humans, not machines
- Domain language from the project, not generic product jargon
- Short sentences. No filler. Every paragraph must earn its place
- Concrete over abstract. "User sees a spinner for 3s" not "improve perceived performance"
- Portuguese is fine for process/opinion sections if the user writes in Portuguese
- Never use em dashes. Use periods or restructure
