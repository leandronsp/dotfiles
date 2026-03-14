---
name: vault
description: Search and retrieve notes from the Obsidian vault. Use when the user wants to find notes, recall past ideas, get context on a topic, look up references, browse blog drafts, consolidate notes for writing, or load knowledge from their second brain into the conversation. Trigger on phrases like "check my notes", "what do I have on", "find in vault", "search notes", "load notes about", "bring me everything about", "consolidate", "briefing for".
---

# Vault

Searches and retrieves notes from the Obsidian vault at `~/vault`.

## Before searching

Always re-index first so new notes are found:

```bash
qmd update -c vault && qmd embed 2>/dev/null
```

## Search strategies

### Semantic search (default, recommended)

Use qmd for topic/meaning searches. Returns relevant snippets, not whole files.

```bash
qmd search -c vault "search term"          # BM25 keyword (fast, exact)
qmd vsearch -c vault "search term"         # Vector semantic (finds related concepts)
qmd query -c vault "search term"           # Hybrid: BM25 + vector + reranking (best quality)
```

Use `--json` or `--files` for structured output. Use `-n 10` to get more results.

### Exact match (when you know the words)
```bash
rg -l "exact phrase" ~/vault --type md
```

### By filename
```bash
find ~/vault -name "*slug*" -not -path "*/.obsidian/*" -not -path "*/templates/*"
```

### By folder
```bash
ls ~/vault/blog/drafts/
ls ~/vault/inbox/
ls ~/vault/projects/fullfabric/
ls ~/vault/learning/til/
```

### By tag
```bash
rg -l "tags:.*search_tag" ~/vault --type md
```

### By recency
```bash
find ~/vault -name "*.md" -not -path "*/.obsidian/*" -not -path "*/templates/*" -mtime -7 | sort
```

### By links (notes that reference a topic)
```bash
rg -l "\[\[slug-or-title\]\]" ~/vault --type md
```

## Output modes

### Quick list (default for broad searches)

List matching notes with a one-line description each. Ask which ones to dive into.

### Consolidate (for blog prep and deep retrieval)

When the user asks for "everything about", "briefing for", "consolidate", or is clearly preparing to write, do a deep search:

1. **Search everywhere.** Use `qmd query` first, then complement with `rg` and folder listing. Cast a wide net
2. **Read all matches.** Don't just list filenames. Read the actual content
3. **Follow the links.** If notes have `[[links]]`, read those too
4. **Build a briefing.** Synthesize everything into a single consolidated view:

```markdown
## Briefing: {topic}

### Outline
{the draft outline if one exists, or a summary of the main idea}

### Key points collected
- {point from note 1}
- {point from TIL}
- {point from inbox note}

### Code sketches
{any code examples found across notes}

### Open questions
{things mentioned but not resolved}

### Sources
- `blog/drafts/slug.md` (outline)
- `learning/til/related-thing.md` (TIL)
- `inbox/random-thought.md` (captured insight)
```

This briefing is what the user takes to Curupira (localhost:4000) to start writing. It must be a useful map, not a dump of raw notes.

## Writing style

Follow the user's voice in all output. Informal, direct, no AI-speak, no em dashes. See the `/note` skill for full style guide.

## Vault structure

```
~/vault/
  inbox/              Quick captures, unprocessed
  blog/drafts/        Blog post outlines
  blog/published/     Published post references
  blog/ideas.md       Blog idea backlog
  learning/til/       Today I Learned
  projects/           Per-project notes (fullfabric, mendio, etc)
  references/         Tools, links, useful info
  sessions/           Session logs
  templates/          Note templates
```
