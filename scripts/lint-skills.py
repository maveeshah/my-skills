#!/usr/bin/env python3
"""Guard the invariants that make both install modes work.

The symlink install flattens every skill to ~/.claude/skills/<dirname>, so a
duplicate basename or a name that shadows a built-in silently breaks at load
time rather than here. Cursor-only frontmatter keys are inert in Claude Code
and are the clearest sign a file was copied but never ported.

    scripts/lint-skills.py          lint skills/ and agents/
    scripts/lint-skills.py --all    also lint parked/ (expected to fail)
"""

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# Shipped with Claude Code. A user skill of the same name collides.
BUILTIN_SKILLS = {
    "artifact-capabilities", "artifact-design", "artifact-diagramming",
    "claude-api", "claude-in-chrome", "code-review", "codebase-memory",
    "dataviz", "fewer-permission-prompts", "init", "keybindings-help",
    "loop", "run", "schedule", "security-review", "simplify", "update-config",
}

# Cursor plugin frontmatter. Inert here; presence means an unfinished port.
# Scoped per kind: `color` is Cursor-only in a SKILL.md but valid in an agent.
CURSOR_ONLY_SKILL = {"mode", "icon", "color", "reminder", "is_background"}
CURSOR_ONLY_AGENT = {"mode", "icon", "reminder", "is_background"}

# Honoured by Claude Code in a SKILL.md.
ALLOWED_SKILL_KEYS = {
    "name", "description", "disable-model-invocation", "argument-hint",
    "allowed-tools", "license", "metadata", "compatibility", "version",
    "user-invocable",
}
# Honoured in an agents/*.md. `color` is valid here, unlike in a SKILL.md.
ALLOWED_AGENT_KEYS = {
    "name", "description", "model", "effort", "tools", "color",
    "initialPrompt",
}

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")

errors: list[str] = []
warnings: list[str] = []


def parse_frontmatter(path: Path) -> dict[str, str] | None:
    """Return top-level key -> raw value. Good enough: these files are flat."""
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        errors.append(f"{rel(path)}: no YAML frontmatter")
        return None
    end = text.find("\n---", 3)
    if end == -1:
        errors.append(f"{rel(path)}: unterminated frontmatter")
        return None
    fm: dict[str, str] = {}
    for line in text[3:end].splitlines():
        if not line.strip() or line.startswith("#") or line[:1] in " \t-":
            continue
        key, sep, value = line.partition(":")
        if sep:
            fm[key.strip()] = value.strip()
    return fm


def rel(path: Path) -> str:
    return str(path.relative_to(REPO))


def unquote(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def check(
    path: Path,
    expected_name: str,
    allowed_keys: set[str],
    cursor_keys: set[str],
    kind: str,
) -> str | None:
    fm = parse_frontmatter(path)
    if fm is None:
        return None

    for key in sorted(set(fm) & cursor_keys):
        errors.append(f"{rel(path)}: Cursor-only key '{key}' survived the port")
    for key in sorted(set(fm) - allowed_keys - cursor_keys):
        warnings.append(f"{rel(path)}: unrecognised key '{key}'")

    name = unquote(fm.get("name", ""))
    if not name:
        errors.append(f"{rel(path)}: missing 'name'")
    else:
        if not NAME_RE.match(name):
            errors.append(f"{rel(path)}: name '{name}' is not kebab-case")
        if name != expected_name:
            errors.append(
                f"{rel(path)}: name '{name}' != {kind} basename '{expected_name}'"
            )

    desc = unquote(fm.get("description", ""))
    if not desc:
        errors.append(f"{rel(path)}: missing 'description'")
    else:
        if len(desc) > 1024:
            errors.append(f"{rel(path)}: description is {len(desc)} chars (max 1024)")
        if "<" in desc or ">" in desc:
            errors.append(f"{rel(path)}: description contains an angle bracket")

    return name or None


def main() -> int:
    roots = [REPO / "skills"]
    if "--all" in sys.argv:
        roots.append(REPO / "parked")

    seen: dict[str, str] = {}
    n_skills = 0
    for root in roots:
        if not root.is_dir():
            continue
        for skill_md in sorted(root.glob("*/SKILL.md")):
            n_skills += 1
            dirname = skill_md.parent.name
            name = check(skill_md, dirname, ALLOWED_SKILL_KEYS, CURSOR_ONLY_SKILL, "directory")
            if not name:
                continue
            if name in seen:
                errors.append(
                    f"{rel(skill_md)}: duplicate skill name '{name}' "
                    f"(also {seen[name]}); the symlink install flattens these"
                )
            seen[name] = rel(skill_md)
            if name in BUILTIN_SKILLS:
                errors.append(
                    f"{rel(skill_md)}: '{name}' shadows a built-in Claude Code skill"
                )

    n_agents = 0
    agents_dir = REPO / "agents"
    if agents_dir.is_dir():
        for agent_md in sorted(agents_dir.glob("*.md")):
            n_agents += 1
            check(agent_md, agent_md.stem, ALLOWED_AGENT_KEYS, CURSOR_ONLY_AGENT, "file")

    for w in warnings:
        print(f"warn:  {w}")
    for e in errors:
        print(f"error: {e}")

    print(f"\nchecked {n_skills} skills, {n_agents} agents")
    if errors:
        print(f"{len(errors)} error(s)")
        return 1
    print("ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
