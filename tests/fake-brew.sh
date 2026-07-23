#!/bin/bash

set -u

case "${1:-} ${2:-}" in
  'bundle check') exit 0 ;;
  'trust --json=v1')
    printf '{"taps":[],"formulae":[],"casks":[],"commands":[]}\n'
    ;;
  'services start'|'services restart') exit 0 ;;
  *)
    : > "${DOTFILES_TEST_HOST_MUTATION_MARKER:?}"
    printf 'TEST GUARD: blocked Homebrew mutation: %s\n' "$*" >&2
    exit 97
    ;;
esac
