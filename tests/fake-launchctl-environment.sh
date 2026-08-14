#!/bin/sh

set -eu

case "${1:-}" in
  setenv)
    printf 'setenv %s=%s\n' "$2" "$3" >> \
      "${FAKE_LAUNCHCTL_LOG:?}"
    ;;
  unsetenv)
    printf 'unsetenv %s\n' "$2" >> "${FAKE_LAUNCHCTL_LOG:?}"
    ;;
  *)
    printf 'unexpected launchctl command: %s\n' "$*" >&2
    exit 1
    ;;
esac
