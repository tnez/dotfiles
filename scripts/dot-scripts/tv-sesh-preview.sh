#!/bin/bash
# Preview sesh targets without dumping active pane contents by default.

set -euo pipefail

if [[ -z "${NO_COLOR:-}" ]]; then
  bold=$'\033[1m'
  dim=$'\033[2m'
  reset=$'\033[0m'
  blue=$'\033[34m'
  cyan=$'\033[36m'
  green=$'\033[32m'
  yellow=$'\033[33m'
  magenta=$'\033[35m'
else
  bold=''
  dim=''
  reset=''
  blue=''
  cyan=''
  green=''
  yellow=''
  magenta=''
fi

target="$*"
target="$(printf '%s' "$target" | perl -pe 's/\e\[[0-9;?]*[ -\/]*[@-~]//g')"

# `sesh list --icons` prefixes entries with a short icon. Strip only that first
# field so paths containing spaces still preview correctly.
if [[ "$target" == *' '* ]]; then
  first="${target%% *}"
  rest="${target#* }"

  if (( ${#first} <= 2 )); then
    target="$rest"
  fi
fi

expanded="${target/#\~/$HOME}"

if tmux has-session -t "$target" >/dev/null 2>&1; then
  printf '%stmux session:%s %s%s%s\n\n' "$bold" "$reset" "$cyan" "$target" "$reset"

  while IFS='|' read -r pane_id window_name pane_index active current_command current_path; do
    marker=' '
    if [[ "$active" == '1' ]]; then
      marker='*'
    fi

    status='running'
    status_color="$yellow"
    case "$current_command" in
      bash|fish|nu|sh|zsh)
        status='idle'
        status_color="$green"
        ;;
      nvim|vim|vi|yazi)
        status='interactive'
        status_color="$magenta"
        ;;
    esac

    printf '%s %s%s.%s%s  [%s%s%s] %s%s%s  %s%s%s\n' \
      "$marker" "$bold" "$window_name" "$pane_index" "$reset" \
      "$status_color" "$status" "$reset" \
      "$blue" "$current_command" "$reset" \
      "$dim" "$current_path" "$reset"

    if [[ "$active" == '1' ]]; then
      recent_lines="$(tmux capture-pane -ep -t "$pane_id" -S -80 2>/dev/null |
        perl -pe 's/\e\[[0-9;?]*[ -\/]*[@-~]//g' |
        sed '/^[[:space:]]*$/d' |
        tail -n 10)"

      if [[ "$status" == 'interactive' ]]; then
        printf '  %spreview:%s interactive terminal app; pane capture omitted\n' "$dim" "$reset"
      elif [[ -n "$recent_lines" ]]; then
        printf '  %srecent:%s\n' "$dim" "$reset"
        while IFS= read -r line; do
          printf '    %s\n' "$line"
        done <<< "$recent_lines"
      fi
    fi

    printf '\n'
  done < <(
    tmux list-panes -s -t "$target" \
      -F '#{pane_id}|#{window_name}|#{pane_index}|#{pane_active}|#{pane_current_command}|#{pane_current_path}'
  )

  exit 0
fi

if [[ -d "$expanded" ]]; then
  printf '%sdirectory:%s %s%s%s\n\n' "$bold" "$reset" "$cyan" "$target" "$reset"

  if git -C "$expanded" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%sgit:%s %s%s%s\n' \
      "$bold" "$reset" "$green" \
      "$(git -C "$expanded" branch --show-current 2>/dev/null || true)" \
      "$reset"
    git -C "$expanded" status --short 2>/dev/null | sed -n '1,12p'
    printf '\n'
  fi

  if command -v eza >/dev/null 2>&1; then
    eza --color=always --group-directories-first --icons --git "$expanded" 2>/dev/null
  else
    ls -la "$expanded"
  fi
  exit 0
fi

exec sesh preview "$target"
