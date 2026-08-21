# Notice

This repository is a personal skill system for Claude Code, derived from two
upstream projects. Both are MIT licensed, and both licenses require that their
copyright and permission notices survive in derivative works. They are
reproduced in full below.

The unmodified upstream trees are vendored under `sources/` so that every
adaptation in `skills/` can be diffed against its origin.

---

## pstack

Source: <https://github.com/cursor/plugins/tree/main/pstack>
Vendored at: `sources/pstack/`

Author's framing, from the upstream README: *"if you want to go fast, go deep
first."*

What this repository takes from it: the sticky router (`poteto-mode`, here
rewritten as `flow`), its playbook layer, the 21 atomic engineering principles,
and the investigation, design, verification and forensics skills (`how`, `why`,
`architect`, `arena`, `swarm`, `blast-radius`, `figure-it-out`, `unslop`,
`technical-writing`, `no-comments`, `verify`, `show-me-your-work`, `recall`,
`reflect`, `automate-me`).

```
MIT License

Copyright (c) 2026 Lauren Tan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## mattpocock/skills

Source: <https://github.com/mattpocock/skills> (v1.2.3)
Vendored at: `sources/mattpocock/`

The upstream README invites this: *"Hack around with them. Make them your
own."*

What this repository takes from it: the deep-module vocabulary
(`codebase-design`), domain modeling with `CONTEXT.md` and ADRs, the design-tree
grilling interview, the two-axis review that became half of `review`, the gated
diagnosis loop that became the spine of `diagnose`, the TDD doctrine that became
the body of `tdd`, and `wayfinder`, `wizard`, `to-spec`, `to-tickets`, `triage`,
`teach`, `writing-for-agents`, `git-guardrails`, and others.

```
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## On the adaptations

Skills in `skills/` are not verbatim copies. They have been ported from Cursor
to Claude Code (tool names, subagent types, transcript paths, frontmatter),
merged where the two upstreams overlapped, and in several cases rewritten.
Where a capability could not be ported honestly, it was parked rather than left
as instructions that would fail on first use. See `parked/README.md`.

Neither upstream author has reviewed or endorsed this derivative.
