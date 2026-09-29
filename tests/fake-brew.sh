#!/bin/bash

set -u

if [ "${FAKE_BREW_ALLOW_INSTALL:-}" = 1 ] &&
  [ "$#" -eq 5 ] && [ "$1 $2" = 'bundle install' ] &&
  [ "$4 $5" = '--no-upgrade --jobs=auto' ] &&
  [ "${HOMEBREW_NO_AUTO_UPDATE:-}" = 1 ]; then
  printf '%s\n' "$*" > "${FAKE_BREW_INSTALL_LOG:?}"
  exit 0
fi

case "${1:-} ${2:-}" in
  'bundle check') exit 0 ;;
  'trust --json=v1')
    printf '{"taps":[],"formulae":[],"casks":[],"commands":[]}\n'
    ;;
  *)
    : > "${DOTFILES_TEST_HOST_MUTATION_MARKER:?}"
    printf 'TEST GUARD: blocked Homebrew mutation: %s\n' "$*" >&2
    exit 97
    ;;
esac
