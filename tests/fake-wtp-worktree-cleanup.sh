#!/bin/bash

set -Eeuo pipefail

printf '%s\n' "$@" > "${FAKE_WTP_LOG:?}"
[[ "${1:-}" == remove && "${2:-}" == --with-branch && $# -eq 3 ]] || {
  printf 'unexpected fake wtp command: %s\n' "$*" >&2
  exit 1
}
[[ "${FAKE_WTP_FAIL:-false}" != true ]] || {
  printf '%s\n' 'simulated non-forced wtp failure' >&2
  exit 1
}

git worktree remove "${FAKE_HERDR_WORKTREE:?}"
git branch -d "${3:?}"
if [[ "${FAKE_WTP_RECREATE_PATH:-false}" == true ]]; then
  mkdir -p "$FAKE_HERDR_WORKTREE"
fi
