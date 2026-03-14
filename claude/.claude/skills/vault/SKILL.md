---
name: vault
description: Search and retrieve notes from the Obsidian vault. Use when the user wants to find notes, recall past ideas, get context on a topic, look up references, browse blog drafts, get live stream ideas, consolidate notes for writing, or load knowledge from their second brain into the conversation. Trigger on phrases like "check my notes", "what do I have on", "find in vault", "search notes", "load notes about", "bring me everything about", "consolidate", "briefing for", "ideia pra live", "what should I stream".
---

# Vault

Searches and retrieves notes from the Obsidian vault at `~/vault`.

## Before searching

Always re-index first so new notes are found:

```bash
qmd update -c vault && qmd embed 2>/dev/null
```

## Search strategy

**MANDATORY: Always use qmd as the primary search tool. Never skip qmd and go straight to rg or grep.**

### Step 1: qmd search (always do this first)

```bash
qmd query -c vault "search term"           # Hybrid: BM25 + vector + reranking (best quality, use by default)
qmd search -c vault "search term"          # BM25 keyword only (when you need exact term matches)
qmd vsearch -c vault "search term"         # Vector semantic only (when you need conceptual/related matches)
```

Use `--json` or `--files` for structured output. Use `-n 10` to get more results.

### Step 2: use qmd results directly

qmd returns snippets with context, scores, and titles. This is usually enough. **Do NOT read the full file after qmd unless you specifically need more context than the snippet provides.** Avoid duplicating work.

When to read the full file:
- Consolidate mode (building a briefing, need every detail)
- The snippet is clearly cut off mid-thought and you need the rest
- The user asks to see the full note

When NOT to read the full file:
- Quick list mode (qmd snippets are sufficient)
- The snippet already answers the user's question
- You just want to confirm what qmd already told you

### Step 3: complement with rg/find only if needed

Only use these when qmd misses something specific:

```bash
rg -l "exact phrase" ~/vault --type md                    # Exact string match
rg -l "tags:.*search_tag" ~/vault --type md               # By tag
rg -l "\[\[slug-or-title\]\]" ~/vault --type md           # By links
find ~/vault -name "*slug*" -not -path "*/.obsidian/*"    # By filename
ls ~/vault/blog/drafts/                                    # By folder
```

Do NOT run rg to confirm results qmd already found. That's redundant.

## Output modes

### Quick list (default for broad searches)

List matching notes with a one-line description each. Ask which ones to dive into.

### Live suggestion (for picking what to stream next)

When the user asks for live ideas, what to stream, or next live topic (e.g. "ideia pra live de hoje", "o que faço na live"):

1. **Read `lives/roadmap.md`** to see what's planned and what's already done (with dates)
2. **Check `lives/ideas.md`** for loose ideas in the backlog
3. **Consider sequence**: suggest topics that build on the last live done (check dates)
4. **Suggest top 3** with brief reasoning for each (why now, what builds on what)
5. **Don't be rigid**: the roadmap is a guide, not a script. The user may go off-plan

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
  tasks/              Task management (roadmap, sprint, pomodoro, routines)
  lives/              Live coding sessions (roadmap, ideas)
  templates/          Note templates
```
