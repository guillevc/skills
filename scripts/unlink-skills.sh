#!/usr/bin/env bash
set -euo pipefail

# Reverses scripts/link-skills.sh: removes the symlinks that point into this
# repo from the local skill directories. Anything else in those directories
# (real dirs, symlinks elsewhere) is left alone.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

for DEST in "${DESTS[@]}"; do
  [ -d "$DEST" ] || continue

  for target in "$DEST"/*; do
    [ -L "$target" ] || continue

    resolved="$(readlink -f "$target")"
    case "$resolved" in
      "$REPO"/*)
        rm "$target"
        echo "unlinked $(basename "$target") ($DEST)"
        ;;
    esac
  done
done
