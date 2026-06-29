#!/usr/bin/env bash
set -euo pipefail

# Regenerates .claude-plugin/marketplace.json from the skills/ tree.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

{
  echo '{'
  echo '  "plugins": ['
  first_group=1
  for group_dir in skills/*/; do
    group="$(basename "$group_dir")"
    skills=()
    while IFS= read -r -d '' skill_md; do
      skills+=("./$(dirname "$skill_md")")
    done < <(find "$group_dir" -name SKILL.md -not -path '*/deprecated/*' -print0 | sort -z)
    [ ${#skills[@]} -eq 0 ] && continue

    [ $first_group -eq 0 ] && echo '    },'
    first_group=0
    echo '    {'
    printf '      "name": "%s",\n' "$group"
    echo '      "skills": ['
    for i in "${!skills[@]}"; do
      sep=','; [ "$i" -eq $((${#skills[@]} - 1)) ] && sep=''
      printf '        "%s"%s\n' "${skills[$i]}" "$sep"
    done
    echo '      ]'
  done
  echo '    }'
  echo '  ]'
  echo '}'
} > .claude-plugin/marketplace.json

echo "wrote .claude-plugin/marketplace.json"
