#!/usr/bin/env python3
"""wtf: state, deterministic score and HTML build for a masterclass.

Stdlib only. Root is ~/vault/learning/wtf/<slug>/ (override with WTF_ROOT).

    wtf.py new <slug> --title T --mode quick|topic|class --lang pt-BR|en [--input TEXT]
    wtf.py answer <slug> <topic> <qid> (--choice N | --choices N,N | --hits N,N [--text T] | --skip)
    wtf.py score <slug> [<topic>]
    wtf.py note <slug> <text>
    wtf.py build <slug>

Files in the folder:
    masterclass.json        meta, plan, sources, books, followups, scores
    NN-<topic>.md           topic content (markdown, written by the agent)
    NN-<topic>.quiz.json    questions, rubrics and recorded answers
    masterclass.html        built page
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import sys
from html import escape
from pathlib import Path

KIT = Path(__file__).resolve().parent
ROOT = Path(os.environ.get("WTF_ROOT", Path.home() / "vault" / "learning" / "wtf"))

NEXT, REVIEW, REDO = "next", "review", "redo"
LABELS = {
    "en": {"quiz": "Quiz", "sources": "References", "books": "Books", "followups": "Follow-ups"},
    "pt": {"quiz": "Quiz", "sources": "Referências", "books": "Livros", "followups": "Próximos passos"},
}


def labels(lang: str) -> dict:
    return LABELS["pt" if lang.lower().startswith("pt") else "en"]


# --- state -------------------------------------------------------------------

def folder(slug: str) -> Path:
    return ROOT / slug


def load(path: Path) -> dict:
    return json.loads(path.read_text())


def save(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def meta_path(slug: str) -> Path:
    return folder(slug) / "masterclass.json"


def quiz_path(slug: str, topic: str) -> Path:
    return folder(slug) / f"{topic}.quiz.json"


def topics(slug: str) -> list[str]:
    return sorted(p.stem for p in folder(slug).glob("*.md") if p.stem != "masterclass")


def cmd_new(args) -> None:
    dest = folder(args.slug)
    dest.mkdir(parents=True, exist_ok=True)
    path = meta_path(args.slug)
    if path.exists():
        sys.exit(f"{path} already exists")
    save(path, {
        "slug": args.slug,
        "title": args.title,
        "mode": args.mode,
        "lang": args.lang,
        "created": dt.date.today().isoformat(),
        "input": args.input or "",
        "map": {"prerequisites": [], "subtopics": []},
        "plan": [],
        "sources": [],
        "books": [],
        "followups": [],
        "scores": {},
    })
    print(dest)


def cmd_note(args) -> None:
    meta = load(meta_path(args.slug))
    meta["followups"].append(args.text)
    save(meta_path(args.slug), meta)
    print(f"followups: {len(meta['followups'])}")


# --- answers and score -------------------------------------------------------

def parse_ints(csv: str | None) -> list[int]:
    return [int(x) for x in csv.split(",")] if csv else []


def cmd_answer(args) -> None:
    path = quiz_path(args.slug, args.topic)
    quiz = load(path)
    question = next((q for q in quiz["questions"] if q["id"] == args.qid), None)
    if question is None:
        sys.exit(f"no question {args.qid} in {path}")
    if args.skip:
        answer = {"skip": True}
    elif question["type"] == "choice":
        answer = {"choice": args.choice}
    elif question["type"] == "multi":
        answer = {"choices": parse_ints(args.choices)}
    else:
        answer = {"hits": parse_ints(args.hits), "text": args.text or ""}
    question["answer"] = answer
    save(path, quiz)
    answered = sum(1 for q in quiz["questions"] if "answer" in q)
    print(f"{answered}/{len(quiz['questions'])} answered")


def points(question: dict) -> float:
    answer = question.get("answer")
    if not answer or answer.get("skip"):
        return 0.0
    kind = question["type"]
    if kind == "choice":
        return 1.0 if answer.get("choice") == question["correct"] else 0.0
    if kind == "multi":
        correct, chosen = set(question["correct"]), set(answer.get("choices", []))
        hits, wrong = len(correct & chosen), len(chosen - correct)
        return max(0.0, (hits - wrong) / len(correct))
    rubric = set(range(len(question["rubric"])))
    return len(rubric & set(answer.get("hits", []))) / len(rubric)


def suggest(ratio: float) -> str:
    if ratio >= 0.8:
        return NEXT
    if ratio >= 0.5:
        return REVIEW
    return REDO


def topic_score(slug: str, topic: str) -> dict:
    path = quiz_path(slug, topic)
    if not path.exists():
        return {"score": 0, "total": 0, "answered": 0, "skipped": 0, "suggest": None}
    questions = load(path)["questions"]
    total = len(questions)
    score = sum(points(q) for q in questions)
    skipped = sum(1 for q in questions if q.get("answer", {}).get("skip"))
    answered = sum(1 for q in questions if "answer" in q)
    return {
        "score": round(score, 2),
        "total": total,
        "answered": answered,
        "skipped": skipped,
        "suggest": suggest(score / total) if total else None,
    }


def fmt(row: dict) -> str:
    if not row["total"]:
        return "no quiz"
    pct = round(100 * row["score"] / row["total"])
    return f"{row['score']:g}/{row['total']}  {pct}%  {row['suggest']}  (skipped {row['skipped']})"


def cmd_score(args) -> None:
    meta = load(meta_path(args.slug))
    names = [args.topic] if args.topic else topics(args.slug)
    for name in names:
        row = topic_score(args.slug, name)
        meta["scores"][name] = row
        print(f"{name:<32} {fmt(row)}")
    save(meta_path(args.slug), meta)
    if not args.topic:
        rows = [meta["scores"][n] for n in names if meta["scores"][n]["total"]]
        score, total = sum(r["score"] for r in rows), sum(r["total"] for r in rows)
        if total:
            print(f"{'class':<32} {score:g}/{total}  {round(100 * score / total)}%")


# --- markdown subset ---------------------------------------------------------

INLINE_CODE = re.compile(r"`([^`]+)`")
BOLD = re.compile(r"\*\*(.+?)\*\*")
ITALIC = re.compile(r"(?<![\w*])[*_](?![*_\s])(.+?)(?<![\s*_])[*_](?![\w*])")
LINK = re.compile(r"\[([^\]]+)\]\((https?://[^)\s]+)\)")
TERM_LINE = re.compile(r"^\s*[-*]\s+\*\*(.+?)\*\*\s*[:.]\s*(.+)$")
TAG_SPLIT = re.compile(r"(<[^>]+>)")


def inline(text: str) -> str:
    text = escape(text, quote=False)
    codes: list[str] = []

    def stash(match: re.Match) -> str:
        codes.append(f"<code>{match.group(1)}</code>")
        return f"\x00{len(codes) - 1}\x00"

    text = INLINE_CODE.sub(stash, text)
    text = LINK.sub(r'<a href="\2" target="_blank" rel="noopener">\1</a>', text)
    text = BOLD.sub(r"<strong>\1</strong>", text)
    text = ITALIC.sub(r"<em>\1</em>", text)
    return re.sub(r"\x00(\d+)\x00", lambda m: codes[int(m.group(1))], text)


def collect_terms(md: str) -> dict[str, str]:
    terms = {}
    for line in md.splitlines():
        match = TERM_LINE.match(line)
        if match:
            terms[match.group(1).strip()] = match.group(2).strip()
    return terms


def tooltip(html: str, terms: dict[str, str], seen: set[str]) -> str:
    """Wrap the first occurrence of each term (outside tags) in a tooltip span."""
    parts = TAG_SPLIT.split(html)
    for term, tip in terms.items():
        if term in seen:
            continue
        pattern = re.compile(rf"(?<!\w){re.escape(escape(term, quote=False))}(?!\w)", re.I)
        for index, part in enumerate(parts):
            if part.startswith("<") or not pattern.search(part):
                continue
            span = f'<span class="term" tabindex="0" data-tip="{escape(tip)}">\\g<0></span>'
            parts[index] = pattern.sub(span, part, count=1)
            seen.add(term)
            break
    return "".join(parts)


def md_to_html(md: str, terms: dict[str, str]) -> tuple[str, str]:
    """Return (title, body_html). The first H1 is the title and leaves the body."""
    lines = md.splitlines()
    out: list[str] = []
    para: list[str] = []
    seen: set[str] = set()
    title = ""

    def flush() -> None:
        if para:
            out.append(f"<p>{tooltip(inline(' '.join(para)), terms, seen)}</p>")
            para.clear()

    index = 0
    while index < len(lines):
        line = lines[index]
        if line.startswith("```"):
            flush()
            lang = line[3:].strip()
            block: list[str] = []
            index += 1
            while index < len(lines) and not lines[index].startswith("```"):
                block.append(lines[index])
                index += 1
            cls = f' class="lang-{escape(lang)}"' if lang else ""
            out.append(f"<pre><code{cls}>{escape(chr(10).join(block))}</code></pre>")
        elif (heading := re.match(r"^(#{1,6})\s+(.*)", line)):
            flush()
            level = len(heading.group(1))
            if level == 1 and not title:
                title = heading.group(2).strip()
            else:
                out.append(f"<h{level + 1}>{inline(heading.group(2))}</h{level + 1}>")
        elif line.startswith(">"):
            flush()
            quote: list[str] = []
            while index < len(lines) and lines[index].startswith(">"):
                quote.append(lines[index].lstrip("> "))
                index += 1
            out.append(f"<blockquote><p>{inline(' '.join(quote))}</p></blockquote>")
            continue
        elif re.match(r"^\s*([-*]|\d+\.)\s+", line):
            flush()
            ordered = bool(re.match(r"^\s*\d+\.", line))
            items: list[str] = []
            while index < len(lines) and re.match(r"^\s*([-*]|\d+\.)\s+", lines[index]):
                items.append(re.sub(r"^\s*([-*]|\d+\.)\s+", "", lines[index]))
                index += 1
            tag = "ol" if ordered else "ul"
            out.append(f"<{tag}>" + "".join(f"<li>{inline(i)}</li>" for i in items) + f"</{tag}>")
            continue
        elif line.strip() in ("---", "***"):
            flush()
            out.append("<hr>")
        elif not line.strip():
            flush()
        else:
            para.append(line.strip())
        index += 1
    flush()
    return title, "\n".join(out)


# --- build -------------------------------------------------------------------

def render_question(question: dict) -> str:
    answer = question.get("answer")
    kind = question["type"]
    skipped = not answer or answer.get("skip")
    earned = points(question)
    status = "skipped" if skipped else f"{earned:g}/1"
    cls = "skip" if skipped else ("ok" if earned >= 1 else ("part" if earned > 0 else "miss"))
    parts = [f'<div class="q {cls}"><div class="q-head"><span class="q-text">{inline(question["text"])}</span>'
             f'<span class="q-status">{status}</span></div>']
    if kind in ("choice", "multi"):
        correct = {question["correct"]} if kind == "choice" else set(question["correct"])
        picked = set() if skipped else (
            {answer.get("choice")} if kind == "choice" else set(answer.get("choices", [])))
        parts.append("<ol class='opts'>")
        for i, option in enumerate(question["options"]):
            flags = " ".join(f for f, on in (("correct", i in correct), ("picked", i in picked)) if on)
            parts.append(f'<li class="{flags}">{inline(option)}</li>')
        parts.append("</ol>")
    else:
        hits = set() if skipped else set(answer.get("hits", []))
        text = "" if skipped else answer.get("text", "")
        if text:
            parts.append(f'<blockquote class="yours"><p>{inline(text)}</p></blockquote>')
        parts.append("<ul class='rubric'>")
        for i, item in enumerate(question["rubric"]):
            parts.append(f'<li class="{"hit" if i in hits else "nohit"}">{inline(item)}</li>')
        parts.append("</ul>")
    if question.get("why"):
        parts.append(f'<p class="why">{inline(question["why"])}</p>')
    parts.append("</div>")
    return "\n".join(parts)


def render_topic(slug: str, name: str, number: int, lang: str) -> tuple[str, str]:
    md = (folder(slug) / f"{name}.md").read_text()
    terms = collect_terms(md)
    title, body = md_to_html(md, terms)
    title = title or name
    row = topic_score(slug, name)
    html = [f'<article id="{escape(name)}"><header class="t-head"><span class="t-num">{number:02d}</span>'
            f"<h2>{inline(title)}</h2></header>", body]
    path = quiz_path(slug, name)
    if path.exists():
        html.append(f'<section class="quiz"><h3>{labels(lang)["quiz"]} <span class="score">{fmt(row)}</span></h3>')
        html.extend(render_question(q) for q in load(path)["questions"])
        html.append("</section>")
    html.append("</article>")
    return title, "\n".join(html)


def cmd_build(args) -> None:
    meta = load(meta_path(args.slug))
    lang = meta.get("lang", "en")
    names = topics(args.slug)
    nav, articles = [], []
    for number, name in enumerate(names, 1):
        title, html = render_topic(args.slug, name, number, lang)
        nav.append(f'<li><a href="#{escape(name)}"><span>{number:02d}</span> {inline(title)}</a></li>')
        articles.append(html)
    rows = [topic_score(args.slug, n) for n in names]
    score = sum(r["score"] for r in rows)
    total = sum(r["total"] for r in rows)
    badge = f"{score:g}/{total}" if total else "no quiz"
    sources = "".join(
        f'<li><a href="{escape(s["url"])}" target="_blank" rel="noopener">{inline(s.get("title") or s["url"])}</a></li>'
        for s in meta.get("sources", []) if s.get("read", True))
    books = "".join(
        f'<li>{inline(b.get("author", ""))}, <em>{inline(b["title"])}</em>'
        + (f' <a href="{escape(b["url"])}" target="_blank" rel="noopener">↗</a>' if b.get("url") else "")
        + "</li>" for b in meta.get("books", []))
    followups = "".join(f"<li>{inline(f)}</li>" for f in meta.get("followups", []))
    page = (KIT / "template.html").read_text()
    for key, value in {
        "TITLE": escape(meta["title"]),
        "LANG": escape(lang),
        "MODE": escape(meta["mode"]),
        "DATE": escape(meta["created"]),
        "INPUT": inline(meta.get("input", "")),
        "BADGE": badge,
        "NAV": "".join(nav),
        "TOPICS": "\n".join(articles),
        "SOURCES": sources or "<li>—</li>",
        "BOOKS": books or "<li>—</li>",
        "FOLLOWUPS": followups,
        "FOLLOWUPS_HIDDEN": "" if followups else " hidden",
        **{f"L_{k.upper()}": v for k, v in labels(lang).items()},
    }.items():
        page = page.replace("{{" + key + "}}", value)
    out = folder(args.slug) / "masterclass.html"
    out.write_text(page)
    print(f"{out} ({out.stat().st_size // 1024} KB, {len(names)} topics)")


# --- cli ---------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)

    new = sub.add_parser("new")
    new.add_argument("slug")
    new.add_argument("--title", required=True)
    new.add_argument("--mode", choices=["quick", "topic", "class"], required=True)
    new.add_argument("--lang", required=True)
    new.add_argument("--input")
    new.set_defaults(fn=cmd_new)

    answer = sub.add_parser("answer")
    answer.add_argument("slug")
    answer.add_argument("topic")
    answer.add_argument("qid")
    answer.add_argument("--choice", type=int)
    answer.add_argument("--choices")
    answer.add_argument("--hits")
    answer.add_argument("--text")
    answer.add_argument("--skip", action="store_true")
    answer.set_defaults(fn=cmd_answer)

    score = sub.add_parser("score")
    score.add_argument("slug")
    score.add_argument("topic", nargs="?")
    score.set_defaults(fn=cmd_score)

    note = sub.add_parser("note")
    note.add_argument("slug")
    note.add_argument("text")
    note.set_defaults(fn=cmd_note)

    build = sub.add_parser("build")
    build.add_argument("slug")
    build.set_defaults(fn=cmd_build)

    args = parser.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
