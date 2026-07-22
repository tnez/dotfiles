#!/bin/bash
# Run the file picker in a multiplexer popup and keep failures visible.

set -euo pipefail

herdr_pane="${HERDR_ACTIVE_PANE_ID:-}"
target_pane="${1:-${TV_FILE_OPEN_TARGET_PANE:-}}"

if [[ -n "$herdr_pane" ]]; then
  foreground_process="$(
    herdr pane process-info --pane "$herdr_pane" 2>/dev/null |
      jq -r \
        '.result.process_info.foreground_processes[0].name
         // "" | ascii_downcase'
  )" || foreground_process=""

  case "$foreground_process" in
    sh | bash | dash | fish | ksh | nu | xonsh | zsh) ;;
    *) exec herdr pane send-keys "$herdr_pane" ctrl+f ;;
  esac

  export TV_FILE_OPEN_HERDR_PANE="$herdr_pane"
  target_pane=""
fi

if [[ -z "$herdr_pane" &&
  ( -z "$target_pane" || "$target_pane" == '#{pane_id}' ) ]]; then
  target_pane="$(tmux display-message -p '#{pane_id}')"
fi

if [[ -z "$herdr_pane" && -z "$target_pane" ]]; then
  printf 'Usage: %s <target-pane>\n' "${0##*/}" >&2
  read -r -n 1 -s -p 'Press any key to close...'
  exit 2
fi

if [[ -n "$target_pane" ]]; then
  export TV_FILE_OPEN_TARGET_PANE="$target_pane"
fi

if "$HOME/.scripts/tv-file-open.sh"; then
  exit 0
else
  status=$?
  printf '\ntv-file-open failed with status %s\n' "$status" >&2
  read -r -n 1 -s -p 'Press any key to close...'
  exit "$status"
fi
