---
name: recap
description: Save session learnings to the Obsidian vault. Use at the end of a work session to capture what was learned, decided, or discovered. Trigger on phrases like "recap", "save session", "what did we learn", "wrap up".
---

# Recap

Reviews the current session and saves valuable learnings to `~/vault/sessions/`.

## When to save

Not every session has learnings worth saving. Save when:

- A non-obvious bug was found and the root cause is worth remembering
- An architectural decision was made with tradeoffs discussed
- A new pattern, tool, or technique was discovered
- Something surprising happened that changes how we think about the codebase
- A workflow or process improvement was identified

Do NOT save:

- Routine changes (added a field, fixed a typo)
- Things already documented in code comments or commit messages
- Generic knowledge easily found in docs

## How to decide

Look back at the conversation. Ask yourself: "If I start a fresh session in this project next week, what would I wish I knew?" If the answer is nothing, say so and don't create a file.

## Session note format

```markdown
---
tags: [session, {project}]
created: YYYY-MM-DD
project: {project-name}
---

# Session: {brief title}

## Context
{What was being worked on, 1-2 sentences}

## Learnings
- {Key insight 1}
- {Key insight 2}

## Decisions
- {Decision made and why, if any}

## Open threads
- {Things left unfinished or to revisit, if any}
```

## Filename

Use `{project}-{session_id_short}.md` where:

- `{project}` is `basename` of the working directory
- `{session_id_short}` is the first 8 characters of the session UUID

To find the session ID, get the most recent `.jsonl` file in `~/.claude/projects/-{cwd_with_dashes}/`. The filename (without `.jsonl`) is the session UUID.

This makes `/recap` idempotent. Running it twice in the same session overwrites the same file.

## Steps

1. Resolve the session ID (see Filename section above)
2. Review the conversation for learnings, decisions, and surprises
3. If nothing worth saving, tell the user: "Nothing non-obvious to save from this session."
4. If there are learnings, show a **preview** of the full note (rendered, not as a code block) and ask the user to confirm before saving. The user may want to edit, add, or remove things.
5. Only after confirmation, write the session note to `~/vault/sessions/{project}-{session_id_short}.md`
6. Search for related notes: `qmd search -c vault "{topic}"` and add `[[links]]`
7. Update index: `qmd update -c vault && qmd embed 2>/dev/null`
8. Confirm what was saved and where

## Writing style

Follow the user's voice. Informal, direct, no AI-speak, no em dashes. Portuguese for process/opinions, English for technical content.
