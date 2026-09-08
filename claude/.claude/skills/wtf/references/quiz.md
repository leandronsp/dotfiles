# Quiz

Off by default. The socratic dialogue already shows what the user understands, so a quiz after
it is redundant. Run this only when the user asks (`quiz`), or when a `class` is closing and
the user wants a score.

Goal: an honest measure of what stuck, then a path. The agent writes the questions and the
rubrics; the script does the arithmetic and the suggestion.

## Before asking

Write `NN-<topic>.quiz.json` in full, rubrics included, before the first question goes out.
Tell the user the total up front ("6 questions, skip allowed"). Never show the running score.

```json
{"questions": [
  {"id": "q1", "type": "choice", "text": "...", "options": ["...", "...", "..."], "correct": 1,
   "why": "one line shown in the HTML after the answer"},
  {"id": "q2", "type": "multi", "text": "...", "options": ["...", "...", "..."], "correct": [0, 2],
   "why": "..."},
  {"id": "q3", "type": "free", "text": "...", "rubric": ["key point 1", "key point 2"],
   "why": "..."}
]}
```

- 4-8 questions, never more than 10. Mix the three types. At least one `free`.
- Questions come from the topic content: the problem, why the solution fits, what the snippet
  output shows, one term. No trivia the topic did not cover.
- `free` accepts text, a screenshot, a pasted command output. The rubric lists 2-4 key points a
  correct answer must contain. Write them as facts, not as words to match.
- Options for `choice`/`multi`: 3-4, plausible, one idea each. No "all of the above".

## Asking

- `choice` and `multi`: `AskUserQuestion`, options from the json in the same order, plus a
  last option "skip". `multi` uses multiSelect.
- `free`: ask in the chat, one question, then wait.
- One question per turn. No feedback between questions beyond "recorded" or a one-line
  clarification when the user asks.

## Recording

```
python3 ~/.claude/skills/wtf/wtf.py answer <slug> <topic> q1 --choice 1
python3 ~/.claude/skills/wtf/wtf.py answer <slug> <topic> q2 --choices 0,2
python3 ~/.claude/skills/wtf/wtf.py answer <slug> <topic> q3 --hits 0,1 --text "user's answer"
python3 ~/.claude/skills/wtf/wtf.py answer <slug> <topic> q4 --skip
```

For `free`, `--hits` lists the rubric indexes the answer actually covers. Judge each rubric
item on its own, against what the user wrote, not against what they probably meant. A
screenshot counts when it shows the fact. Partial is fine, generous is not.

## Scoring (in wtf.py, not in your head)

- `choice`: 1 or 0.
- `multi`: (hits − wrong picks) / correct count, floored at 0.
- `free`: covered rubric items / rubric size.
- skip: 0, still counted in the total.

`wtf.py score <slug> <topic>` prints `score/total  pct  suggestion  (skipped n)`.

| pct | suggestion | what to say |
|---|---|---|
| ≥ 80 | next | ready for the next topic |
| 50-79 | review | list the missed terms or rubric items, then next |
| < 50 | redo | redo the topic, or spin off a `/wtf` on the weakest part |

Report the line as printed, then the user picks. The suggestion is a suggestion.

## After the quiz

Answer any "why did I miss q2" in three lines, from the `why` field and the topic text. Then
the path: next topic, stop, or `note <x>`.
