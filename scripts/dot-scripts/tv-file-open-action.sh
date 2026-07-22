#!/bin/bash
# Open a Television file selection in an editor or default application.

set -euo pipefail

mode="${1:-edit}"
file="${2:-}"

if [[ -z "$file" ]]; then
  printf 'Usage: %s <edit|readonly> <file>\n' "${0##*/}" >&2
  exit 2
fi

editor_value="${VISUAL:-${EDITOR:-nvim}}"
# Allow simple EDITOR/VISUAL values with flags, e.g. "nvim -p".
# shellcheck disable=SC2206
editor_cmd=($editor_value)

shell_join() {
  local quoted arg

  for arg in "$@"; do
    printf -v quoted '%q' "$arg"
    printf '%s ' "$quoted"
  done
}

file_mime_type() {
  local output

  if output="$(file -b --mime-type -- "$file" 2>/dev/null)"; then
    printf '%s\n' "$output"
    return
  fi

  if output="$(file -bI -- "$file" 2>/dev/null)"; then
    printf '%s\n' "${output%%;*}"
  fi
}

should_use_editor() {
  local mime

  mime="$(file_mime_type)"
  case "$mime" in
    text/* | application/json | application/*+json | application/xml | \
      application/*+xml | application/yaml | application/x-yaml | \
      application/toml | application/javascript | application/x-shellscript)
      return 0
      ;;
  esac

  case "${file##*.}" in
    bash | c | cc | conf | cpp | css | env | go | h | hpp | html | js | \
      json | lua | md | py | rb | rs | sh | toml | ts | tsx | txt | vim | \
      yaml | yml | zsh)
      return 0
      ;;
  esac

  return 1
}

open_file() {
  local -a command_args

  if should_use_editor; then
    command_args=("${editor_cmd[@]}")
    if [[ "$mode" == readonly ]]; then
      command_args+=(-R)
    fi
    command_args+=("$file")
  elif command -v open >/dev/null 2>&1; then
    command_args=(open "$file")
  elif command -v xdg-open >/dev/null 2>&1; then
    command_args=(xdg-open "$file")
  else
    command_args=("${editor_cmd[@]}" "$file")
  fi

  if [[ -n "${TV_FILE_OPEN_HERDR_PANE:-}" ]]; then
    herdr pane run \
      "$TV_FILE_OPEN_HERDR_PANE" \
      "$(shell_join "${command_args[@]}")"
    return
  elif [[ -n "${TV_FILE_OPEN_TARGET_PANE:-}" ]]; then
    tmux set-buffer -b tv-file-open "$(shell_join "${command_args[@]}")"
    tmux paste-buffer -b tv-file-open -t "$TV_FILE_OPEN_TARGET_PANE"
    tmux send-keys -t "$TV_FILE_OPEN_TARGET_PANE" Enter
    return
  fi

  exec "${command_args[@]}"
}

case "$mode" in
  edit)
    open_file
    ;;
  readonly)
    open_file
    ;;
  *)
    printf 'Unknown mode: %s\n' "$mode" >&2
    exit 2
    ;;
esac
