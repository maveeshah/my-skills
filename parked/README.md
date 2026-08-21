# Parked

Material kept in the tree but not installed: it is either unportable to Claude
Code today, or out of scope for how this repo is currently used. Nothing here
is linked by `scripts/link-skills.sh` or listed in `plugin.json`.

Parked, not deleted, so promoting one later is a move rather than an
archaeology exercise. Each entry names what it would take to revive.

## Blocked on missing tooling

These came from pstack and depend on a toolchain that is not on this machine.
Writing them against tools that do not exist would produce skills that read
plausibly and fail on first use.

| Item | Needs | Status |
|---|---|---|
| `babysit`, `shipping` | A real GitHub CLI | `gh` on PATH is `/home/mavee/.local/bin/gh`, a v0.0.4 Python script that opens GitHub in a browser. It shadows the real CLI, and `~/.config/gh` does not exist. Install the real `gh`, put it ahead of `~/.local/bin`, `gh auth login`, and these become a clean follow-up. |
| `shipping`, `autopilot-stack` | Graphite (`gt`) | Not installed. Paid product, separate account. The stacked-PR mechanics have no plain-git substitute that preserves the playbook's guarantees. |
| `orchestrate`, `autopilot-full`, `autopilot-stack` | Cursor cloud agents | No Claude Code equivalent. There is no per-Agent-call `environment: "cloud"`; cloud is a whole-session concept and is not addressable from a skill. |
| `scripts/` (`orch.ts`, `store.ts`, `watch-pr/*`) | `bun` | Not installed. ~5,200 LOC of TypeScript serving only the playbooks above. The bun coupling is thin (`Bun.spawnSync`, `import.meta.dir`, `bun:test`) so a node port is mechanical, but it is speculative work until a playbook that needs it can actually run. |
| `visual-parity` | Image-diff on a driven UI | Depended on `control-ui`. `claude-in-chrome` can screenshot, but pixel-exact diffing driven autonomously has no honest path yet. |

## Out of scope

| Item | Reason |
|---|---|
| `writing-beats`, `writing-fragments`, `writing-shape` | Matt's prose-article trio. Article authoring, not engineering. Upstream marks them in-progress. No current need stated. |

## Dropped outright

Not parked, removed. Recorded here so the reasoning survives.

- `automations/benny/` (pstack) was dormant Cursor and Slack issue automation, built entirely on `.cursor/settings.json` and cloud automations. Nothing survives a port.
- `agents/openai.yaml` (35 files, Matt) is Codex picker metadata. This repo ships no Codex plugin.
- `ask-matt` was a router over Matt's skills. `flow` is the router now, and two routers is worse than one.
- `implement` and `research` (Matt) were 15 and 12 lines. `flow`'s Feature playbook and `why` cover them.
- `migrate-to-shoehorn` and `scaffold-exercises` are specific to Matt's own library and course products.
- `loop-me` is redundant. Claude Code ships `/loop`.
- `.out-of-scope/`, `.changeset/`, `CHANGELOG.md`, and `docs/` are upstream repo state, not skill content.
- `docs/guide/images/` (pstack, 2.3 MB) are Cursor-branded illustrations.

The full originals remain under `sources/` regardless.
