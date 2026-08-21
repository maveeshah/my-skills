#!/usr/bin/env bash
set -euo pipefail

# Symlinks this repo's skills, agents, and plugin configuration into user-level
# directories for both Claude Code and Antigravity, so edits here are live
# immediately with no reinstall step.
#
#   Claude Code:
#     ~/.claude/skills/<name>  ->  <repo>/skills/<name>
#     ~/.claude/agents/<x>.md  ->  <repo>/agents/<x>.md
#
#   Antigravity:
#     ~/.gemini/config/plugins/my-skills  ->  <repo>
#
#   scripts/link-skills.sh              link everything for all agents
#   scripts/link-skills.sh --dry-run    show what would happen
#   scripts/link-skills.sh --unlink     remove only the symlinks pointing here

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_SKILL_DEST="$HOME/.claude/skills"
CLAUDE_AGENT_DEST="$HOME/.claude/agents"
ANTIGRAVITY_PLUGINS_DIR="$HOME/.gemini/config/plugins"
ANTIGRAVITY_PLUGIN_DEST="$ANTIGRAVITY_PLUGINS_DIR/my-skills"

DRY_RUN=false
UNLINK=false
case "${1:-}" in
  --dry-run) DRY_RUN=true ;;
  --unlink)  UNLINK=true ;;
  "")        ;;
  *)         echo "usage: $0 [--dry-run|--unlink]" >&2; exit 2 ;;
esac

run() {
  if $DRY_RUN; then echo "  would: $*"; else "$@"; fi
}

# A destination that is itself a symlink into this repo would make us write the
# per-skill links back into our own tree. Bail rather than pollute the checkout.
guard_dest() {
  local dest="$1"
  if [ -L "$dest" ]; then
    local resolved
    resolved="$(readlink -f "$dest")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $dest is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$dest\") and re-run; it will be recreated as a real dir." >&2
        exit 1
        ;;
    esac
  fi
}

# Remove a link only if it actually points into this repo.
unlink_ours() {
  local target="$1"
  [ -L "$target" ] || return 0
  local resolved
  resolved="$(readlink -f "$target")"
  case "$resolved" in
    "$REPO"|"$REPO"/*) run rm "$target"; echo "unlinked $(basename "$target")" ;;
  esac
}

guard_dest "$CLAUDE_SKILL_DEST"
guard_dest "$CLAUDE_AGENT_DEST"

if $UNLINK; then
  echo "Unlinking Claude Code symlinks..."
  for t in "$CLAUDE_SKILL_DEST"/* "$CLAUDE_AGENT_DEST"/*; do
    [ -e "$t" ] || [ -L "$t" ] || continue
    unlink_ours "$t"
  done

  echo "Unlinking Antigravity plugin..."
  if [ -L "$ANTIGRAVITY_PLUGIN_DEST" ]; then
    unlink_ours "$ANTIGRAVITY_PLUGIN_DEST"
  fi
  exit 0
fi

# 1. Claude Code links
run mkdir -p "$CLAUDE_SKILL_DEST" "$CLAUDE_AGENT_DEST"

linked_claude_skills=0
while IFS= read -r skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$CLAUDE_SKILL_DEST/$name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "error: $target exists and is not a symlink. Rename the skill in this repo." >&2
    exit 1
  fi

  run ln -sfn "$src" "$target"
  linked_claude_skills=$((linked_claude_skills + 1))
done < <(find "$REPO/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | sort)

linked_claude_agents=0
if compgen -G "$REPO/agents/*.md" >/dev/null; then
  for src in "$REPO"/agents/*.md; do
    name="$(basename "$src")"
    target="$CLAUDE_AGENT_DEST/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "error: $target exists and is not a symlink. Rename the agent in this repo." >&2
      exit 1
    fi

    run ln -sfn "$src" "$target"
    linked_claude_agents=$((linked_claude_agents + 1))
  done
fi

pruned_claude=0
for target in "$CLAUDE_SKILL_DEST"/* "$CLAUDE_AGENT_DEST"/*; do
  [ -L "$target" ] || continue
  resolved="$(readlink -f "$target" || true)"
  case "$resolved" in
    "$REPO"/*) [ -e "$target" ] || { run rm "$target"; echo "pruned $(basename "$target")"; pruned_claude=$((pruned_claude + 1)); } ;;
    "") run rm "$target"; echo "pruned $(basename "$target") (dangling)"; pruned_claude=$((pruned_claude + 1)) ;;
  esac
done

# 2. Antigravity plugin link
run mkdir -p "$ANTIGRAVITY_PLUGINS_DIR"
if [ -e "$ANTIGRAVITY_PLUGIN_DEST" ] && [ ! -L "$ANTIGRAVITY_PLUGIN_DEST" ]; then
  echo "error: $ANTIGRAVITY_PLUGIN_DEST exists and is not a symlink." >&2
  exit 1
fi
run ln -sfn "$REPO" "$ANTIGRAVITY_PLUGIN_DEST"

echo
echo "Claude Code: $linked_claude_skills skills, $linked_claude_agents agents -> $CLAUDE_SKILL_DEST, $CLAUDE_AGENT_DEST"
echo "Antigravity: plugin linked -> $ANTIGRAVITY_PLUGIN_DEST (discovering all $linked_claude_skills skills + rules)"
