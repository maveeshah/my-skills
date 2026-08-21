# my-skills

A personal Claude Code skill system, merged from [poteto's pstack][pstack] and
[mattpocock/skills][matt]. Both are MIT; see [NOTICE.md](./NOTICE.md).

The two upstreams pull in different directions and that is the point of merging
them. pstack is autonomous execution: a sticky router over playbooks, parallel
subagents, 21 atomic principles, verify-against-the-real-artifact. Matt's set is
alignment and design: grill the plan before writing code, deep modules, a gated
diagnosis loop, review split into standards and spec. Neither is complete alone.

Where they overlapped, one skill replaced two rather than shipping both.

[pstack]: https://github.com/cursor/plugins/tree/main/pstack
[matt]: https://github.com/mattpocock/skills

## Layout

```
skills/      the installed set, one directory per skill
agents/      subagent definitions (flow-agent, comment-sicko, role agents)
sources/     both upstream trees, unmodified, for diffing
parked/      kept but not installed; see parked/README.md for why
scripts/     installer, manifest generator, lint
```

## Install

Two modes. They conflict if used together, because the same skill name would
register twice. Pick one.

**Symlinks** (the daily driver, edits are live immediately):

```bash
scripts/link-skills.sh
```

**Plugin** (the shareable artifact):

```bash
scripts/gen-plugin-manifest.sh
claude plugin marketplace add ~/my-skills
```

`link-skills.sh --unlink` removes only the links it created. It never touches
anything else in `~/.claude/skills`.

## Working on it

`CLAUDE.md` holds the invariants and the Cursor-to-Claude-Code porting table.
`scripts/lint-skills.py` enforces the invariants; run it after any change.

```bash
python3 scripts/lint-skills.py
claude plugin validate . --strict
```

## Status

Being built. See `parked/README.md` for what is deliberately not installed and
what it would take to revive each piece.
