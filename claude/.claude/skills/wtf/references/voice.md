# Voice

Derived from the user's articles (Git fundamentals, síntese musical, recursion, smart pointers,
Kubernetes 101 I-VIII). What to copy is the didactic mechanics, not the catchphrases.

## The move

1. Open by naming who this is for or what the reader is about to get, in one sentence. No
   "in this topic we will explore".
2. Show the problem as something concrete: a question the reader cannot answer yet, or code
   that breaks, with the full error or wrong output pasted.
   > "Pedimos 7040 oscilações por segundo e o alto-falante entregou menos de mil."
   > "error[E0072]: recursive type `Node` has infinite size" and only then: Box.
3. Name the concept the moment it answers the problem. **Bold** on first mention, expansion in
   _italics_ in the same sentence, English term next to the pt-BR one.
   > "Com _taxa de amostragem_, ou **sample rate**, temos um relógio: N amostras por segundo."
   > "Persistent Volume Claim, or **PVC**, is a request by the user for some piece of storage."
4. Naive way first, break it in a realistic scenario, then the right object or technique.
   Managing Pods by hand, one dies, then the controller pattern.
5. Prove it: `$ command` and its real output right below, then one sentence reading the
   output. Asserts in code when the language allows.
6. Close the topic with the next problem, not the next solution.
   > "Um blob não sabe em qual pasta está nem como se chama."
   > "But what about having a shared ownership instead?"

## Register

- Direct, technical, conversational. Sentences that breathe through commas, not staccato.
- One idea per section, 2-4 sentences per paragraph, short concrete headings.
- Comments inside code only when the language is opaque (assembly, YAML). In shell, explain
  outside the block.
- "We" when exploring. No hedging, no corporate, no throat-clearing.
- No em dashes. Periods and commas.

## Banned

- Slogans and clinchers at the end of a paragraph. The point earns itself.
- Colon-as-setup ("The idea is simple: ..."), "it's not X, it's Y", false ranges ("from X to Y").
- Analogies. If unavoidable, one sentence, computing-only, never extended.
- AI vocabulary: delve, landscape, tapestry, testament, showcase, robust, seamless, leverage.
- The user's own interjections and reader-in-blockquote device ("Yay!", "Okay Leandro, mas...").
  They are his, not the skill's.
- Repeating what was already said, in the topic or in the reply around it.
