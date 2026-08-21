# Personal Skills and Engineering Principles

This workspace uses the personal skill system from `my-skills`. When tackling tasks in this workspace, follow these engineering standards and workflows.

## Core Workflows and Skills

1. **Autonomous Execution and Routing**:
   - For multi-step tasks, explore the **flow** skill (`skills/flow/SKILL.md`) and its specialized playbooks under `skills/flow/playbooks/`.
   - Before applying an engineering principle, open its leaf file under `skills/principles/` and state the decision it influenced.

2. **Design and Architecture**:
   - Use **architect** (`skills/architect/SKILL.md`) to sketch types, interfaces, and module boundaries before writing code.
   - Run **how** (`skills/how/SKILL.md`) and **why** (`skills/why/SKILL.md`) to ground existing system mechanics and design rationale before altering structure.
   - Use **setup-ts-deep-modules** / **codebase-design** to keep module interfaces simple and implementation hidden.

3. **Gated Diagnosis and Debugging**:
   - When diagnosing bugs, use **diagnose** (`skills/diagnose/SKILL.md`). Do not guess or apply trial-and-error fixes; isolate the root cause with a deterministic reproducer first.

4. **Review and Code Quality**:
   - Use **review** (`skills/review/SKILL.md`) for three-axis evaluation (standards, spec, adversarial edge cases).
   - Use **unslop** (`skills/unslop/SKILL.md`) for prose discipline and clear commit messages.
   - Use **no-comments** (`skills/no-comments/SKILL.md`) to eliminate narrative, dead code, or redundant comments that mask poor naming.

5. **Verification**:
   - Use **verify** (`skills/verify/SKILL.md`) to drive real application features and capture observable proof rather than relying on self-report.

## Specialized Subagents

When fanning out complex or specialized subtasks:

- **flow-agent**: Runs the full flow execution style. Reads `skills/flow/SKILL.md` before performing work and consults principles for each architectural decision.
- **comment-sicko**: A read-only reviewer that identifies redundant comments, workarounds, and suppression flags (`eslint-disable`, `@ts-ignore`) for refactoring.
