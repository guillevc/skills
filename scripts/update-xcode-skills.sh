#!/usr/bin/env bash
set -euo pipefail

# Refreshes skills/xcode-skills/ from the skills a given Xcode ships, using
# Xcode's own exporter:
#
#   xcrun mcpbridge run-agent skills export --output-dir <dir>
#
# That exporter talks to a *running* Xcode, so this script launches the target
# Xcode if it isn't already running (and quits it again only if it launched it).
# Skills already in skills/xcode-skills/ that this Xcode does not export are
# kept, and reported as stale.

usage() {
  cat <<'EOF'
Usage: scripts/update-xcode-skills.sh [options] [/Applications/Xcode.app]

Exports the skills bundled with Xcode into skills/xcode-skills/.
With no path, uses the most recently modified /Applications/Xcode*.app.

Options:
  -n, --dry-run   Export and report what would change; write nothing.
  -h, --help      Show this help.
EOF
}

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$REPO/skills/xcode-skills"

DRY_RUN=0
XCODE=""
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      [ -n "$XCODE" ] && { echo "error: unexpected argument: $1" >&2; exit 2; }
      XCODE="${1%/}"
      ;;
  esac
  shift
done

if [ -z "$XCODE" ]; then
  # Newest by mtime among the installed Xcodes.
  XCODE="$(ls -dt /Applications/Xcode*.app 2>/dev/null | head -1 || true)"
fi

if [ -z "$XCODE" ] || [ ! -d "$XCODE" ]; then
  echo "error: no Xcode.app found. Pass one explicitly:" >&2
  echo "  $0 /Applications/Xcode.app" >&2
  exit 1
fi
XCODE="$(cd "$XCODE" && pwd)"

MCPBRIDGE="$XCODE/Contents/Developer/usr/bin/mcpbridge"
if [ ! -x "$MCPBRIDGE" ]; then
  echo "error: $XCODE has no mcpbridge (needs Xcode 26.4 or later):" >&2
  echo "  $MCPBRIDGE" >&2
  exit 1
fi

version="$(defaults read "$XCODE/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo unknown)"
build="$(defaults read "$XCODE/Contents/version" ProductBuildVersion 2>/dev/null || echo unknown)"
echo "source: $XCODE ($version, $build)"

# The exporter resolves skills through a live Xcode instance; MCP_XCODE_PID
# pins it to the one we were asked about rather than whichever is selected.
xcode_pid() { pgrep -f "^${XCODE}/Contents/MacOS/Xcode$" | head -1 || true; }

pid="$(xcode_pid)"
launched=0
if [ -z "$pid" ]; then
  echo "launching Xcode (not running)..."
  open -a "$XCODE"
  for _ in $(seq 60); do
    pid="$(xcode_pid)"
    [ -n "$pid" ] && break
    sleep 1
  done
  [ -n "$pid" ] && launched=1
fi

if [ -z "$pid" ]; then
  echo "error: could not start $XCODE; open it manually and re-run." >&2
  exit 1
fi

TMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP"
  if [ "$launched" = 1 ]; then
    echo "quitting the Xcode this script launched (pid $pid)"
    # Ask nicely so Xcode can save state; fall back to a signal.
    osascript -e "tell application id \"com.apple.dt.Xcode\" to quit" >/dev/null 2>&1 ||
      kill "$pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# Xcode can need a moment after launch before its tool service answers.
export_log="$TMP/export.log"
for attempt in 1 2 3 4 5; do
  if MCP_XCODE_PID="$pid" "$MCPBRIDGE" run-agent skills export \
      --output-dir "$TMP/xcode-skills" --replace-existing >"$export_log" 2>&1; then
    break
  fi
  if [ "$attempt" = 5 ]; then
    echo "error: skills export failed" >&2
    cat "$export_log" >&2
    exit 1
  fi
  sleep 3
done

exported=()
while IFS= read -r src; do
  exported+=("$(basename "$src")")
done < <(find "$TMP/xcode-skills" -mindepth 1 -maxdepth 1 -type d | sort)

if [ ${#exported[@]} -eq 0 ]; then
  echo "error: exporter produced no skills" >&2
  cat "$export_log" >&2
  exit 1
fi

# The exporter emits frontmatter keys in a nondeterministic order, which would
# churn the diff on every run. Pin the order: name first, then the rest as-is.
pin_name_first() {
  local file="$1"
  awk '
    NR == 1 { if ($0 != "---") plain = 1; print; next }   # no frontmatter: copy
    plain || in_body { print; next }
    $0 == "---" {                                          # end of frontmatter
      if (name != "") print name
      for (i = 1; i <= n; i++) print buf[i]
      print
      in_body = 1
      next
    }
    name == "" && $0 ~ /^name:[ \t]/ { name = $0; next }
    { buf[++n] = $0 }
  ' "$file" >"$file.tmp" && mv "$file.tmp" "$file"
}

mkdir -p "$DEST"
for name in "${exported[@]}"; do
  src="$TMP/xcode-skills/$name"
  chmod -R u+w "$src"
  [ -f "$src/SKILL.md" ] && pin_name_first "$src/SKILL.md"

  if [ ! -d "$DEST/$name" ]; then
    status="new"
  elif diff -rq "$src" "$DEST/$name" >/dev/null 2>&1; then
    status="unchanged"
  else
    status="updated"
  fi

  if [ "$DRY_RUN" = 0 ] && [ "$status" != "unchanged" ]; then
    # Replace wholesale so files dropped by a newer Xcode don't linger.
    rm -rf "${DEST:?}/$name"
    cp -R "$src" "$DEST/$name"
  fi
  echo "  $status: $name"
done

# Skills the repo carries that this Xcode no longer exports: keep them, but say
# so — they may be leftovers from an older Xcode.
for dir in "$DEST"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  found=0
  for e in "${exported[@]}"; do
    [ "$e" = "$name" ] && found=1 && break
  done
  [ "$found" = 0 ] && echo "  stale (kept): $name — not exported by this Xcode"
done

if [ "$DRY_RUN" = 1 ]; then
  echo
  echo "dry run: nothing written"
  exit 0
fi

"$REPO/scripts/gen-marketplace.sh"

echo
git -C "$REPO" status --short -- skills/xcode-skills .claude-plugin/marketplace.json
