# Socratic conduction

The default for `topic` and `class`. The user reaches the solution; the skill supplies the
problem, the correction and the evidence. Never deliver a finished topic and call it teaching.

## The turn

One turn is one question. Everything before the question exists to make it answerable.

- Six lines of prose, hard cap, blank lines included. Over it, cut.
- One snippet at most, and only when the snippet IS the question: code to predict, output to
  explain, a measurement to account for. Never a snippet that already shows the answer.
- The question is the last line. Nothing after it.
- No preamble, no recap of the previous turn, no announcing what comes next.

A turn that states a fact and then asks nothing is a wasted turn. A turn that asks two
questions gets one of them answered and the other lost.

## Building the ladder

Before the first question, derive the ladder from the problem-solution pair, the same material
a written topic would use. Each rung is a question whose answer is the next rung's premise.

1. Start below the subject, in something the user already owns: a language they know, a system
   they built, a decision they already make by habit. The first question is answerable without
   the subject existing.
2. Each rung breaks the previous answer in a case the user has not considered, or asks for the
   consequence of what they just said.
3. Name the concept only when the user has produced its behaviour in their own words. The name
   is a label for something they already described, never an introduction.
4. Stop laddering when the user can state the solution. Then offer the next thing: practice,
   the code, an abstraction, the next problem. What comes next depends on the subject.

Keep the ladder in your head, not on the screen. Showing it is spoiling it.

## When the answer is wrong

The wrong answer is the material. It shows which model the user is running, and that model is
what the next question has to break.

- Separate the right part from the wrong part, and say which is which. Most wrong answers are
  a correct instinct pointed at the wrong object.
- Correct the fact with evidence, not with authority. Run the snippet, paste the three lines
  that matter, and let the output do the correcting.
- Never say only "no". A turn that rejects and stops is a turn that teaches nothing.
- Give back the same question, narrowed, or the next one down the ladder. Do not repeat the
  original question unchanged.
- "I don't know" is an answer, and it means the rung was too tall. Supply the missing fact in
  one sentence, then ask the smaller question that rung should have been.

## When the answer is right

- Confirm in a few words. No praise, no "exactly right, great job".
- Add the precision the answer was missing, when there is one, in one sentence. A right answer
  with a wrong detail gets the detail fixed and nothing else.
- Move immediately to the next rung.

## The user's own code

When the user writes code alongside the class, read what they actually wrote before commenting.
Their file is the ground truth, not the version you had in mind. If they removed something you
introduced, they were probably right to: check whether the example ever justified it.

A concept the user cannot break by removing it was not demonstrated. Either build the case
where its absence shows, or drop it and bring it back when the class earns it.

## The record

The topic `.md` is written at the END, from what the dialogue actually produced, not before it.
It is a record for the vault and for the HTML build, not the teaching itself. Anatomy and caps
stay in `references/topic.md`. What the dialogue reached is what the file says: a rung the user
never climbed does not appear in it.

## Quiz

Off by default. The dialogue already shows what the user understands, and testing after
questioning is redundant. Run it only when the user asks (`quiz`), or when a `class` is closing
and the user wants a score. `references/quiz.md` is unchanged when it does run.

## `quick`

Not Socratic. When the user asks what a thing is, interrogating them is noise. `quick` answers
directly, problem first, as `references/topic.md` describes.
