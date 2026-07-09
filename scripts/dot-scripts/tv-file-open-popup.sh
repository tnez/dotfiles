#!/bin/bash
# Run the file picker in a tmux popup and keep failures visible.

set -euo pipefail

target_pane="${1:-${TV_FILE_OPEN_TARGET_PANE:-}}"

if [[ -z "$target_pane" || "$target_pane" == '#{pane_id}' ]]; then
  target_pane="$(tmux display-message -p '#{pane_id}')"
fi

if [[ -z "$target_pane" ]]; then
  printf 'Usage: %s <target-pane>\n' "${0##*/}" >&2
  read -r -n 1 -s -p 'Press any key to close...'
  exit 2
fi

if "$HOME/.scripts/tv-file-open.sh" --target-pane "$target_pane"; then
  exit 0
else
  status=$?
  printf '\ntv-file-open failed with status %s\n' "$status" >&2
  read -r -n 1 -s -p 'Press any key to close...'
  exit "$status"
fi
