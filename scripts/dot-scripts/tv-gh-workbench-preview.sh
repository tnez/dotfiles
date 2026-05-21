#!/bin/bash
set -euo pipefail

kind="${1:-}"
entry="${2:-}"
target="${entry%%$'\t'*}"

if [[ "$target" != *#* ]]; then
  message="${entry#*$'\t'}"
  message="${message%%$'\t'*}"
  printf '%s\n' "${message:-No results}"
  exit 0
fi

repo="${target%%#*}"
number="${target##*#}"

case "$kind" in
  pr)
    exec gh pr view "$number" --repo "$repo" --comments
    ;;
  issue)
    exec gh issue view "$number" --repo "$repo" --comments
    ;;
  *)
    printf 'usage: %s {pr|issue} ENTRY\n' "$0" >&2
    exit 2
    ;;
esac
