# my-skills

A unified personal skill system bringing together the best of complementary upstream frameworks: [poteto's pstack][pstack], [mattpocock/skills][matt], [marketingskills][marketing], [anthropics/skills][anthropic], [superpowers][superpowers], [Agent-Skills-for-Context-Engineering][ce], [LessieAI/lessie-skill][lessie], [bradautomates/head-of-content][hoc], and [remotion-dev/skills][remotion]. All are open-source / MIT licensed; see [NOTICE.md](./NOTICE.md).

[pstack]: https://github.com/cursor/plugins/tree/main/pstack
[matt]: https://github.com/mattpocock/skills
[marketing]: https://github.com/coreyhaines31/marketingskills
[anthropic]: https://github.com/anthropics/skills
[superpowers]: https://github.com/obra/superpowers
[ce]: https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering
[lessie]: https://github.com/LessieAI/lessie-skill
[hoc]: https://github.com/bradautomates/head-of-content
[remotion]: https://github.com/remotion-dev/skills

## The Best of Both Worlds

Upstream skill libraries approach AI-assisted software engineering, product, and growth workflows from different angles. Merging them into `my-skills` creates a complete end-to-end framework across coding, architecture, context engineering, marketing intelligence, video generation, documents, and tool creation.

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

### Context Engineering and Agent Architecture
- **Context Management.** Compression, memory stores, KV-cache optimization, and degradation diagnosis.
- **Harness & Scaffolds.** Deterministic evaluation, LLM-as-judge pipelines, and recursive self-improvement loops.
- **Tool Design.** Minimal, clean tool interfaces that reduce hallucination and maximize agent reliability.

### Engineering Superpowers and Subagent Workflows (superpowers)
- **Parallel Dispatch.** Systematic subagent decomposition, plan review checkpoints, and execution tracking.
- **Git Worktree Isolation.** Safe parallel workspace branching for independent feature exploration.

### Official Anthropic Tools and Document Engines (Anthropic)
- **Office Formats.** Programmatic creation and manipulation of `.docx`, `.pdf`, `.pptx`, and `.xlsx`.
- **MCP & Web UI.** MCP server creation harnesses (`mcp-builder`), webapp Playwright testing, and frontend design guidelines.

### Strategic and Growth Marketing (marketingskills)
- **50 Growth Skills.** Comprehensive playbooks across copywriting, paid ads, SEO/AI-search, CRO, pricing, onboarding, and compounding marketing loops.

### People & Lead Intelligence (Lessie)
- **Live People Search.** Discover KOLs, influencers, candidates, and B2B buyers across 100+ live sources (`people-search`).
- **Contact Enrichment & Email.** Verify work emails, phones, and automate multi-provider email campaigns (`lessie-email`).

### Social Intelligence & Content Planning (Head of Content)
- **Multi-Platform Research.** Scrape, analyze, and detect viral outliers across X, Instagram Reels, TikTok, and YouTube.
- **Hook & Retention Mechanics.** Extract replicable opening formulas, pacing, and retention patterns (`video-content-analyzer`, `content-planner`).

### Programmatic Video Production (Remotion)
- **React-Native Video.** Code video compositions with springs, sequencing, and audio directly in React (`remotion-markup`, `remotion-create`).
- **Maps, Studio & Rendering.** 2D/3D map animations (`remotion-maps`), Studio preview (`remotion-studio`), and production rendering (`remotion-render`).

## Repository Layout

```
skills/      the installed set, one directory per skill
agents/      subagent definitions (flow-agent, comment-sicko)
tools/       tool integrations and registry references
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

[CLAUDE.md](./CLAUDE.md) documents invariants and porting rules. `scripts/lint-skills.py` enforces directory naming, frontmatter, and prohibited tags.

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

163 active skills, 2 agents, 12 playbooks. All verification checks pass.

See [parked/README.md](./parked/README.md) for features parked due to host dependency requirements.
