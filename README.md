# my-skills

A unified personal skill system bringing together the best of two complementary upstream frameworks: [poteto's pstack][pstack] and [mattpocock/skills][matt]. Both are MIT licensed; see [NOTICE.md](./NOTICE.md).

[pstack]: https://github.com/cursor/plugins/tree/main/pstack
[matt]: https://github.com/mattpocock/skills

## The Best of Both Worlds

Upstream `pstack` and Matt Pocock's skills approach AI-assisted software engineering from different angles. Neither system is complete alone. Merging them into `my-skills` creates a complete end-to-end engineering framework.

### Autonomous Execution Engine (pstack)
- **Sticky Routing.** The `flow` skill routes tasks to matched playbooks and mandates grounded principle citations.
- **Task Playbooks.** 12 standard recipes for features, refactoring, forensics, evaluations, and pull requests.
- **Atomic Principles.** 21 rules grounding choices in data structures, domain modeling, deletion bias, and boundary discipline.
- **Real Verification.** Proves code behavior against actual app artifacts instead of relying on self-reports.

### Alignment and Architectural Rigor (Matt Pocock)
- **Deep Modules.** Design vocabulary (`architect`, `codebase-design`) hiding implementation details behind simple seams.
- **Plan Grilling.** Stress-tests requirements (`grilling`) before writing any code.
- **Gated Diagnosis.** Enforces a reproducible failing test before forming diagnostic hypotheses (`diagnose`).
- **Multi-Axis Review.** Evaluates pull requests across Standards, Spec, and Adversarial axes (`review`).

### Consolidation
Where upstreams overlapped, skills were consolidated into single authoritative implementations rather than shipping duplicate tools.

## Repository Layout

```
skills/      the installed set, one directory per skill
agents/      subagent definitions (flow-agent, comment-sicko)
sources/     unmodified upstream trees for diffing
parked/      kept but not installed; see parked/README.md for revival conditions
scripts/     installer, manifest generator, lint, and verification harness
```

## Installation

Pick one installation mode.

**Symlinks** (daily driver, edits reflect live immediately):

```bash
scripts/link-skills.sh
```

To remove links created by the installer:

```bash
scripts/link-skills.sh --unlink
```

**Plugin** (the shareable artifact):

```bash
scripts/gen-plugin-manifest.sh
claude plugin marketplace add ~/my-skills
```

## Validation and Linting

[CLAUDE.md](./CLAUDE.md) documents invariants and Cursor-to-Claude-Code porting rules. `scripts/lint-skills.py` enforces directory naming, frontmatter, and prohibited tags.

```bash
python3 scripts/lint-skills.py
claude plugin validate . --strict
```

## Verification

Run the automated 7-check verification suite before committing:

```bash
scripts/verify.sh
```

The verification suite checks frontmatter invariants, internal references, port residue, manifest freshness, strict plugin schema validity, router coverage across all skills, and symlink resolution.

## Current Status

43 active skills, 2 agents, 12 playbooks. All verification checks pass.

See [parked/README.md](./parked/README.md) for features parked due to host dependency requirements.

