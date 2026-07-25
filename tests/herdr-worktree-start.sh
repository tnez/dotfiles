#!/bin/bash

set -Eeuo pipefail

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
REPO_ROOT=${SCRIPT_DIR%/*}
HELPER=$REPO_ROOT/scripts/dot-scripts/herdr-worktree-start.sh
TMPDIR_TEST=$(mktemp -d -t herdr-worktree-start.XXXXXX)
FIXTURE_REPO=$TMPDIR_TEST/repo
FIXTURE_WORKTREE=$TMPDIR_TEST/worktree
FIXTURE_BIN=$TMPDIR_TEST/bin
START_LOG=$TMPDIR_TEST/agent-start.log
PROMPT_LOG=$TMPDIR_TEST/agent-prompt.log

cleanup() {
  rm -rf "$TMPDIR_TEST"
}
trap cleanup EXIT HUP INT TERM

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

mkdir -p "$FIXTURE_REPO" "$FIXTURE_WORKTREE" "$FIXTURE_BIN"
git -C "$FIXTURE_REPO" init -q
: > "$FIXTURE_REPO/.wtp.yml"
ln -s "$SCRIPT_DIR/fake-herdr-worktree.sh" "$FIXTURE_BIN/herdr"
ln -s "$SCRIPT_DIR/fake-wtp-worktree.sh" "$FIXTURE_BIN/wtp"

export FAKE_HERDR_AGENT_START_LOG=$START_LOG
export FAKE_HERDR_AGENT_PROMPT_LOG=$PROMPT_LOG
export FAKE_HERDR_REPO=$FIXTURE_REPO
export FAKE_WTP_WORKTREE=$FIXTURE_WORKTREE
export HERDR_ENV=1
export HERDR_WORKSPACE_ID=w1
export PATH="$FIXTURE_BIN:$PATH"

output="$(
  printf '%s\n' 'Make the bounded fixture change.' |
    "$HELPER" \
      --repo "$FIXTURE_REPO" \
      --branch test/default-start \
      --agent-name default-worker
)" || fail 'helper starts a worker without native arguments'
jq -e '.status == "started" and .agent == "default-worker"' \
  >/dev/null <<<"$output" || fail 'default startup returns worker metadata'

expected="$(
  printf '%s\n' \
    default-worker \
    --kind \
    opencode \
    --pane \
    w1:p2
)"
[ "$(< "$START_LOG")" = "$expected" ] ||
  fail 'no native arguments preserves the existing Herdr command'
printf '%s\n' 'ok - no native arguments preserves current behavior'

output="$(
  printf '%s\n' 'Make one small fixture change.' |
    "$HELPER" \
      --repo "$FIXTURE_REPO" \
      --branch test/profile-start \
      --agent-name profile-worker \
      -- --agent code-lite
)" || fail 'helper starts a worker with native arguments'
jq -e '.status == "started" and .agent == "profile-worker"' \
  >/dev/null <<<"$output" || fail 'profile startup returns worker metadata'

expected="$(
  printf '%s\n' \
    profile-worker \
    --kind \
    opencode \
    --pane \
    w1:p2 \
    -- \
    --agent \
    code-lite
)"
[ "$(< "$START_LOG")" = "$expected" ] ||
  fail 'native arguments are forwarded after the Herdr separator'
printf '%s\n' 'ok - native arguments reach the OpenCode command unchanged'

expected="$(
  printf '%s\n' \
    profile-worker \
    'Make one small fixture change.' \
    --wait \
    --until \
    idle \
    --until \
    working \
    --until \
    blocked \
    --until \
    'done' \
    --until \
    unknown
)"
[ "$(< "$PROMPT_LOG")" = "$expected" ] ||
  fail 'prompt delivery does not wait for an observed lifecycle transition'
printf '%s\n' 'ok - prompt acceptance requires a post-submit state transition'

printf '%s\n' 'All herdr-worktree-start tests passed.'
