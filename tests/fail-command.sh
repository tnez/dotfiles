#!/bin/bash

set -u

: > "${DOTFILES_TEST_HOST_MUTATION_MARKER:?}"
printf 'TEST GUARD: blocked host command: %s %s\n' \
  "${0##*/}" "$*" >&2
exit 97
