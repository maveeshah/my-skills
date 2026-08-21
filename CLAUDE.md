# Working in this repo

A personal Claude Code skill system, merged from two upstreams. `sources/` holds
both original trees unmodified; `skills/` holds the adapted, merged result.
Every skill here should be diffable against its origin under `sources/`.

## Invariants

`scripts/lint-skills.py` enforces all of these. Run it after any change.

- **Directory basename == frontmatter `name` == the slash command.** No
  exceptions.
- **Names are globally unique** across `skills/`, and must not equal a built-in
  Claude Code skill name (`code-review`, `loop`, `run`, `init`, `simplify`,
  `schedule`, `security-review`, `update-config`, `dataviz`, `claude-api`,
  `codebase-memory`, …). The symlink install flattens everything into
  `~/.claude/skills/<name>`, so a collision is a load-time failure, not a
  warning.
- **Names are kebab-case**, `^[a-z0-9]+(-[a-z0-9]+)*$`.
- **Descriptions carry no angle brackets** and stay under 1024 characters.
- **No Cursor-only frontmatter.** `mode`, `icon`, `color`, `reminder` in a
  SKILL.md and `is_background` in an agent are inert here; their presence means
  a file was copied but never ported. (`color` *is* valid in `agents/*.md`.)

## Frontmatter

Model-invocable skill:

```yaml
---
name: how
description: "Use when ... . One scalar, trigger phrases included."
---
```

User-only skill (add `argument-hint` when it takes one):

```yaml
---
name: architect
description: "..."
disable-model-invocation: true
---
```

Agent:

```yaml
---
name: flow-agent
description: "..."
model: opus
effort: high
tools: Read, Glob, Grep, Bash, Write, Edit, Skill, Agent
---
```

An agent that fans out must list `Agent` in `tools`, or every delegating
playbook step silently fails.

## Porting rules

Anything moved from `sources/pstack` targets Cursor and needs the full pass:

| Cursor | Here |
|---|---|
| `Task` tool | `Agent` |
| `subagent_type: generalPurpose` | `general-purpose` |
| `AskQuestion` | `AskUserQuestion` |
| `create-skill` | `skill-creator@claude-plugins-official`, else `writing-for-agents` |
| `/deslop` | `/simplify` |
| `control-ui` | `claude-in-chrome` |
| `control-cli` | `/run`, or a harness from `verify` |
| `environment: "cloud"` | nothing; park the playbook |
| `~/.cursor/projects/<slug>/agent-transcripts/<uuid>/<uuid>.jsonl` | `~/.claude/projects/<slug>/<uuid>.jsonl` |
| `.cursor/skills/` | `.claude/skills/` |

The transcript path is a **shape** change, not a rename. Claude Code writes one
flat `.jsonl` per session, the slug keeps its leading dash
(`/home/mavee/x` → `-home-mavee-x`), and subagent turns are inlined in the
parent file tagged `"isSidechain": true` rather than split into their own files.
Any skill that globbed for per-subagent transcripts needs rewriting, not
find-and-replace.

**Model diversity is narrower here.** The Agent tool takes a `model`, but only
`sonnet` / `opus` / `haiku` / `fable`. Every subagent is a Claude model, so
pstack's "a second opinion is a different vendor" premise does not hold. Say so
in the skills that relied on it; never leave a dead slug like
`grok-4.6-fast-xhigh` in a file.

## Install

Two modes, and they conflict if used together (the same `name` registers
twice). Pick one.

```bash
scripts/link-skills.sh          # symlinks into ~/.claude/{skills,agents}
scripts/gen-plugin-manifest.sh  # regenerate plugin.json after add/rename/remove
claude plugin validate . --strict
```

Symlinks are the daily driver for a repo you edit. The plugin manifest is the
shareable artifact. `link-skills.sh` also prunes its own stale links and never
touches anything it did not create.

## Prose

No em-dashes, in skills or docs. Both upstreams enforce this and it is worth
keeping.
