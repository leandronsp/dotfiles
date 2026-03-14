---
name: brainstorm
description: Brainstorm blog post ideas and develop them into outlines ready to write in Curupira. Use when the user wants to explore topics for writing, flesh out a blog idea, find angles for a post, connect ideas from their vault, or think through what to write about. Trigger on phrases like "blog idea", "what should I write about", "brainstorm", "help me think about a post", "develop this idea".
---

# Brainstorm

Interactive brainstorming for blog posts. Helps the user go from vague idea to concrete outline that serves as a GUIDE for writing in the Curupira blog engine.

## The user's writing style

The user writes like a thoughtful senior engineer teaching peers. Know this before suggesting anything:

- Conversational tone. Confident enough to be casual, experienced enough to be clear
- "We" language in learning contexts. Creates partnership, not lecturing
- Problem-first teaching. Show the broken thing, then explain why, then fix it
- Code as primary source. Not snippets. Reproducible examples you can run
- Portuguese for opinion/leadership/process pieces. English for technical deep-dives
- Short punchy sentences. No filler. No corporate speak
- Never use em dashes. Periods to separate ideas
- Ends with warmth, never cold conclusions
- Strategic emoji in headers for visual rhythm (more in PT, less in EN)
- Topics: systems programming, concurrency, low-level, Ruby, Elixir, Rust, DevOps, infrastructure

The notes and outlines must match this voice. No formal academic tone. No AI-speak.

## The user's blog workflow

The user writes in Curupira (Elixir/Phoenix app at localhost:4000). The vault notes are REFERENCE MATERIAL, not the final article. Never write a full article in the vault. Write outlines, angles, key points, code sketches.

```
Brainstorm (vault) -> Outline (vault) -> Write in Curupira (localhost:4000) -> Export -> Deploy
```

## Steps

### 1. Gather context

Search the vault for existing material:

```bash
cat ~/vault/blog/ideas.md
ls ~/vault/blog/drafts/
rg -l "" ~/vault/learning/til/ --type md 2>/dev/null
rg -l "" ~/vault/references/ --type md 2>/dev/null
```

Also search for related TILs or project notes that could feed into the post.

### 2. Explore the idea

If the user has a topic in mind:

- What angle makes this interesting? What is the unique take?
- Who is the reader? Beginners? Experienced devs? Both?
- What is the one thing the reader takes away?
- Can we show a problem first, then solve it? (the user's signature pattern)
- What code examples would make this concrete and runnable?
- Does the vault have related notes?

If the user has no topic, suggest ideas based on:
- Recent TILs that could expand into posts
- Patterns across project notes
- Gaps in existing drafts
- Things the user has been working on lately

Push back on weak ideas. Ask "why would someone read this?" Challenge the user to find their unique angle.

### 3. Shape the outline

Once the idea has shape, propose:

- Title (2-3 options, in the right language)
- Hook (opening angle. problem-first when possible)
- Key sections with one-line descriptions
- Code examples or demos needed (specify language, what to show)
- Effort estimate (quick post vs deep dive)

The outline should be enough for the user to open Curupira and start writing. Not a full draft. A map.

### 4. Save

After brainstorming, offer two actions:

**Add to ideas backlog** (not ready yet):
Append a bullet to `~/vault/blog/ideas.md` under `## Backlog` with title, angle, and one-line summary.

**Create an outline** (ready to start writing):
Create `~/vault/blog/drafts/{slug}.md` with the outline, key points, code sketches, and references.

Always ask the user which one. Never create without confirmation.
