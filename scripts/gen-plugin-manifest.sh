#!/usr/bin/env bash
set -euo pipefail

# Regenerates the "skills" array in .claude-plugin/plugin.json from whatever
# actually exists under skills/. Run it after adding, renaming, or removing a
# skill. A hand-maintained array silently drops skills; this does not.
#
#   scripts/gen-plugin-manifest.sh            rewrite plugin.json
#   scripts/gen-plugin-manifest.sh --check    exit 1 if it would change

REPO="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO/.claude-plugin/plugin.json"

paths=()
while IFS= read -r skill_md; do
  paths+=("./skills/$(basename "$(dirname "$skill_md")")")
done < <(find "$REPO/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | sort)

if [ ${#paths[@]} -eq 0 ]; then
  echo "error: no skills found under $REPO/skills" >&2
  exit 1
fi

skills_json="$(printf '%s\n' "${paths[@]}" | jq -R . | jq -s .)"
new="$(jq --argjson s "$skills_json" '.skills = $s' "$MANIFEST")"

if [ "${1:-}" = "--check" ]; then
  if [ "$new" = "$(cat "$MANIFEST")" ]; then
    echo "plugin.json is up to date (${#paths[@]} skills)"
    exit 0
  fi
  echo "error: plugin.json is stale. Run scripts/gen-plugin-manifest.sh" >&2
  diff <(jq -r '.skills[]' "$MANIFEST") <(printf '%s\n' "${paths[@]}") || true
  exit 1
fi

printf '%s\n' "$new" >"$MANIFEST"
echo "wrote ${#paths[@]} skills to .claude-plugin/plugin.json"
