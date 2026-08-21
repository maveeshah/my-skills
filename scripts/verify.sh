#!/usr/bin/env bash
set -uo pipefail

# Every check that guards this repo, in one place. Run it after any change.
# Exits non-zero if anything fails, so it works as a pre-commit hook or in CI.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

fail=0
step() { printf '\n\033[1m%s\033[0m\n' "$1"; }
check() { if "$@"; then :; else fail=1; fi; }

step "1. Frontmatter invariants"
check python3 scripts/lint-skills.py

step "2. Internal references"
check python3 scripts/check-links.py

step "3. Port residue"
# Anything Cursor-era that survived a port is a skill that reads fine and
# points at something that does not exist here.
pat='\.cursor|cursor-team-kit|create-skill|/deslop|control-ui|control-cli'
pat="$pat"'|generalPurpose|poteto|pstack|grok-4|gpt-5\.|claude-fable-5-thinking'
pat="$pat"'|claude-opus-5-thinking|environment: "cloud"|is_background'
pat="$pat"'|\.\./principle-|principle skill|AskQuestion'
if grep -rEn "$pat" skills/ agents/ 2>/dev/null; then
  echo "  found Cursor-era references above"
  fail=1
else
  echo "  clean"
fi

step "4. Plugin manifest is current"
check bash scripts/gen-plugin-manifest.sh --check

step "5. Plugin validation"
for t in . ./skills ./agents; do
  if claude plugin validate "$t" --strict >/dev/null 2>&1; then
    printf '  %-10s ok\n' "$t"
  else
    printf '  %-10s FAILED\n' "$t"
    fail=1
  fi
done

step "6. Router covers every skill"
missing=0
for n in $(ls skills); do
  grep -q "\*\*$n\*\*\|\`$n\`\|/$n\b" skills/flow/SKILL.md || { echo "  orphan: $n"; missing=1; }
done
[ $missing -eq 0 ] && echo "  all $(ls skills | wc -l) skills reachable from flow" || fail=1

step "7. Installed symlinks resolve"
if [ -d "$HOME/.claude/skills" ]; then
  broken=$(find "$HOME/.claude/skills" "$HOME/.claude/agents" -maxdepth 1 -xtype l 2>/dev/null)
  if [ -n "$broken" ]; then
    echo "$broken" | sed 's/^/  broken: /'
    fail=1
  else
    echo "  $(find "$HOME/.claude/skills" -maxdepth 1 -type l | wc -l) skills, $(find "$HOME/.claude/agents" -maxdepth 1 -type l 2>/dev/null | wc -l) agents, none broken"
  fi
else
  echo "  not installed (run scripts/link-skills.sh)"
fi

printf '\n'
if [ $fail -eq 0 ]; then
  printf '\033[32mall checks passed\033[0m\n'
else
  printf '\033[31mFAILURES above\033[0m\n'
fi
exit $fail
