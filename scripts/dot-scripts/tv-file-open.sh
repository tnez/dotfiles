#!/bin/bash
# Pick a file with Television, then open it in the current or target tmux pane.

set -euo pipefail

target_pane=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-pane)
      target_pane="${2:-}"
      shift 2
      ;;
    *)
      printf 'Usage: %s [--target-pane pane-id]\n' "${0##*/}" >&2
      exit 2
      ;;
  esac
done

selection="$(tv --expect ctrl-r file-open)" || exit $?
[[ -n "$selection" ]] || exit 0

mode=edit
file="$selection"

if [[ "$selection" == *$'\n'* ]]; then
  key="${selection%%$'\n'*}"
  file="${selection##*$'\n'}"
  if [[ "$key" == ctrl-r ]]; then
    mode="readonly"
  fi
fi

[[ -n "$file" ]] || exit 0

if [[ -n "$target_pane" ]]; then
  export TV_FILE_OPEN_TARGET_PANE="$target_pane"
fi

exec ~/.scripts/tv-file-open-action.sh "$mode" "$file"
