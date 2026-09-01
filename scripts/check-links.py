#!/usr/bin/env python3
"""Check every relative markdown link and script reference resolves.

A skill that points at a file which is not there fails silently: the model
reads the pointer, cannot follow it, and carries on with less than the skill
intended. That is worse than a hard error, so make it a hard error here.
"""

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
ROOTS = [REPO / "skills", REPO / "agents"]

# [text](target) where target is relative: no scheme, no anchor-only, no mailto
LINK = re.compile(r"\[[^\]]*\]\((?!https?://|#|mailto:)([^)\s]+)\)")
# `scripts/foo.sh` and similar inline code that names a path in this skill
CODEPATH = re.compile(r"`((?:scripts|references|playbooks)/[A-Za-z0-9_./-]+)`")

broken: list[str] = []
checked = 0


def rel(p: Path) -> str:
    return str(p.relative_to(REPO))


for root in ROOTS:
    if not root.is_dir():
        continue
    for md in sorted(root.rglob("*.md")):
        if md.name == "anthropic-best-practices.md":
            continue
        text = md.read_text(encoding="utf-8")
        targets = [(m.group(1), "link") for m in LINK.finditer(text)]
        targets += [(m.group(1), "path") for m in CODEPATH.finditer(text)]
        for target, kind in targets:
            clean = target.split("#", 1)[0]
            if not clean:
                continue
            # Template placeholders in prompt scaffolds: [text](link), [x](url).
            if "/" not in clean and "." not in clean:
                continue
            # Illustrative repo layouts inside format docs, web routes, not real targets.
            if clean.startswith("./src/") or clean.startswith("src/") or clean.startswith("/"):
                continue
            checked += 1
            resolved = (md.parent / clean).resolve()
            if resolved.exists():
                continue
            # A skill may reference a sibling skill's file by skill-relative
            # path, e.g. principles/prove-it-works.md from another skill.
            if (REPO / "skills" / clean).exists() or (REPO / clean).exists():
                continue
            skill_root = md.parent
            while skill_root != REPO and skill_root.parent != REPO / "skills":
                skill_root = skill_root.parent
            if (skill_root / clean).exists():
                continue
            broken.append(f"{rel(md)} -> {target}")

for b in broken:
    print(f"error: broken reference: {b}")

print(f"\nchecked {checked} references")
if broken:
    print(f"{len(broken)} broken")
    sys.exit(1)
print("ok")
