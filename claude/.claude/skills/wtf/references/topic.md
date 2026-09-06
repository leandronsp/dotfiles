# Topic anatomy

One markdown file per topic: `~/vault/learning/wtf/<slug>/NN-<topic>.md`. The reply that
delivers the topic is the file content, nothing more. Section headings are in the class
language; the builder does not depend on their names.

````markdown
# NN. Title

## The problem
Concrete case with an example. A question the reader cannot answer yet, or a snippet that
breaks, with the real error or output pasted.

## <Concept name, as a heading>
**Concept** named in bold on first mention, expansion in _italics_ in the same sentence.
How it solves the problem above. Then the proof: a runnable snippet with its real output when
the subject is code, a measured number or a before → then from a fetched source when it is not.

```ruby
# snippet
```
```
$ command
output
```

## Terms
- **term**: one line, plain.
- **ACRONYM**: expansion, then what it is for.

## References
- [Title](https://url-you-fetched)

## Book
- Author, *Title*, chapter or part when it applies.

## Next
One or two sentences stating the next problem. Not the next solution's name.
````

## Caps

| | topic | quick |
|---|---|---|
| words (excluding code) | 350 | 200 |
| snippets (code subjects only) | 2, up to 30 lines each | 1, up to 30 lines |
| terms | 5 | 3 |
| references | 2-4 | 1-2 |
| book | 1 | 0-1 |

Over the cap: cut, do not compress. A topic that does not fit is two topics.

## Snippets

- Example language: the one the user picked in Intake. Shell is always allowed.
- When the language has a unit test library, the snippet is a test file: the implementation
  on top, then one test per method, each with the assertions that state what the method does.
  The test output is the proof. Ruby: Test::Unit (`assert_equal(expected, actual)`,
  `assert`, `refute`, `assert_raise`). Python: unittest. Go: testing. Rust: `#[test]`.
- Run it before pasting. `$ command` on the first line, output right below, in the same block.
- When it cannot run on this machine (cluster, GPU, paid API), say so under the block in one
  line and keep the expected output labelled as expected.
- Before → then when a change is the point: the naive version and its failure, then the fix and
  its output.

## Subjects without code

Physics, math, economics, a protocol spec, a paper, a screenshot of a conversation: same
anatomy, no forced snippet. The example in the problem is a concrete scenario with numbers.
The proof is something the user can check: a measurement from a fetched source, a calculation
shown step by step, a before → then with real values. Never invent a code example to have one.
When a formula or a rule of thumb appears, the reader can redo it by hand with the numbers
given.

## Math

Avoid notation in `quick` and `topic` unless the subject is math. When it appears, read every
symbol once, right after the formula, one symbol per line. Then the same thing as code.

## Markdown the builder relies on

- First `# H1` is the topic title. Use `##` for sections.
- `- **term**: text` items become tooltips on the term's first occurrence in the body.
- Fenced code with a language tag. Links as `[text](https://...)`.
- Paragraphs, lists, blockquotes, `---`. Nothing else (no tables, no HTML, no images).

## quick

Same anatomy without the file: problem with an example, the concept named, one snippet with
output, terms inline in parentheses, one reference. No plan, no quiz, no questions beyond the
Intake batch. Offer to save it to the vault only if the user asks for more.
