#!/usr/bin/env bash
set -euo pipefail

# Symlinks this repo's skills and agents into Claude Code's user-level
# directories, so edits here are live immediately with no reinstall step.
#
#   ~/.claude/skills/<name>  ->  <repo>/skills/<name>
#   ~/.claude/agents/<x>.md  ->  <repo>/agents/<x>.md
#
# Agents matter: the plugin install auto-discovers agents/, but a symlink
# install does not. Without the second loop, /flow spawns flow-agent and gets
# nothing.
#
# Adapted from mattpocock/skills scripts/link-skills.sh (MIT), which upstream
# marks dev-only. Changes: dropped the ~/.agents/skills (Codex) destination,
# added the agents/ loop, added --unlink and --dry-run.
#
#   scripts/link-skills.sh              link everything
#   scripts/link-skills.sh --dry-run    show what would happen
#   scripts/link-skills.sh --unlink     remove only the symlinks pointing here

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DEST="$HOME/.claude/skills"
AGENT_DEST="$HOME/.claude/agents"

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

# Remove a link only if it actually points into this repo. Never touch anything
# else living in the destination (codebase-memory, for one, is not ours).
unlink_ours() {
  local target="$1"
  [ -L "$target" ] || return 0
  local resolved
  resolved="$(readlink -f "$target")"
  case "$resolved" in
    "$REPO"/*) run rm "$target"; echo "unlinked $(basename "$target")" ;;
  esac
}

guard_dest "$SKILL_DEST"
guard_dest "$AGENT_DEST"

if $UNLINK; then
  for t in "$SKILL_DEST"/* "$AGENT_DEST"/*; do
    [ -e "$t" ] || [ -L "$t" ] || continue
    unlink_ours "$t"
  done
  exit 0
fi

run mkdir -p "$SKILL_DEST" "$AGENT_DEST"

linked=0
while IFS= read -r skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$SKILL_DEST/$name"

  # A real directory here is someone else's skill of the same name. Refuse
  # rather than delete it; a name collision is a bug to fix in the repo.
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "error: $target exists and is not a symlink. Rename the skill in this repo." >&2
    exit 1
  fi

  run ln -sfn "$src" "$target"
  echo "skill  $name"
  linked=$((linked + 1))
done < <(find "$REPO/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | sort)

agents=0
if compgen -G "$REPO/agents/*.md" >/dev/null; then
  for src in "$REPO"/agents/*.md; do
    name="$(basename "$src")"
    target="$AGENT_DEST/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "error: $target exists and is not a symlink. Rename the agent in this repo." >&2
      exit 1
    fi

    run ln -sfn "$src" "$target"
    echo "agent  $name"
    agents=$((agents + 1))
  done
fi

# Prune links that still point into this repo but whose target is gone. Without
# this, renaming a skill leaves the old name installed and resolvable, and the
# model happily loads a skill the repo no longer has.
pruned=0
for target in "$SKILL_DEST"/* "$AGENT_DEST"/*; do
  [ -L "$target" ] || continue
  resolved="$(readlink -f "$target" || true)"
  case "$resolved" in
    "$REPO"/*) [ -e "$target" ] || { run rm "$target"; echo "pruned $(basename "$target")"; pruned=$((pruned + 1)); } ;;
    "") run rm "$target"; echo "pruned $(basename "$target") (dangling)"; pruned=$((pruned + 1)) ;;
  esac
done

echo
echo "$linked skills, $agents agents, $pruned pruned -> $SKILL_DEST, $AGENT_DEST"
