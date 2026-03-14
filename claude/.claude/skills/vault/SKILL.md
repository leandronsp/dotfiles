---
name: vault
description: Search and retrieve notes from the Obsidian vault. Use when the user wants to find notes, recall past ideas, get context on a topic, look up references, browse blog drafts, or load knowledge from their second brain into the conversation. Trigger on phrases like "check my notes", "what do I have on", "find in vault", "search notes", "load notes about".
---

# Vault

Searches and retrieves notes from the Obsidian vault at `~/vault`.

## Search strategies

Use the right approach based on what the user needs:

### By topic (most common)
```bash
rg -l "search term" ~/vault --type md
```

### By folder
```bash
ls ~/vault/blog/drafts/          # Blog drafts
ls ~/vault/inbox/                # Unprocessed notes
ls ~/vault/projects/fullfabric/  # FF-specific notes
ls ~/vault/learning/til/         # TIL notes
```

### By tag
```bash
rg -l "tags:.*search_tag" ~/vault --type md
```

### By recency
```bash
find ~/vault -name "*.md" -not -path "*/.obsidian/*" -not -path "*/templates/*" -mtime -7 | sort
```

### Recent notes (last 7 days)
```bash
find ~/vault -name "*.md" -not -path "*/.obsidian/*" -not -path "*/templates/*" -newer ~/vault -mtime -7
```

## Output

After finding relevant notes, read them and present a concise summary. If multiple notes match, list them with a one-line description each and ask which ones the user wants to dive into.

## Vault structure

```
~/vault/
  inbox/              Quick captures, unprocessed
  blog/drafts/        Blog post drafts
  blog/published/     Published posts
  blog/ideas.md       Blog idea backlog
  learning/til/       Today I Learned
  projects/           Per-project notes (fullfabric, mendio, etc)
  references/         Tools, links, useful info
  sessions/           Session logs
  templates/          Note templates
```

## Connecting context

When the user asks about a topic, search broadly first, then narrow down. If you find relevant notes, offer to bring them into the conversation as context for the current task.
