---
name: wtf
description: Learn a subject on demand, problem first. Takes a prompt, link, snippet, screenshot or a previous masterclass and teaches it as a quick one-shot, a single topic, or a multi-topic class with quizzes and a deterministic score. Runs in the terminal, ships an HTML page in the vault at the end. Use when the user says "wtf", "wtf quick", "wtf topic", "wtf class", "me explica", "quero aprender", "what is", "how does X work", "masterclass", "teach me".
argument-hint: '[quick|topic|class] <prompt, link, snippet, screenshot or masterclass folder>'
---

# wtf

Problem first, then the name of the solution. Always. The user thinks about the problem before
seeing what solves it. Voice, topic anatomy and quiz rules live in `references/`; read each one
at the step that needs it, not all up front.

**Language.** The class runs in the language of the user's prompt. pt-BR prompt, pt-BR class
(English jargon stays English). English prompt, English class. Never mix within a class.

## Modes

| Mode | Shape | Quiz |
|---|---|---|
| `quick` | one shot, no plan, no state on disk unless asked to save | no |
| `topic` | one topic, full anatomy | yes |
| `class` | plan of 2-6 topics, each a `topic` | per topic |

`/wtf quick|topic|class <input>` sets the mode. Without it, infer: a term or "what is X" leans
quick; "how does X work" leans topic; a broad area, a long link, or a previous masterclass leans
class. When two readings are plausible, ask in Intake.

## Loop

1. **Intake.** The input can be a prompt, a link, a snippet, a screenshot of a conversation, a
   file. Read it, state in one line what you took as the subject and the claim (quote the
   source when it is a screenshot) so the user can correct it. Identify the subject, the
   problems it solves, its sub-subjects and what comes before it. Keep that map to ~8 lines. If the input carries a claim, check it against a
   source before accepting it and say so in one line when the source disagrees. Pragmatic, not
   contrarian. Batch every question into ONE `AskUserQuestion`: mode (if ambiguous), example
   language (only when the subject has code), prerequisites the user may already know.
2. **Scout + research**, two agents in one message, in parallel.
   - scout: `qmd search -c vault "<subject>"` for prior TILs and masterclasses
     (`~/vault/learning/wtf/*/masterclass.json`), plus the current repo when the input points at
     code here. Returns paths and five lines on what exists.
   - research: WebSearch, then WebFetch the top hits. Returns only URLs whose content it read,
     one line each on what they contribute, plus 1-3 book candidates with a fetched URL.
   - `quick` skips the agents: 1-3 WebFetch inline. A prior masterclass on the subject: offer to
     continue from its follow-ups.
3. **Plan** (topic and class). Always shown, always short: one line per topic,
   `NN. title: the problem it solves`, plus the prerequisites assumed. Under 12 lines. The user
   edits or approves. Then create the state (see State) and fill `plan`, `map`, `sources`.
4. **Topic.** Read `references/voice.md` and `references/topic.md`. Write
   `<folder>/NN-<topic>.md`, run every snippet before pasting its output, and reply with the
   file content. Nothing else in that reply.
5. **Pause.** One line: deepen a term, start the quiz, or say anything. Wait. Any free input is
   one of three things; say which in one line, then act:
   - margin note: record it (`wtf.py note`) or answer inline, plan unchanged
   - question: answer short, plan unchanged
   - change of course: replan the remaining topics (research again when needed), show the plan
     as before → then, wait for approval
6. **Quiz.** Read `references/quiz.md`. Write `NN-<topic>.quiz.json` with rubrics BEFORE asking
   anything. One question per turn. Record each answer with `wtf.py answer`. Show the score only
   at the end, via `wtf.py score <slug> <topic>`.
7. **Path.** Report the score line and the suggestion the script printed. The user picks: next
   topic, stop, or a note for a spin-off. Never advance on your own.
8. **End.** Books for the class as a whole. Offer in one line: `wtf.py build` for the HTML, and
   `qmd update -c vault` so the folder is indexed.

## State

```
python3 ~/.claude/skills/wtf/wtf.py new <slug> --title "..." --mode class --lang pt-BR --input "..."
```

creates `~/vault/learning/wtf/<slug>/masterclass.json`, the source of truth. Topic `.md` and
`.quiz.json` files sit next to it; `masterclass.html` is built from them. Edit `plan`, `map`,
`sources`, `books` in the json directly; use the script for answers, scores, notes and build.
After a context compaction, re-read `masterclass.json` and the last topic before continuing.
A finished folder is a valid input: `/wtf ~/vault/learning/wtf/<slug>/` continues from its
follow-ups.

## Commands

A word is a command only when it is the whole message.

| Input | Action |
|---|---|
| `?` | where we are: topic N of M, what is pending, three lines |
| `plan` / `plano` | the plan with a status per topic |
| `quiz` | start the quiz for the current topic |
| `skip` / `pular` | skip the current question, counts as zero |
| `term <x>` / `termo <x>` | 3-6 lines on the term, problem first |
| `note <x>` / `nota <x>` | record a follow-up for a future `/wtf` |
| `html` | build the page and print its path |
| `end` / `fim` | close the class: score table, books, html offer |

## Iron rules

- Problem before solution, in every topic and in `quick`. Name the solution only after the
  problem has an example.
- No prose, no slogans, no marketing, no "it's not X, it's Y", no analogies. When a thing is
  abstract enough to need one, one sentence, computing-only.
- A reference is a URL a WebFetch returned content from in this session, or the book or
  document the user handed over (photo, PDF, file), cited with chapter or page. Nothing else.
  A book as input still gets one fetched source to confront it.
- Proof is real: snippet output is run and pasted; a number comes from a fetched source or a
  calculation shown. Code is not mandatory. A subject without code gets no invented snippet.
- Terms and acronyms get one line on first use. Notation is read symbol by symbol when it
  appears.
- The hook to the next topic states the next problem, never the next solution's name.
- Score is arithmetic in `wtf.py`. Rubrics are written before the answer. Skips count as zero.
- A topic is not an article. Caps live in `references/topic.md`.
- The method is the user's, the register is neutral: no catchphrases, no reader-in-blockquote,
  no interjections.
