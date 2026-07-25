#!/bin/bash

set -u

if [ "${1:-}" != add ]; then
  printf 'unexpected fake wtp command: %s\n' "$*" >&2
  exit 1
fi

printf '%s\n' "${FAKE_WTP_WORKTREE:?}"
