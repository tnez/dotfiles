#!/bin/bash

set -Eeuo pipefail

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
REPO_ROOT=${SCRIPT_DIR%/*}
HELPER=$REPO_ROOT/scripts/dot-scripts/herdr-worktree-cleanup.sh
TMPDIR_TEST=$(mktemp -d -t herdr-worktree-cleanup.XXXXXX)
FIXTURE_BIN=$TMPDIR_TEST/bin
FIXTURE_REPO=$TMPDIR_TEST/repo

cleanup() {
  rm -rf "$TMPDIR_TEST"
}
trap cleanup EXIT HUP INT TERM

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_no_mutation() {
  [[ ! -e "$FAKE_HERDR_CLOSED_MARKER" ]] ||
    fail "$1 closed the Herdr tab"
  [[ ! -e "$FAKE_WTP_LOG" ]] || fail "$1 invoked wtp"
}

new_worktree() {
  local name=$1

  export FAKE_HERDR_WORKTREE=$TMPDIR_TEST/worktrees/$name
  export FAKE_WTP_BRANCH="test/$name"
  export FAKE_HERDR_CLOSED_MARKER=$TMPDIR_TEST/$name.closed
  export FAKE_HERDR_CLOSE_LOG=$TMPDIR_TEST/$name.close.log
  export FAKE_WTP_LOG=$TMPDIR_TEST/$name.wtp.log
  export FAKE_HERDR_AGENT_STATUS=idle
  export FAKE_HERDR_PANE_COUNT=1
  unset FAKE_HERDR_PANE_CWD FAKE_WTP_FAIL FAKE_WTP_RECREATE_PATH HELPER_BASE
  git -C "$FIXTURE_REPO" worktree add -q \
    -b "$FAKE_WTP_BRANCH" "$FAKE_HERDR_WORKTREE" main
}

run_helper() {
  "$HELPER" \
    --agent "$FAKE_HERDR_AGENT" \
    --base "${HELPER_BASE:-main}" \
    --branch "$FAKE_WTP_BRANCH" \
    --pane "$FAKE_HERDR_PANE" \
    --tab "$FAKE_HERDR_TAB" \
    --worktree "$FAKE_HERDR_WORKTREE" \
    --workspace "$FAKE_HERDR_WORKSPACE"
}

mkdir -p "$FIXTURE_BIN" "$FIXTURE_REPO" "$TMPDIR_TEST/worktrees"
ln -s "$SCRIPT_DIR/fake-herdr-worktree-cleanup.sh" "$FIXTURE_BIN/herdr"
ln -s "$SCRIPT_DIR/fake-wtp-worktree-cleanup.sh" "$FIXTURE_BIN/wtp"
git -C "$FIXTURE_REPO" init -q -b main
git -C "$FIXTURE_REPO" config user.email test@example.com
git -C "$FIXTURE_REPO" config user.name 'Test User'
: > "$FIXTURE_REPO/.wtp.yml"
git -C "$FIXTURE_REPO" add .wtp.yml
git -C "$FIXTURE_REPO" commit -qm 'test: initialize fixture'

export FAKE_HERDR_AGENT=test-worker
export FAKE_HERDR_PANE=w1:p2
export FAKE_HERDR_TAB=w1:t2
export FAKE_HERDR_WORKSPACE=w1
export HERDR_ENV=1
export PATH="$FIXTURE_BIN:$PATH"

new_worktree success
output=$(run_helper) || fail 'settled merged worker cleanup succeeds'
jq -e \
  '.status == "cleaned" and .branch == "test/success" and
   .base == "main" and .tab_id == "w1:t2"' \
  >/dev/null <<<"$output" || fail 'success returns cleanup metadata'
[[ "$(< "$FAKE_HERDR_CLOSE_LOG")" == "$FAKE_HERDR_TAB" ]] ||
  fail 'success closes only the returned tab'
expected=$(printf '%s\n' remove --with-branch "$FAKE_WTP_BRANCH")
[[ "$(< "$FAKE_WTP_LOG")" == "$expected" ]] ||
  fail 'success uses only non-forced wtp removal'
[[ ! -d "$FAKE_HERDR_WORKTREE" ]] || fail 'success leaves the worktree'
git -C "$FIXTURE_REPO" show-ref --verify --quiet \
  "refs/heads/$FAKE_WTP_BRANCH" && fail 'success leaves the local branch'
printf '%s\n' 'ok - settled merged worker is cleaned through bounded commands'

for worker_status in working blocked unknown; do
  new_worktree "status-$worker_status"
  export FAKE_HERDR_AGENT_STATUS=$worker_status
  if run_helper >"$TMPDIR_TEST/status.out" 2>"$TMPDIR_TEST/status.err"; then
    fail "$worker_status worker cleanup unexpectedly succeeds"
  fi
  grep -Fq "status $worker_status" "$TMPDIR_TEST/status.err" ||
    fail "$worker_status worker blocker is not precise"
  assert_no_mutation "$worker_status worker"
done
printf '%s\n' 'ok - running, blocked, and unknown workers fail before mutation'

new_worktree dirty
printf '%s\n' dirty > "$FAKE_HERDR_WORKTREE/untracked.txt"
if run_helper >"$TMPDIR_TEST/dirty.out" 2>"$TMPDIR_TEST/dirty.err"; then
  fail 'dirty worktree cleanup unexpectedly succeeds'
fi
grep -Fq 'linked worktree is dirty' "$TMPDIR_TEST/dirty.err" ||
  fail 'dirty worktree blocker is not precise'
assert_no_mutation 'dirty worktree'
printf '%s\n' 'ok - dirty worktree fails before mutation'

new_worktree unmerged
printf '%s\n' change > "$FAKE_HERDR_WORKTREE/change.txt"
git -C "$FAKE_HERDR_WORKTREE" add change.txt
git -C "$FAKE_HERDR_WORKTREE" commit -qm 'test: unmerged change'
if run_helper >"$TMPDIR_TEST/unmerged.out" 2>"$TMPDIR_TEST/unmerged.err"; then
  fail 'unmerged branch cleanup unexpectedly succeeds'
fi
grep -Fq 'is not contained in local integration base main' \
  "$TMPDIR_TEST/unmerged.err" || fail 'unmerged blocker is not precise'
assert_no_mutation 'unmerged branch'
printf '%s\n' 'ok - unmerged branch fails before mutation'

new_worktree equal-base
export HELPER_BASE=$FAKE_WTP_BRANCH
if run_helper >"$TMPDIR_TEST/equal-base.out" \
  2>"$TMPDIR_TEST/equal-base.err"; then
  fail 'worker branch equal to integration base unexpectedly succeeds'
fi
grep -Fq 'worker branch cannot equal integration base' \
  "$TMPDIR_TEST/equal-base.err" || fail 'equal branch/base blocker is not precise'
assert_no_mutation 'worker branch equal to integration base'
printf '%s\n' 'ok - worker branch cannot equal the integration base'

new_worktree mismatched
export FAKE_HERDR_PANE_CWD=$FIXTURE_REPO
if run_helper >"$TMPDIR_TEST/mismatch.out" 2>"$TMPDIR_TEST/mismatch.err"; then
  fail 'mismatched pane cleanup unexpectedly succeeds'
fi
grep -Fq 'does not target worktree' "$TMPDIR_TEST/mismatch.err" ||
  fail 'mismatched pane blocker is not precise'
assert_no_mutation 'mismatched pane'
printf '%s\n' 'ok - mismatched returned resources fail before mutation'

new_worktree ambiguous
export FAKE_HERDR_PANE_COUNT=2
if run_helper >"$TMPDIR_TEST/ambiguous.out" \
  2>"$TMPDIR_TEST/ambiguous.err"; then
  fail 'ambiguous tab cleanup unexpectedly succeeds'
fi
grep -Fq 'cleanup is ambiguous' "$TMPDIR_TEST/ambiguous.err" ||
  fail 'ambiguous tab blocker is not precise'
assert_no_mutation 'ambiguous tab'
printf '%s\n' 'ok - tabs with unreturned resources fail before mutation'

new_worktree locked
git -C "$FIXTURE_REPO" worktree lock "$FAKE_HERDR_WORKTREE"
if run_helper >"$TMPDIR_TEST/locked.out" 2>"$TMPDIR_TEST/locked.err"; then
  fail 'locked worktree cleanup unexpectedly succeeds'
fi
grep -Fq 'worktree is locked or prunable' "$TMPDIR_TEST/locked.err" ||
  fail 'locked worktree blocker is not precise'
assert_no_mutation 'locked worktree'
printf '%s\n' 'ok - force-requiring worktree state fails before mutation'

new_worktree stale-path
export FAKE_WTP_RECREATE_PATH=true
if run_helper >"$TMPDIR_TEST/stale-path.out" \
  2>"$TMPDIR_TEST/stale-path.err"; then
  fail 'cleanup with a remaining filesystem path unexpectedly succeeds'
fi
grep -Fq 'Git cleanup completed, but worktree path remains' \
  "$TMPDIR_TEST/stale-path.err" ||
  fail 'remaining worktree path partial failure is not precise'
[[ -e "$FAKE_HERDR_CLOSED_MARKER" ]] ||
  fail 'remaining-path fixture did not close the returned tab'
[[ -d "$FAKE_HERDR_WORKTREE" ]] ||
  fail 'remaining-path fixture did not recreate the worktree path'
git -C "$FIXTURE_REPO" worktree list --porcelain |
  grep -Fq "worktree $FAKE_HERDR_WORKTREE" &&
  fail 'remaining-path fixture left a Git worktree registration'
git -C "$FIXTURE_REPO" show-ref --verify --quiet \
  "refs/heads/$FAKE_WTP_BRANCH" &&
  fail 'remaining-path fixture left the local branch'
printf '%s\n' 'ok - remaining filesystem path is a post-close partial failure'

new_worktree partial
export FAKE_HERDR_AGENT_STATUS='done'
export FAKE_WTP_FAIL=true
if run_helper >"$TMPDIR_TEST/partial.out" 2>"$TMPDIR_TEST/partial.err"; then
  fail 'partial cleanup unexpectedly succeeds'
fi
grep -Fq 'Herdr tab w1:t2 closed, but non-forced wtp cleanup failed' \
  "$TMPDIR_TEST/partial.err" || fail 'partial failure is not reported honestly'
[[ -e "$FAKE_HERDR_CLOSED_MARKER" ]] ||
  fail 'partial fixture did not close the returned tab'
[[ -d "$FAKE_HERDR_WORKTREE" ]] ||
  fail 'partial failure unexpectedly removed the worktree'
git -C "$FIXTURE_REPO" show-ref --verify --quiet \
  "refs/heads/$FAKE_WTP_BRANCH" ||
  fail 'partial failure unexpectedly removed the branch'
printf '%s\n' \
  'ok - Herdr-first partial failure preserves and reports Git state'

printf '%s\n' 'All herdr-worktree-cleanup tests passed.'
