#!/usr/bin/env python3
"""Collapse pstack's 21 principle-* skill dirs into one `principles` skill.

Each leaf becomes skills/principles/<slug>.md, keeping its body verbatim and
carrying its frontmatter description forward as the "Apply when" line the
router's index used to hold. Cross-links between principles are rewritten from
../principle-<slug>/SKILL.md to the sibling <slug>.md.
"""

import re
import sys
from pathlib import Path

REPO = Path("/home/mavee/my-skills")
SRC = REPO / "sources/pstack/skills"
DEST = REPO / "skills/principles"

# Grouping is pstack's own, taken from poteto-mode/SKILL.md's Principles index.
GROUPS = [
    ("Core", [
        "laziness-protocol", "foundational-thinking",
        "redesign-from-first-principles", "subtract-before-you-add",
        "minimize-reader-load", "outcome-oriented-execution",
        "experience-first", "exhaust-the-design-space", "build-the-lever",
    ]),
    ("Architecture", [
        "model-the-domain", "boundary-discipline", "type-system-discipline",
        "make-operations-idempotent",
        "migrate-callers-then-delete-legacy-apis",
        "separate-before-serializing-shared-state",
    ]),
    ("Verification", [
        "prove-it-works", "fix-root-causes", "sequence-verifiable-units",
    ]),
    ("Delegation", [
        "guard-the-context-window", "never-block-on-the-human",
    ]),
    ("Meta", [
        "encode-lessons-in-structure",
    ]),
]


def split_frontmatter(text: str) -> tuple[dict[str, str], str]:
    assert text.startswith("---"), "no frontmatter"
    end = text.index("\n---", 3)
    fm = {}
    for line in text[3:end].splitlines():
        key, sep, value = line.partition(":")
        if sep:
            v = value.strip()
            if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
                v = v[1:-1]
            fm[key.strip()] = v
    return fm, text[end + 4:].lstrip("\n")


def main() -> int:
    DEST.mkdir(parents=True, exist_ok=True)
    all_slugs = [s for _, slugs in GROUPS for s in slugs]

    found = sorted(p.name[len("principle-"):] for p in SRC.glob("principle-*"))
    if set(found) != set(all_slugs):
        print(f"error: group table does not match disk", file=sys.stderr)
        print(f"  only on disk:  {sorted(set(found) - set(all_slugs))}", file=sys.stderr)
        print(f"  only in table: {sorted(set(all_slugs) - set(found))}", file=sys.stderr)
        return 1

    descriptions: dict[str, str] = {}
    titles: dict[str, str] = {}

    for slug in all_slugs:
        src = SRC / f"principle-{slug}" / "SKILL.md"
        fm, body = split_frontmatter(src.read_text(encoding="utf-8"))
        descriptions[slug] = fm["description"]

        m = re.match(r"#\s+(.+)", body)
        titles[slug] = m.group(1).strip() if m else slug

        # ../principle-foo/SKILL.md -> foo.md  (siblings now, not skills)
        body = re.sub(r"\.\./principle-([a-z0-9-]+)/SKILL\.md", r"\1.md", body)

        # Lead with when it applies, which is what the frontmatter carried.
        body = re.sub(
            r"^#\s+(.+?)\n+",
            lambda m: f"# {m.group(1).strip()}\n\n*{descriptions[slug]}*\n\n",
            body,
            count=1,
        )
        (DEST / f"{slug}.md").write_text(body.rstrip() + "\n", encoding="utf-8")

    # The index. Kept short: it routes, the leaves do the teaching.
    out = [
        "---",
        "name: principles",
        'description: "Twenty-one atomic engineering principles, each naming when it '
        "applies. Use when a decision needs grounding: sizing a diff, choosing types, "
        "designing a boundary, debugging, delegating, or declaring work done. Read the "
        'named leaf in full before citing it."',
        "---",
        "",
        "# Principles",
        "",
        "Twenty-one rules, each small enough to hold in your head and specific enough",
        "to change a decision. Every entry names the situation it applies to.",
        "",
        "**Read the leaf in full before you cite it.** A citation with no decision",
        "behind it means you skipped the file. It has to trace to a real choice the",
        "leaf's rule drove.",
        "",
    ]
    for group, slugs in GROUPS:
        out.append(f"## {group}")
        out.append("")
        for slug in slugs:
            out.append(f"- **[{titles[slug]}]({slug}.md)**. {descriptions[slug]}")
        out.append("")

    (DEST / "SKILL.md").write_text("\n".join(out).rstrip() + "\n", encoding="utf-8")
    print(f"wrote {len(all_slugs)} principles + index to {DEST.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
