---
name: note
description: Capture an insight, idea, or note into the Obsidian vault. Use when the user wants to save something for later, jot down an idea, record a TIL, start a blog draft, or log anything to their second brain. Trigger on phrases like "save this", "note this down", "I had an idea", "TIL", "remember this", "add to vault".
---

# Note

Saves a note to the Obsidian vault at `~/vault`.

## Writing style

All notes must follow the user's voice. Write like a human, not like an AI.

- Informal, conversational, direct. No corporate speak, no filler
- Never use em dashes. Use periods to separate ideas
- Short sentences. Punchy. Get to the point
- First person when expressing opinion. "We" when exploring together
- Portuguese for opinions/ideas/process. English for technical/code topics
- No excessive formatting. Bold only for key terms on first mention
- No emoji in prose (ok in headers if it adds visual rhythm)

## How to decide where it goes

Based on the content, pick the right location:

| Content | Path | Template |
|---------|------|----------|
| Quick thought, unsorted | `inbox/{slug}.md` | note |
| Blog post idea (one-liner) | Append to `blog/ideas.md` under `## Backlog` | - |
| Blog post idea (needs exploration) | Suggest `/brainstorm` instead | - |
| Blog draft (outline ready) | `blog/drafts/{slug}.md` | blog-draft |
| Something learned today | `learning/til/{slug}.md` | til |
| Project-specific note | `projects/{project}/{slug}.md` | note |
| Useful link or tool | `references/{slug}.md` | note |

If ambiguous, ask the user. Default to `inbox/`.

## Slug

Generate a lowercase kebab-case slug from the title. Example: "Ruby GC tuning" becomes `ruby-gc-tuning`.

## Frontmatter

Every note must have YAML frontmatter:

```yaml
---
tags: [relevant, tags]
created: YYYY-MM-DD
---
```

For blog drafts, add `status: draft`. For project notes, add `project: {name}`.

## Links

If the note relates to existing notes, add `[[links]]` to connect them. Use `rg` on `~/vault` to find related notes before writing.

## Steps

1. Understand what the user wants to capture
2. Pick the right folder based on content type
3. Search vault for related notes with `rg`
4. Write the note with frontmatter, content, and links to related notes
5. Confirm to the user: what was saved and where
