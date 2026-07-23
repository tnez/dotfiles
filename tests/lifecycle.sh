#!/bin/bash

set -u

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
REPO_ROOT=${SCRIPT_DIR%/*}
TMPDIR_TEST=$(mktemp -d -t dotfiles-tests.XXXXXX) || exit 1
FIXTURE=$TMPDIR_TEST/repo
FIXTURE_PHYSICAL=
HOME_TEST=$TMPDIR_TEST/home
GIT_PRIMARY=$TMPDIR_TEST/git-primary
GIT_LINKED=$TMPDIR_TEST/git-linked
GIT_HOME=$TMPDIR_TEST/git-home
OUTPUT=
STATUS=0
FAILURES=0
STOW_BIN=$(command -v stow 2>/dev/null || true)
JQ_BIN=$(command -v jq 2>/dev/null || true)

cleanup() {
  rm -rf "$TMPDIR_TEST"
}
trap cleanup EXIT HUP INT TERM

run_command() {
  OUTPUT=$("$@" 2>&1)
  STATUS=$?
}

assert_status() {
  local expected=$1 label=$2

  if [ "$STATUS" -ne "$expected" ]; then
    printf 'not ok - %s (expected %s, got %s)\n%s\n' \
      "$label" "$expected" "$STATUS" "$OUTPUT"
    FAILURES=$((FAILURES + 1))
  else
    printf 'ok - %s\n' "$label"
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

mkdir -p "$FIXTURE/.git" "$FIXTURE/brew" "$HOME_TEST" \
  "$TMPDIR_TEST/bin" "$FIXTURE/sample" \
  "$FIXTURE/codex/dot-codex" \
  "$FIXTURE/agents/dot-agents/skills/managed" || exit 1
cp "$REPO_ROOT/dotfiles" "$FIXTURE/dotfiles" || exit 1
cp "$REPO_ROOT/dotfiles-trusted-formulae" \
  "$FIXTURE/dotfiles-trusted-formulae" || exit 1
: > "$FIXTURE/brew/Brewfile"
printf 'agents no-folding\nsample standard\n' > \
  "$FIXTURE/dotfiles-packages"
printf 'fixture\n' > "$FIXTURE/sample/dot-sample"
printf 'fixture = true\n' > "$FIXTURE/codex/dot-codex/config.base.toml"
printf 'managed v1\n' > \
  "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md"
chmod +x "$FIXTURE/dotfiles"
ln -s ../repo/dotfiles "$TMPDIR_TEST/bin/dotfiles"
FIXTURE_PHYSICAL=$(cd -P "$FIXTURE" >/dev/null 2>&1 && pwd)

for command in bootstrap doctor plan apply provision upgrade; do
  run_command "$FIXTURE/dotfiles" "$command" --help
  assert_status 0 "$command help exits successfully"
done

if grep -q '^satococoa/tap/wtp$' "$REPO_ROOT/dotfiles-trusted-formulae"; then
  printf 'ok - wtp formula-specific trust is recorded\n'
else
  printf 'not ok - wtp formula-specific trust is missing\n'
  FAILURES=$((FAILURES + 1))
fi

legacy_runtime_root='Code/tnez/dotfiles'
runtime_files=(
  "$REPO_ROOT/profile/dot-profile"
  "$REPO_ROOT/scripts/dot-scripts/quick-gh-dashboard.sh"
  "$REPO_ROOT/sesh/dot-config/sesh/sesh.toml"
  "$REPO_ROOT/scripts/dot-scripts/herdr-session.sh"
  "$REPO_ROOT/codex/dot-codex/config.base.toml"
)
if grep -q "$legacy_runtime_root" "${runtime_files[@]}"; then
  printf 'not ok - live runtime config references the legacy checkout\n'
  FAILURES=$((FAILURES + 1))
else
  printf 'ok - live runtime config uses checkout-independent paths\n'
fi

run_command env HOME="$HOME_TEST" PATH=/usr/bin:/bin \
  "$TMPDIR_TEST/bin/dotfiles" doctor
assert_status 1 "doctor reports convergence without optional dependencies"
assert_contains "Repository: $FIXTURE_PHYSICAL" \
  "CLI resolves its own relative symlink"
assert_contains "GNU Stow is unavailable" "doctor explains missing Stow"

mkdir -p "$GIT_PRIMARY/brew" "$GIT_HOME/.local/bin"
cp "$REPO_ROOT/dotfiles" "$GIT_PRIMARY/dotfiles"
printf '# no reviewed formulae in launcher fixture\n' > \
  "$GIT_PRIMARY/dotfiles-trusted-formulae"
printf '# no Stow packages in launcher fixture\n' > \
  "$GIT_PRIMARY/dotfiles-packages"
: > "$GIT_PRIMARY/brew/Brewfile"
chmod +x "$GIT_PRIMARY/dotfiles"
git -C "$GIT_PRIMARY" init -q
git -C "$GIT_PRIMARY" add .
git -C "$GIT_PRIMARY" -c user.name=Test -c user.email=test@example.com \
  commit -qm fixture
git -C "$GIT_PRIMARY" worktree add -qb feature "$GIT_LINKED"
ln -s "$GIT_PRIMARY/dotfiles" "$GIT_HOME/.local/bin/dotfiles"

run_command env HOME="$GIT_HOME" PATH=/usr/bin:/bin \
  "$GIT_LINKED/dotfiles" doctor
assert_status 1 "linked doctor accepts the primary-checkout launcher"
assert_contains "launcher targets the primary checkout" \
  "linked doctor recognizes the same Git repository primary"
run_command env HOME="$GIT_HOME" PATH=/usr/bin:/bin \
  "$GIT_LINKED/dotfiles" plan
assert_status 0 "linked plan accepts the primary-checkout launcher"
assert_contains "repository primary checkout" \
  "linked plan reports the canonical launcher"

rm -f "$GIT_HOME/.local/bin/dotfiles"
ln -s "$FIXTURE/dotfiles" "$GIT_HOME/.local/bin/dotfiles"
run_command env HOME="$GIT_HOME" PATH=/usr/bin:/bin \
  "$GIT_LINKED/dotfiles" doctor
assert_status 1 "linked doctor rejects an unrelated checkout launcher"
assert_contains "[CONFLICT] launcher" \
  "unrelated checkout remains a launcher conflict"

run_command env HOME="$HOME_TEST" "$REPO_ROOT/dotfiles" plan
assert_status 0 "linked-worktree plan remains read-only"
assert_contains "defer Stow simulation" \
  "linked-worktree plan defers misleading Stow checks"

run_command env HOME="$HOME_TEST" PATH=/usr/bin:/bin \
  "$FIXTURE/dotfiles" plan
assert_status 0 "primary-checkout plan works without dependencies"
assert_contains "provision GNU Stow" "plan explains deferred Stow simulation"

if [ -n "$STOW_BIN" ]; then
  ln -s "$STOW_BIN" "$TMPDIR_TEST/bin/stow"
  run_command env HOME="$HOME_TEST" PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    "$FIXTURE/dotfiles" plan
  assert_status 0 \
    "primary-checkout Stow simulation succeeds in temporary home"
  assert_contains "STOW PLAN: sample" \
    "plan uses the explicit package manifest"

  mkdir -p "$HOME_TEST/.agents/skills/private"
  printf 'unmanaged skill\n' > \
    "$HOME_TEST/.agents/skills/private/SKILL.md"
  run_command env HOME="$HOME_TEST" PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    "$FIXTURE/dotfiles" apply
  assert_status 0 "apply converges a primary checkout in temporary home"
  if [ "$(readlink "$HOME_TEST/.local/bin/dotfiles")" = \
    "$FIXTURE_PHYSICAL/dotfiles" ]; then
    printf 'ok - apply installs a canonical CLI launcher\n'
  else
    printf 'not ok - apply launcher has the wrong target\n'
    FAILURES=$((FAILURES + 1))
  fi
  if [ "$(< "$HOME_TEST/.sample")" = fixture ]; then
    printf 'ok - apply activates the explicit Stow package\n'
  else
    printf 'not ok - apply did not activate the Stow package\n'
    FAILURES=$((FAILURES + 1))
  fi
  if [ "$(< "$HOME_TEST/.agents/skills/private/SKILL.md")" = \
    "unmanaged skill" ]; then
    printf 'ok - apply preserves an unrelated regular SKILL.md\n'
  else
    printf 'not ok - apply changed an unrelated regular SKILL.md\n'
    FAILURES=$((FAILURES + 1))
  fi

  printf 'managed v2\n' > \
    "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md"
  run_command env HOME="$HOME_TEST" PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    "$FIXTURE/dotfiles" apply
  assert_status 0 "second apply updates a state-owned materialized skill"
  if [ "$(< "$HOME_TEST/.agents/skills/managed/SKILL.md")" = \
    "managed v2" ]; then
    printf 'ok - updated skill source is materialized\n'
  else
    printf 'not ok - updated skill source was not materialized\n'
    FAILURES=$((FAILURES + 1))
  fi

  rm -f "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md"
  run_command env HOME="$HOME_TEST" PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    "$FIXTURE/dotfiles" apply
  assert_status 0 "apply removes an unchanged stale state-owned skill"
  if [ ! -e "$HOME_TEST/.agents/skills/managed/SKILL.md" ] &&
    [ ! -L "$HOME_TEST/.agents/skills/managed/SKILL.md" ]; then
    printf 'ok - stale state-owned skill is removed\n'
  else
    printf 'not ok - stale state-owned skill remains\n'
    FAILURES=$((FAILURES + 1))
  fi

  printf 'managed v3\n' > \
    "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md"
  run_command env HOME="$HOME_TEST" PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    "$FIXTURE/dotfiles" apply
  assert_status 0 "apply rematerializes a restored managed skill"
  printf 'user modified\n' > \
    "$HOME_TEST/.agents/skills/managed/SKILL.md"
  run_command env HOME="$HOME_TEST" PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    "$FIXTURE/dotfiles" apply
  assert_status 1 "apply refuses a user-modified state-owned skill"
  assert_contains "managed skill was modified" \
    "modified state-owned skill is reported precisely"
  if [ "$(< "$HOME_TEST/.agents/skills/managed/SKILL.md")" = \
    "user modified" ]; then
    printf 'ok - user-modified state-owned skill is preserved\n'
  else
    printf 'not ok - user-modified state-owned skill changed\n'
    FAILURES=$((FAILURES + 1))
  fi
  cp "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md" \
    "$HOME_TEST/.agents/skills/managed/SKILL.md"

  mkdir -p "$FIXTURE/agents/dot-agents/skills/unmanaged" \
    "$HOME_TEST/.agents/skills/unmanaged"
  printf 'repository version\n' > \
    "$FIXTURE/agents/dot-agents/skills/unmanaged/SKILL.md"
  printf 'unmanaged version\n' > \
    "$HOME_TEST/.agents/skills/unmanaged/SKILL.md"
  run_command env HOME="$HOME_TEST" PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    "$FIXTURE/dotfiles" apply
  assert_status 1 "apply refuses an unmanaged conflicting skill"
  assert_contains "unmanaged skill file blocks activation" \
    "unmanaged skill conflict is reported"
  if [ "$(< "$HOME_TEST/.agents/skills/unmanaged/SKILL.md")" = \
    "unmanaged version" ]; then
    printf 'ok - unmanaged conflicting skill is preserved\n'
  else
    printf 'not ok - unmanaged conflicting skill changed\n'
    FAILURES=$((FAILURES + 1))
  fi
  rm -rf "$FIXTURE/agents/dot-agents/skills/unmanaged" \
    "$HOME_TEST/.agents/skills/unmanaged"

  ln -s "$REPO_ROOT/tests/fake-brew.sh" "$TMPDIR_TEST/bin/brew"
  if [ -n "$JQ_BIN" ]; then
    ln -s "$REPO_ROOT/tests/fake-herdr.sh" "$TMPDIR_TEST/bin/herdr"
    ln -s "$JQ_BIN" "$TMPDIR_TEST/bin/jq"
    rm -f "$TMPDIR_TEST/herdr-plugin-installed"
    run_command env HOME="$HOME_TEST" \
      PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
      FAKE_HERDR_PLUGIN_ENABLED=false \
      FAKE_HERDR_PLUGIN_MARKER="$TMPDIR_TEST/herdr-plugin-installed" \
      "$FIXTURE/dotfiles" apply
    assert_status 0 "apply converges a disabled pinned Herdr plugin"
    if [ -e "$TMPDIR_TEST/herdr-plugin-installed" ]; then
      printf 'ok - disabled pinned Herdr plugin is reinstalled\n'
    else
      printf 'not ok - disabled pinned Herdr plugin was accepted\n'
      FAILURES=$((FAILURES + 1))
    fi

    rm -f "$TMPDIR_TEST/herdr-plugin-installed"
    run_command env HOME="$HOME_TEST" \
      PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
      FAKE_HERDR_PLUGIN_ENABLED=true \
      FAKE_HERDR_PLUGIN_COMMIT=0000000000000000000000000000000000000000 \
      FAKE_HERDR_PLUGIN_MARKER="$TMPDIR_TEST/herdr-plugin-installed" \
      "$FIXTURE/dotfiles" apply
    assert_status 0 \
      "apply converges an enabled Herdr plugin at the wrong commit"
    if [ -e "$TMPDIR_TEST/herdr-plugin-installed" ]; then
      printf 'ok - wrong Herdr plugin commit is reinstalled\n'
    else
      printf 'not ok - wrong Herdr plugin commit was accepted\n'
      FAILURES=$((FAILURES + 1))
    fi

    rm -f "$TMPDIR_TEST/herdr-plugin-installed"
    run_command env HOME="$HOME_TEST" \
      PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
      FAKE_HERDR_PLUGIN_ENABLED=true \
      FAKE_HERDR_PLUGIN_MARKER="$TMPDIR_TEST/herdr-plugin-installed" \
      "$FIXTURE/dotfiles" apply
    assert_status 0 "apply accepts an enabled pinned Herdr plugin"
    if [ ! -e "$TMPDIR_TEST/herdr-plugin-installed" ]; then
      printf 'ok - enabled pinned Herdr plugin is left unchanged\n'
    else
      printf 'not ok - enabled pinned Herdr plugin was reinstalled\n'
      FAILURES=$((FAILURES + 1))
    fi
    rm -f "$TMPDIR_TEST/bin/herdr" "$TMPDIR_TEST/bin/jq"
  else
    printf 'ok - Herdr plugin condition test skipped (jq unavailable)\n'
  fi

  run_command env HOME="$HOME_TEST" \
    PATH="$TMPDIR_TEST/bin:/usr/bin:/bin" \
    FAKE_BREW_MARKER="$TMPDIR_TEST/brew-mutated" \
    "$FIXTURE/dotfiles" bootstrap --non-interactive --yes
  assert_status 3 "noninteractive bootstrap stops for formula trust"
  assert_contains "ACTION_REQUIRED: review formula trust" \
    "generic --yes does not grant formula trust"
  if [ ! -e "$TMPDIR_TEST/brew-mutated" ]; then
    printf 'ok - trust policy stops before provisioning changes\n'
  else
    printf 'not ok - provisioning ran before formula trust approval\n'
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$TMPDIR_TEST/bin/brew"
else
  printf 'ok - Stow convergence test skipped (stow unavailable)\n'
fi

rm -rf "$HOME_TEST/.local"
mkdir -p "$HOME_TEST/.local/bin"
printf 'unmanaged\n' > "$HOME_TEST/.local/bin/dotfiles"
run_command env HOME="$HOME_TEST" PATH=/usr/bin:/bin \
  "$FIXTURE/dotfiles" plan
assert_status 1 "plan fails on an unmanaged launcher"
assert_contains "CONFLICT: launcher" "plan exposes launcher conflict"
rm -rf "$HOME_TEST/.local"

for command in bootstrap apply provision upgrade; do
  case "$command" in
    bootstrap)
      run_command env HOME="$HOME_TEST" \
        "$REPO_ROOT/dotfiles" bootstrap --non-interactive --yes
      ;;
    provision|upgrade)
      run_command env HOME="$HOME_TEST" \
        "$REPO_ROOT/dotfiles" "$command" --non-interactive \
        --trust-formula modem-dev/tap/hunk
      ;;
    *)
      run_command env HOME="$HOME_TEST" "$REPO_ROOT/dotfiles" "$command"
      ;;
  esac
  assert_status 3 "$command refuses a linked worktree"
  assert_contains "linked/disposable worktree" \
    "$command explains linked-worktree refusal"
done

[ ! -e "$HOME_TEST/.local" ] || {
  printf 'not ok - refused commands changed the temporary home\n'
  FAILURES=$((FAILURES + 1))
}

run_command "$FIXTURE/dotfiles" apply --unknown
assert_status 2 "unknown command options fail as usage errors"

run_command "$FIXTURE/dotfiles" provision --non-interactive \
  --trust-formula example/tap/unreviewed
assert_status 3 "unreviewed formula trust requires action"
assert_contains "not in dotfiles-trusted-formulae" \
  "formula trust is constrained by the manifest"

run_command "$REPO_ROOT/install.sh" --path "$REPO_ROOT" --non-interactive
assert_status 3 "installer refuses a linked checkout"

if [ "$FAILURES" -ne 0 ]; then
  printf '%s lifecycle test(s) failed\n' "$FAILURES" >&2
  exit 1
fi

printf 'All lifecycle tests passed.\n'
