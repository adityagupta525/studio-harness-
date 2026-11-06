#!/usr/bin/env bash
# harness-run.sh: open or switch the active harness run (the hooks read ACTIVE_RUN).
#   harness-run.sh new <slug>    copy runs/_template to runs/<today>-<slug>, set it active
#   harness-run.sh use <run-dir> set an existing run active
#   harness-run.sh show          print the active run and its status line
set -euo pipefail
H="$HOME/studio-harness"
case "${1:-show}" in
  new)
    [ -n "${2:-}" ] || { echo "usage: harness-run.sh new <slug>"; exit 1; }
    R="runs/$(date +%F)-$2"
    [ -e "$H/$R" ] && { echo "exists: $R"; exit 1; }
    cp -R "$H/runs/_template" "$H/$R"
    sed -i '' "s/^run_id: .*/run_id: $(basename "$R")/; s/^created: .*/created: $(date +%F)/; s/^updated: .*/updated: $(date +%F)/" "$H/$R/STATUS.md"
    echo "$R" > "$H/ACTIVE_RUN"; echo "active: $R" ;;
  use)
    R="${2#"$H/"}"; [ -d "$H/$R" ] || { echo "no such run: $R"; exit 1; }
    echo "$R" > "$H/ACTIVE_RUN"; echo "active: $R" ;;
  show)
    R=$(cat "$H/ACTIVE_RUN" 2>/dev/null || true); echo "active: ${R:-none}"
    [ -n "$R" ] && awk '/^## Status/{getline; print; exit}' "$H/$R/STATUS.md" ;;
  *) echo "usage: harness-run.sh new <slug> | use <run> | show"; exit 1 ;;
esac
