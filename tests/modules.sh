#!/bin/bash

set -u

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
PROJECT_ROOT=${SCRIPT_DIR%/*}
TMPDIR_TEST=$(mktemp -d -t dotfiles-modules.XXXXXX) || exit 1
trap 'rm -rf "$TMPDIR_TEST"' EXIT HUP INT TERM
REPO_ROOT=$TMPDIR_TEST/repo
FAILURES=0
OUTPUT=
STATUS=0

# shellcheck source=../lib/dotfiles/modules.sh
. "$PROJECT_ROOT/lib/dotfiles/modules.sh"

run_function() {
  OUTPUT=$("$@" 2>&1)
  STATUS=$?
}

assert_status() {
  local expected=$1 label=$2

  if [ "$STATUS" -eq "$expected" ]; then
    printf 'ok - %s\n' "$label"
  else
    printf 'not ok - %s (expected %s, got %s)\n%s\n' \
      "$label" "$expected" "$STATUS" "$OUTPUT"
    FAILURES=$((FAILURES + 1))
  fi
}

assert_contains() {
  local expected=$1 label=$2

  case "$OUTPUT" in
    *"$expected"*) printf 'ok - %s\n' "$label" ;;
    *)
      printf 'not ok - %s (missing %s)\n%s\n' \
        "$label" "$expected" "$OUTPUT"
      FAILURES=$((FAILURES + 1))
      ;;
  esac
}

write_module() {
  local name=$1 declaration=$2

  mkdir -p "$REPO_ROOT/$name"
  printf '# %s\n\n<!-- dotfiles-module\n%s\n-->\n' \
    "$name" "$declaration" > "$REPO_ROOT/$name/AGENT.md"
}

mkdir -p "$REPO_ROOT"
write_module alpha 'version 1
platform darwin
stow standard'
write_module beta 'version 1
platform darwin
platform omarchy
stow no-folding
capability codex-seed'
write_module omarchy 'version 1
platform omarchy
stow standard'
write_module provider 'version 1
platform darwin
stow none'

run_function validate_modules
assert_status 0 'valid module declarations pass validation'

run_function list_modules darwin
assert_status 0 'Darwin modules can be selected'
assert_contains 'alpha|standard|darwin||' \
  'selection includes a Darwin Stow module'
assert_contains 'beta|no-folding|darwin omarchy|codex-seed|' \
  'selection includes a multi-platform module with a capability'
assert_contains 'provider|none|darwin||' \
  'selection includes a provider-only module'
case "$OUTPUT" in
  *'omarchy|standard|omarchy||'*)
    printf 'not ok - Darwin selection included an Omarchy-only module\n'
    FAILURES=$((FAILURES + 1))
    ;;
  *) printf 'ok - Darwin selection excludes Omarchy-only modules\n' ;;
esac

run_function list_modules omarchy
assert_status 0 'Omarchy modules can be selected'
assert_contains 'omarchy|standard|omarchy||' \
  'selection includes an Omarchy-only module'
case "$OUTPUT" in
  *'alpha|standard|darwin||'*)
    printf 'not ok - Omarchy selection included a Darwin-only module\n'
    FAILURES=$((FAILURES + 1))
    ;;
  *) printf 'ok - Omarchy selection excludes Darwin-only modules\n' ;;
esac

write_module broken 'version 1
platform linux
stow standard'
run_function validate_modules
assert_status 1 'unknown platforms fail validation'
assert_contains 'invalid platform' 'invalid platform failure is explained'
rm -rf "$REPO_ROOT/broken"

write_module broken 'version 1
platform darwin
stow standard
capability arbitrary-shell'
run_function validate_modules
assert_status 1 'unknown capabilities fail validation'
assert_contains 'invalid capability' \
  'capabilities are constrained to lifecycle-owned behavior'
rm -rf "$REPO_ROOT/broken"

write_module broken 'version 1
platform darwin
run curl example.invalid
stow standard'
run_function validate_modules
assert_status 1 'executable directives fail validation'
assert_contains 'unknown directive' \
  'declarations cannot smuggle arbitrary actions'
rm -rf "$REPO_ROOT/broken"

write_module broken 'version 1
platform darwin
stow standard
stow no-folding'
run_function validate_modules
assert_status 1 'duplicate Stow directives fail validation'
assert_contains 'exactly one stow directive' \
  'duplicate Stow failure is explained'
rm -rf "$REPO_ROOT/broken"

write_module broken 'version 1
platform darwin
stow standard'
printf '\n<!-- dotfiles-module\nversion 1\nplatform darwin\nstow standard\n-->\n' \
  >> "$REPO_ROOT/broken/AGENT.md"
run_function validate_modules
assert_status 1 'multiple declaration blocks fail validation'
assert_contains 'expected one complete declaration' \
  'multiple-block failure is explained'
rm -rf "$REPO_ROOT/broken"

run_function detect_host_platform
assert_status 0 'the current supported host is detected'
case "$OUTPUT" in
  darwin|omarchy)
    printf 'ok - the host has a supported platform identifier\n'
    ;;
  *)
    printf 'not ok - unexpected platform identifier: %s\n' "$OUTPUT"
    FAILURES=$((FAILURES + 1))
    ;;
esac

if [ "$FAILURES" -ne 0 ]; then
  printf '%s module test(s) failed\n' "$FAILURES" >&2
  exit 1
fi

printf 'All module tests passed.\n'
