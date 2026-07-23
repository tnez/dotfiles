#!/bin/bash

set -u

case "${1:-} ${2:-}" in
  'bundle check') exit 0 ;;
  'trust --json=v1')
    printf '{"taps":[],"formulae":[],"casks":[],"commands":[]}\n'
    ;;
  'trust --formula'|'bundle install')
    : > "${FAKE_BREW_MARKER:?}"
    ;;
esac
