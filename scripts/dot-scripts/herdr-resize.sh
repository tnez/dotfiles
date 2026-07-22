#!/bin/bash
# Resize Herdr panes while preserving Neovim's internal split resizing.

set -euo pipefail

direction=${1:-}
pane=${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}

case "$direction" in
  left) key=alt+h ;;
  down) key=alt+j ;;
  up) key=alt+k ;;
  right) key=alt+l ;;
  *)
    printf 'Usage: %s <left|down|up|right>\n' "${0##*/}" >&2
    exit 2
    ;;
esac

[[ -n "$pane" ]] || exit 0

if herdr pane process-info --pane "$pane" 2>/dev/null |
  jq -e \
    '.result.process_info.foreground_processes[]?.name
     | ascii_downcase
     | test("^g?(view|l?n?vim?x?)(diff)?$")' >/dev/null; then
  exec herdr pane send-keys "$pane" "$key"
fi

exec herdr pane resize --pane "$pane" --direction "$direction"
