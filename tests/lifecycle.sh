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
FIXTURE_BIN=$TMPDIR_TEST/fixture-bin
LINKED_BIN=$TMPDIR_TEST/linked-bin
KNOWLEDGE_BASE=$TMPDIR_TEST/knowledge-base
HOST_MUTATION_MARKER=$TMPDIR_TEST/host-mutation-attempted
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

run_fixture() {
  run_command env -i \
    HOME="$HOME_TEST" \
    PATH="$FIXTURE_BIN:/usr/bin:/bin" \
    TMPDIR="$TMPDIR_TEST" \
    TNEZDEV_KNOWLEDGE_BASE_ROOT="$KNOWLEDGE_BASE" \
    DOTFILES_TEST_HOST_MUTATION_MARKER="$HOST_MUTATION_MARKER" \
    "$FIXTURE_BIN/dotfiles" "$@"
}

run_fixture_with_root() {
  local root=$1
  shift
  run_command env -i \
    HOME="$HOME_TEST" \
    PATH="$FIXTURE_BIN:/usr/bin:/bin" \
    TMPDIR="$TMPDIR_TEST" \
    TNEZDEV_KNOWLEDGE_BASE_ROOT="$root" \
    DOTFILES_TEST_HOST_MUTATION_MARKER="$HOST_MUTATION_MARKER" \
    "$FIXTURE_BIN/dotfiles" "$@"
}

run_linked() {
  run_command env -i \
    HOME="$GIT_HOME" \
    PATH="$LINKED_BIN:/usr/bin:/bin" \
    TMPDIR="$TMPDIR_TEST" \
    TNEZDEV_KNOWLEDGE_BASE_ROOT="$KNOWLEDGE_BASE" \
    DOTFILES_TEST_HOST_MUTATION_MARKER="$HOST_MUTATION_MARKER" \
    "$GIT_LINKED/dotfiles" "$@"
}

run_linked_installer() {
  run_command env -i \
    HOME="$GIT_HOME" \
    PATH="$LINKED_BIN:/usr/bin:/bin" \
    TMPDIR="$TMPDIR_TEST" \
    TNEZDEV_KNOWLEDGE_BASE_ROOT="$KNOWLEDGE_BASE" \
    DOTFILES_TEST_HOST_MUTATION_MARKER="$HOST_MUTATION_MARKER" \
    "$GIT_LINKED/install.sh" --path "$GIT_LINKED" --non-interactive
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

write_test_module() {
  local root=$1 name=$2 platform=$3 mode=$4

  mkdir -p "$root/$name"
  cat > "$root/$name/AGENT.md" <<EOF
# $name fixture

<!-- dotfiles-module
version 1
platform $platform
stow $mode
-->
EOF
}

mkdir -p "$FIXTURE/.git" "$FIXTURE/brew" "$HOME_TEST" \
  "$FIXTURE_BIN" "$LINKED_BIN" "$FIXTURE/sample" \
  "$KNOWLEDGE_BASE/root/skills/present-for-decision" \
  "$KNOWLEDGE_BASE/root/processes" \
  "$KNOWLEDGE_BASE/root/principles" \
  "$KNOWLEDGE_BASE/root/meta" \
  "$FIXTURE/codex/dot-codex" "$FIXTURE/lib/dotfiles" \
  "$FIXTURE/agents/dot-agents/skills/managed" || exit 1
KNOWLEDGE_BASE=$(cd -P "$KNOWLEDGE_BASE" >/dev/null 2>&1 && pwd) || exit 1
cp "$REPO_ROOT/dotfiles" "$FIXTURE/dotfiles" || exit 1
cp "$REPO_ROOT/lib/dotfiles/modules.sh" \
  "$FIXTURE/lib/dotfiles/modules.sh" || exit 1
printf '# no reviewed formulae in primary fixture\n' > \
  "$FIXTURE/dotfiles-trusted-formulae"
printf 'present-for-decision\n' > \
  "$FIXTURE/dotfiles-knowledge-base-skill-adapter"
: > "$FIXTURE/brew/Brewfile"
write_test_module "$FIXTURE" agents darwin no-folding
write_test_module "$FIXTURE" brew darwin none
write_test_module "$FIXTURE" sample darwin standard
printf 'fixture\n' > "$FIXTURE/sample/dot-sample"
printf 'fixture = true\n' > "$FIXTURE/codex/dot-codex/config.base.toml"
printf 'managed v1\n' > \
  "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md"
printf '# Agent Guide\n' > "$KNOWLEDGE_BASE/AGENTS.md"
printf '# Knowledge Base\n' > "$KNOWLEDGE_BASE/root/index.md"
cat > "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.md" <<'EOF'
---
name: present-for-decision
description: Fixture decision skill.
metadata:
  okf-status: trial
---

# Present for Decision
EOF
for context in \
  processes/initiative-wayfinding.md \
  principles/knowledge-carrying-cost.md \
  meta/agent-consumption.md; do
  printf '# Required Context\n' > "$KNOWLEDGE_BASE/root/$context"
done
chmod +x "$FIXTURE/dotfiles"
ln -s "$REPO_ROOT/tests/fake-brew.sh" "$FIXTURE_BIN/brew"
ln -s "$REPO_ROOT/tests/fake-brew.sh" "$LINKED_BIN/brew"
ln -s "$REPO_ROOT/tests/fake-uname.sh" "$FIXTURE_BIN/uname"
ln -s "$REPO_ROOT/tests/fake-uname.sh" "$LINKED_BIN/uname"
for command in bun curl gh git herdr jq launchctl npm opencode pi stow; do
  ln -s "$REPO_ROOT/tests/fail-command.sh" "$LINKED_BIN/$command"
done
ln -s "$FIXTURE/dotfiles" "$FIXTURE_BIN/dotfiles"
FIXTURE_PHYSICAL=$(cd -P "$FIXTURE" >/dev/null 2>&1 && pwd)

for command in bootstrap doctor plan apply provision upgrade modules; do
  run_fixture "$command" --help
  assert_status 0 "$command help exits successfully"
done

# shellcheck disable=SC2016
run_command env -i \
  HOME="$HOME_TEST" \
  PATH="/usr/bin:/bin" \
  /bin/sh -c '. "$1"; printf "%s\n" "$TNEZDEV_KNOWLEDGE_BASE_ROOT"' \
  profile-test "$REPO_ROOT/profile/dot-profile"
assert_status 0 "shared profile loads in a POSIX shell"
assert_contains "$HOME_TEST/Code/tnezdev/knowledge-base/main" \
  "shared profile supplies the portable knowledge-base default"

{
  printf 'export TNEZDEV_KNOWLEDGE_BASE_ROOT="%s"\n' "$KNOWLEDGE_BASE"
  printf 'export TNEZDEV_LOCAL_CONTEXT_ROOT="%s"\n' \
    "$HOME_TEST/Documents"
} >"$HOME_TEST/.profile.local"
# shellcheck disable=SC2016
run_command env -i \
  HOME="$HOME_TEST" \
  PATH="/usr/bin:/bin" \
  /bin/sh -c '
    . "$1"
    printenv TNEZDEV_KNOWLEDGE_BASE_ROOT
    printenv TNEZDEV_LOCAL_CONTEXT_ROOT
  ' profile-test "$REPO_ROOT/profile/dot-profile"
assert_status 0 "shared profile loads machine-specific overrides"
assert_contains "$KNOWLEDGE_BASE" \
  "machine-specific knowledge-base root replaces the default"
assert_contains "$HOME_TEST/Documents" \
  "machine-specific local context root is exported"
rm -f "$HOME_TEST/.profile.local"

ln -s "$REPO_ROOT/profile/dot-profile" "$HOME_TEST/.profile"
{
  printf 'export TNEZDEV_KNOWLEDGE_BASE_ROOT="%s"\n' "$KNOWLEDGE_BASE"
  printf 'export TNEZDEV_LOCAL_CONTEXT_ROOT="%s"\n' \
    "$HOME_TEST/Documents"
} >"$HOME_TEST/.profile.local"
launchctl_log=$TMPDIR_TEST/launchctl-environment.log
run_command env -i \
  HOME="$HOME_TEST" \
  PATH="/usr/bin:/bin" \
  LAUNCHCTL_BIN="$REPO_ROOT/tests/fake-launchctl-environment.sh" \
  FAKE_LAUNCHCTL_LOG="$launchctl_log" \
  /bin/sh "$REPO_ROOT/scripts/dot-scripts/sync-launchd-environment.sh"
assert_status 0 "GUI environment synchronizer loads the shared profile"
OUTPUT=$(< "$launchctl_log")
assert_contains "setenv TNEZDEV_KNOWLEDGE_BASE_ROOT=$KNOWLEDGE_BASE" \
  "GUI environment publishes the configured knowledge-base root"
assert_contains "setenv TNEZDEV_LOCAL_CONTEXT_ROOT=$HOME_TEST/Documents" \
  "GUI environment publishes the configured local-context root"
assert_contains "setenv PATH=" "GUI environment publishes the resolved PATH"
rm -f "$HOME_TEST/.profile" "$HOME_TEST/.profile.local"

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

if [ ! -e "$REPO_ROOT/claude/README.md" ] &&
  [ -f "$REPO_ROOT/claude/dot-claude/README.md" ]; then
  printf 'ok - Claude LEGACY documentation installs only under ~/.claude\n'
else
  printf 'not ok - Claude documentation would create an unintended ~/README.md\n'
  FAILURES=$((FAILURES + 1))
fi

run_fixture doctor
assert_status 1 "doctor reports convergence without optional dependencies"
assert_contains "Repository: $FIXTURE_PHYSICAL" \
  "CLI resolves its own relative symlink"
assert_contains "GNU Stow is unavailable" "doctor explains missing Stow"
assert_contains "[OK] tnezdev knowledge base: $KNOWLEDGE_BASE" \
  "doctor accepts a configured knowledge-base root"
assert_contains "create knowledge-base skill adapter" \
  "doctor reports the missing knowledge-base adapter"

run_command env -i \
  HOME="$HOME_TEST" \
  PATH="$FIXTURE_BIN:/usr/bin:/bin" \
  TMPDIR="$TMPDIR_TEST" \
  "$FIXTURE_BIN/dotfiles" doctor
assert_status 1 "doctor rejects an unset knowledge-base root"
assert_contains "TNEZDEV_KNOWLEDGE_BASE_ROOT is not set" \
  "doctor explains the missing knowledge-base environment variable"

run_command env -i \
  HOME="$HOME_TEST" \
  PATH="$FIXTURE_BIN:/usr/bin:/bin" \
  TMPDIR="$TMPDIR_TEST" \
  TNEZDEV_KNOWLEDGE_BASE_ROOT="relative/knowledge-base" \
  "$FIXTURE_BIN/dotfiles" doctor
assert_status 1 "doctor rejects a relative knowledge-base root"
assert_contains "TNEZDEV_KNOWLEDGE_BASE_ROOT must be absolute" \
  "doctor explains the absolute-path requirement"

run_command env -i \
  HOME="$HOME_TEST" \
  PATH="$FIXTURE_BIN:/usr/bin:/bin" \
  TMPDIR="$TMPDIR_TEST" \
  TNEZDEV_KNOWLEDGE_BASE_ROOT="$TMPDIR_TEST/missing-knowledge-base" \
  "$FIXTURE_BIN/dotfiles" doctor
assert_status 1 "doctor rejects a missing knowledge-base checkout"
assert_contains "knowledge-base root is unreadable" \
  "doctor identifies the missing knowledge-base checkout"

mv "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.md" \
  "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.invalid"
run_fixture doctor
assert_status 1 "doctor rejects a missing knowledge-base skill entrypoint"
assert_contains "knowledge-base skill entrypoint is unreadable" \
  "doctor identifies the missing skill entrypoint"
mv "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.invalid" \
  "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.md"

cp "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.md" \
  "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.valid"
printf '%s\n' '---' 'name: wrong-name' 'description: Invalid.' '---' > \
  "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.md"
run_fixture plan
assert_status 1 "plan rejects invalid knowledge-base skill frontmatter"
assert_contains "invalid knowledge-base skill frontmatter" \
  "plan explains invalid skill metadata"
mv "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.valid" \
  "$KNOWLEDGE_BASE/root/skills/present-for-decision/SKILL.md"

rm -f "$KNOWLEDGE_BASE/root/meta/agent-consumption.md"
run_fixture doctor
assert_status 1 "doctor rejects missing bundle-root skill context"
assert_contains "required knowledge-base skill context is unreadable" \
  "doctor resolves required context below the OKF bundle root"
printf '# Required Context\n' > \
  "$KNOWLEDGE_BASE/root/meta/agent-consumption.md"

mkdir -p "$GIT_PRIMARY/brew" "$GIT_PRIMARY/lib/dotfiles" \
  "$GIT_HOME/.local/bin"
cp "$REPO_ROOT/dotfiles" "$GIT_PRIMARY/dotfiles"
cp "$REPO_ROOT/lib/dotfiles/modules.sh" \
  "$GIT_PRIMARY/lib/dotfiles/modules.sh"
cp "$REPO_ROOT/install.sh" "$GIT_PRIMARY/install.sh"
printf '# no reviewed formulae in launcher fixture\n' > \
  "$GIT_PRIMARY/dotfiles-trusted-formulae"
write_test_module "$GIT_PRIMARY" brew darwin none
printf 'present-for-decision\n' > \
  "$GIT_PRIMARY/dotfiles-knowledge-base-skill-adapter"
: > "$GIT_PRIMARY/brew/Brewfile"
chmod +x "$GIT_PRIMARY/dotfiles" "$GIT_PRIMARY/install.sh"
git -C "$GIT_PRIMARY" init -q
git -C "$GIT_PRIMARY" add .
git -C "$GIT_PRIMARY" -c user.name=Test -c user.email=test@example.com \
  commit -qm fixture
git -C "$GIT_PRIMARY" worktree add -qb feature "$GIT_LINKED"
ln -s "$GIT_PRIMARY/dotfiles" "$GIT_HOME/.local/bin/dotfiles"

run_linked doctor
assert_status 1 "linked doctor accepts the primary-checkout launcher"
assert_contains "launcher targets the primary checkout" \
  "linked doctor recognizes the same Git repository primary"
run_linked plan
assert_status 0 "linked plan accepts the primary-checkout launcher"
assert_contains "repository primary checkout" \
  "linked plan reports the canonical launcher"
assert_contains "defer Stow simulation" \
  "linked-worktree plan remains read-only"

rm -f "$GIT_HOME/.local/bin/dotfiles"
ln -s "$FIXTURE/dotfiles" "$GIT_HOME/.local/bin/dotfiles"
run_linked doctor
assert_status 1 "linked doctor rejects an unrelated checkout launcher"
assert_contains "[CONFLICT] launcher" \
  "unrelated checkout remains a launcher conflict"

run_fixture plan
assert_status 0 "primary-checkout plan works without dependencies"
assert_contains "provision GNU Stow" "plan explains deferred Stow simulation"

if [ -n "$STOW_BIN" ]; then
  ln -s "$STOW_BIN" "$FIXTURE_BIN/stow"
  run_fixture plan
  assert_status 0 \
    "primary-checkout Stow simulation succeeds in temporary home"
  assert_contains "STOW PLAN: sample" \
    "plan uses the selected declarative modules"

  mkdir -p "$HOME_TEST/.agents/skills/private"
  printf 'unmanaged skill\n' > \
    "$HOME_TEST/.agents/skills/private/SKILL.md"
  run_fixture apply
  assert_status 0 "apply converges a primary checkout in temporary home"
  adapter=$HOME_TEST/.agents/skills/present-for-decision
  adapter_source=$KNOWLEDGE_BASE/root/skills/present-for-decision
  if [ -L "$adapter" ] && [ "$(readlink "$adapter")" = "$adapter_source" ]; then
    printf 'ok - apply creates the whole-directory knowledge-base adapter\n'
  else
    printf 'not ok - knowledge-base adapter is not the expected directory link\n'
    FAILURES=$((FAILURES + 1))
  fi
  if cmp -s "$adapter/SKILL.md" "$adapter_source/SKILL.md"; then
    printf 'ok - adapter exposes canonical skill frontmatter without copying\n'
  else
    printf 'not ok - adapter does not expose the canonical skill entrypoint\n'
    FAILURES=$((FAILURES + 1))
  fi
  if [ -f "$KNOWLEDGE_BASE/root/processes/initiative-wayfinding.md" ] &&
    [ -f "$KNOWLEDGE_BASE/root/principles/knowledge-carrying-cost.md" ] &&
    [ -f "$KNOWLEDGE_BASE/root/meta/agent-consumption.md" ]; then
    printf 'ok - adapter required context resolves below the OKF bundle root\n'
  else
    printf 'not ok - adapter required context is not bundle-root resolvable\n'
    FAILURES=$((FAILURES + 1))
  fi
  adapter_state=$HOME_TEST/.local/state/dotfiles/knowledge-base-skill-adapter
  if [ "$(< "$adapter_state")" = \
    "present-for-decision|$adapter_source" ]; then
    printf 'ok - adapter ownership records its exact generated target\n'
  else
    printf 'not ok - adapter ownership state is incorrect\n'
    FAILURES=$((FAILURES + 1))
  fi

  rm -f "$adapter" "$adapter_state"
  chmod 500 "$HOME_TEST/.agents/skills"
  run_fixture apply
  assert_status 1 "failed adapter creation does not claim ownership"
  chmod 700 "$HOME_TEST/.agents/skills"
  if [ ! -e "$adapter" ] && [ ! -L "$adapter" ] &&
    [ ! -e "$adapter_state" ] && [ ! -L "$adapter_state" ]; then
    printf 'ok - link failure leaves no adapter or ownership state\n'
  else
    printf 'not ok - link failure left adapter ownership behind\n'
    FAILURES=$((FAILURES + 1))
  fi
  run_fixture apply
  assert_status 0 "apply creates the adapter after link failure is repaired"
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

  KNOWLEDGE_BASE_MOVED=$TMPDIR_TEST/knowledge-base-moved
  cp -R "$KNOWLEDGE_BASE" "$KNOWLEDGE_BASE_MOVED"
  rm -rf "$KNOWLEDGE_BASE"
  KNOWLEDGE_BASE_MOVED=$(cd -P "$KNOWLEDGE_BASE_MOVED" >/dev/null 2>&1 && pwd) ||
    exit 1
  run_fixture_with_root "$KNOWLEDGE_BASE_MOVED" plan
  assert_status 0 "plan detects a dangling lifecycle-owned adapter"
  assert_contains "repair lifecycle-owned knowledge-base skill adapter" \
    "plan reports repair through the normal lifecycle path"
  run_fixture_with_root "$KNOWLEDGE_BASE_MOVED" apply
  assert_status 0 "apply repairs an adapter after the configured root moves"
  KNOWLEDGE_BASE=$KNOWLEDGE_BASE_MOVED
  adapter_source=$KNOWLEDGE_BASE/root/skills/present-for-decision
  if [ "$(readlink "$adapter")" = "$adapter_source" ]; then
    printf 'ok - repaired adapter targets the newly configured root\n'
  else
    printf 'not ok - repaired adapter retains its dangling target\n'
    FAILURES=$((FAILURES + 1))
  fi

  rm -f "$adapter"
  run_fixture plan
  assert_status 0 "plan detects a missing lifecycle-owned adapter"
  assert_contains "repair lifecycle-owned knowledge-base skill adapter" \
    "missing managed link is repairable only through the lifecycle"
  run_fixture apply
  assert_status 0 "apply repairs a missing lifecycle-owned adapter"

  stale_state_target=$TMPDIR_TEST/stale/root/skills/present-for-decision
  printf 'present-for-decision|%s\n' "$stale_state_target" > "$adapter_state"
  run_fixture doctor
  assert_status 1 "doctor rejects stale adapter ownership state"
  assert_contains "repair knowledge-base skill ownership state" \
    "doctor does not report a correct link with stale state as current"
  run_fixture plan
  assert_status 0 "plan identifies stale adapter ownership state"
  assert_contains "repair stale knowledge-base skill ownership state" \
    "plan isolates state repair from link repair"
  run_fixture apply
  assert_status 0 "apply repairs stale adapter ownership state"
  if [ "$(readlink "$adapter")" = "$adapter_source" ] &&
    [ "$(< "$adapter_state")" = \
      "present-for-decision|$adapter_source" ]; then
    printf 'ok - state repair preserves the correct link and converges ownership\n'
  else
    printf 'not ok - state repair changed the link or retained stale ownership\n'
    FAILURES=$((FAILURES + 1))
  fi

  owned_old_target=$TMPDIR_TEST/owned/root/skills/present-for-decision
  printf 'present-for-decision|%s\n' "$owned_old_target" > "$adapter_state"
  rm -f "$adapter"
  ln -s "$owned_old_target" "$adapter"
  run_fixture plan
  assert_status 0 "plan detects an incorrectly targeted managed adapter"
  assert_contains "repair lifecycle-owned knowledge-base skill adapter" \
    "ownership state permits repair only through the lifecycle"
  run_fixture apply
  assert_status 0 "apply repairs an incorrectly targeted managed adapter"
  if [ "$(readlink "$adapter")" = "$adapter_source" ]; then
    printf 'ok - managed adapter repair restores the configured source\n'
  else
    printf 'not ok - managed adapter repair retained the wrong target\n'
    FAILURES=$((FAILURES + 1))
  fi

  stale_owned_target=$TMPDIR_TEST/stale-owned/root/skills/present-for-decision
  changed_link_target=$TMPDIR_TEST/user-replaced-target
  printf 'present-for-decision|%s\n' "$stale_owned_target" > "$adapter_state"
  rm -f "$adapter"
  ln -s "$changed_link_target" "$adapter"
  run_fixture plan
  assert_status 1 "plan rejects a changed symlink with stale ownership state"
  assert_contains "symlink differs from recorded ownership" \
    "changed link is not mistaken for a lifecycle-owned moved-root adapter"
  run_fixture apply
  assert_status 1 "apply preserves a changed symlink with stale state"
  if [ "$(readlink "$adapter")" = "$changed_link_target" ] &&
    [ "$(< "$adapter_state")" = \
      "present-for-decision|$stale_owned_target" ]; then
    printf 'ok - changed symlink and stale ownership state are preserved\n'
  else
    printf 'not ok - lifecycle changed an unproven adapter symlink or its state\n'
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$adapter"
  ln -s "$adapter_source" "$adapter"
  printf 'present-for-decision|%s\n' "$adapter_source" > "$adapter_state"

  printf 'present-for-decision|/tmp/../root/skills/present-for-decision\n' > \
    "$adapter_state"
  run_fixture doctor
  assert_status 1 "doctor rejects traversal in adapter ownership state"
  assert_contains "invalid knowledge-base adapter ownership state" \
    "ownership state path traversal is rejected"
  printf 'present-for-decision|%s\n' "$adapter_source" > "$adapter_state"

  mv "$adapter_state" "$adapter_state.regular"
  ln -s "$adapter_state.regular" "$adapter_state"
  run_fixture plan
  assert_status 1 "plan rejects symlinked adapter ownership state"
  assert_contains "ownership state is a symlink" \
    "ownership cannot be asserted through an unmanaged state symlink"
  rm -f "$adapter_state"
  mv "$adapter_state.regular" "$adapter_state"

  : > "$FIXTURE/dotfiles-knowledge-base-skill-adapter"
  run_fixture plan
  assert_status 0 "plan reports safe adapter retirement"
  assert_contains "remove retired lifecycle-owned" \
    "retirement is constrained to the state-owned adapter"
  run_fixture apply
  assert_status 0 "apply safely removes a retired adapter"
  if [ ! -e "$adapter" ] && [ ! -L "$adapter" ] &&
    [ ! -e "$adapter_state" ]; then
    printf 'ok - retirement removes only the adapter and its ownership state\n'
  else
    printf 'not ok - retired adapter or ownership state remains\n'
    FAILURES=$((FAILURES + 1))
  fi
  if [ -f "$adapter_source/SKILL.md" ] &&
    [ -f "$HOME_TEST/.agents/skills/private/SKILL.md" ]; then
    printf 'ok - retirement preserves the KB source and unrelated skills\n'
  else
    printf 'not ok - retirement changed source or unrelated skill data\n'
    FAILURES=$((FAILURES + 1))
  fi
  printf 'present-for-decision\n' > \
    "$FIXTURE/dotfiles-knowledge-base-skill-adapter"
  run_fixture apply
  assert_status 0 "apply restores the declared adapter after retirement test"

  rm -f "$adapter" "$adapter_state"
  mkdir -p "$adapter"
  run_fixture plan
  assert_status 1 "plan rejects an unmanaged adapter directory"
  assert_contains "unmanaged target blocks knowledge-base adapter" \
    "unmanaged directory is reported without replacement"
  rm -rf "$adapter"
  printf 'unmanaged file\n' > "$adapter"
  run_fixture apply
  assert_status 1 "apply refuses an unmanaged adapter file"
  assert_contains "unmanaged target blocks knowledge-base adapter" \
    "unmanaged file is reported without replacement"
  if [ "$(< "$adapter")" = "unmanaged file" ]; then
    printf 'ok - unmanaged adapter target is preserved\n'
  else
    printf 'not ok - unmanaged adapter target was changed\n'
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$adapter"
  ln -s "$TMPDIR_TEST/unmanaged-target" "$adapter"
  run_fixture doctor
  assert_status 1 "doctor rejects an unmanaged adapter symlink"
  assert_contains "unmanaged symlink blocks knowledge-base adapter" \
    "unmanaged symlink is reported without replacement"
  rm -f "$adapter"
  run_fixture apply
  assert_status 0 "apply restores adapter after unmanaged-target tests"

  mkdir -p \
    "$FIXTURE/agents/dot-agents/skills/present-for-decision"
  printf 'copied collision\n' > \
    "$FIXTURE/agents/dot-agents/skills/present-for-decision/SKILL.md"
  run_fixture plan
  assert_status 1 "plan keeps the adapter out of the copied materializer"
  assert_contains "copied skill materializer cannot own reserved name" \
    "adapter ownership remains separate from copied skills"
  rm -rf "$FIXTURE/agents/dot-agents/skills/present-for-decision"

  printf 'managed v2\n' > \
    "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md"
  run_fixture apply
  assert_status 0 "second apply updates a state-owned materialized skill"
  if [ "$(< "$HOME_TEST/.agents/skills/managed/SKILL.md")" = \
    "managed v2" ]; then
    printf 'ok - updated skill source is materialized\n'
  else
    printf 'not ok - updated skill source was not materialized\n'
    FAILURES=$((FAILURES + 1))
  fi

  rm -f "$FIXTURE/agents/dot-agents/skills/managed/SKILL.md"
  run_fixture apply
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
  run_fixture apply
  assert_status 0 "apply rematerializes a restored managed skill"
  printf 'user modified\n' > \
    "$HOME_TEST/.agents/skills/managed/SKILL.md"
  run_fixture apply
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
  run_fixture apply
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

  if [ -n "$JQ_BIN" ]; then
    ln -s "$REPO_ROOT/tests/fake-herdr.sh" "$FIXTURE_BIN/herdr"
    ln -s "$JQ_BIN" "$FIXTURE_BIN/jq"
    rm -f "$TMPDIR_TEST/herdr-plugin-installed"
    run_command env -i HOME="$HOME_TEST" \
      PATH="$FIXTURE_BIN:/usr/bin:/bin" \
      TMPDIR="$TMPDIR_TEST" \
      TNEZDEV_KNOWLEDGE_BASE_ROOT="$KNOWLEDGE_BASE" \
      DOTFILES_TEST_HOST_MUTATION_MARKER="$HOST_MUTATION_MARKER" \
      FAKE_HERDR_PLUGIN_ENABLED=false \
      FAKE_HERDR_PLUGIN_MARKER="$TMPDIR_TEST/herdr-plugin-installed" \
      "$FIXTURE_BIN/dotfiles" apply
    assert_status 0 "apply converges a disabled pinned Herdr plugin"
    if [ -e "$TMPDIR_TEST/herdr-plugin-installed" ]; then
      printf 'ok - disabled pinned Herdr plugin is reinstalled\n'
    else
      printf 'not ok - disabled pinned Herdr plugin was accepted\n'
      FAILURES=$((FAILURES + 1))
    fi

    rm -f "$TMPDIR_TEST/herdr-plugin-installed"
    run_command env -i HOME="$HOME_TEST" \
      PATH="$FIXTURE_BIN:/usr/bin:/bin" \
      TMPDIR="$TMPDIR_TEST" \
      TNEZDEV_KNOWLEDGE_BASE_ROOT="$KNOWLEDGE_BASE" \
      DOTFILES_TEST_HOST_MUTATION_MARKER="$HOST_MUTATION_MARKER" \
      FAKE_HERDR_PLUGIN_ENABLED=true \
      FAKE_HERDR_PLUGIN_COMMIT=0000000000000000000000000000000000000000 \
      FAKE_HERDR_PLUGIN_MARKER="$TMPDIR_TEST/herdr-plugin-installed" \
      "$FIXTURE_BIN/dotfiles" apply
    assert_status 0 \
      "apply converges an enabled Herdr plugin at the wrong commit"
    if [ -e "$TMPDIR_TEST/herdr-plugin-installed" ]; then
      printf 'ok - wrong Herdr plugin commit is reinstalled\n'
    else
      printf 'not ok - wrong Herdr plugin commit was accepted\n'
      FAILURES=$((FAILURES + 1))
    fi

    rm -f "$TMPDIR_TEST/herdr-plugin-installed"
    run_command env -i HOME="$HOME_TEST" \
      PATH="$FIXTURE_BIN:/usr/bin:/bin" \
      TMPDIR="$TMPDIR_TEST" \
      TNEZDEV_KNOWLEDGE_BASE_ROOT="$KNOWLEDGE_BASE" \
      DOTFILES_TEST_HOST_MUTATION_MARKER="$HOST_MUTATION_MARKER" \
      FAKE_HERDR_PLUGIN_ENABLED=true \
      FAKE_HERDR_PLUGIN_MARKER="$TMPDIR_TEST/herdr-plugin-installed" \
      "$FIXTURE_BIN/dotfiles" apply
    assert_status 0 "apply accepts an enabled pinned Herdr plugin"
    if [ ! -e "$TMPDIR_TEST/herdr-plugin-installed" ]; then
      printf 'ok - enabled pinned Herdr plugin is left unchanged\n'
    else
      printf 'not ok - enabled pinned Herdr plugin was reinstalled\n'
      FAILURES=$((FAILURES + 1))
    fi
    rm -f "$FIXTURE_BIN/herdr" "$FIXTURE_BIN/jq"
  else
    printf 'ok - Herdr plugin condition test skipped (jq unavailable)\n'
  fi

  printf 'modem-dev/tap/hunk\n' > "$FIXTURE/dotfiles-trusted-formulae"
  run_fixture bootstrap --non-interactive --yes
  assert_status 3 "noninteractive bootstrap stops for formula trust"
  assert_contains "ACTION_REQUIRED: review formula trust" \
    "generic --yes does not grant formula trust"
  if [ ! -e "$HOST_MUTATION_MARKER" ]; then
    printf 'ok - trust policy stops before provisioning changes\n'
  else
    printf 'not ok - provisioning ran before formula trust approval\n'
    FAILURES=$((FAILURES + 1))
  fi
  printf '# no reviewed formulae in primary fixture\n' > \
    "$FIXTURE/dotfiles-trusted-formulae"
else
  printf 'ok - Stow convergence test skipped (stow unavailable)\n'
fi

rm -rf "$HOME_TEST/.local"
mkdir -p "$HOME_TEST/.local/bin"
printf 'unmanaged\n' > "$HOME_TEST/.local/bin/dotfiles"
run_fixture plan
assert_status 1 "plan fails on an unmanaged launcher"
assert_contains "CONFLICT: launcher" "plan exposes launcher conflict"
rm -rf "$HOME_TEST/.local"

for command in bootstrap apply provision upgrade; do
  case "$command" in
    bootstrap)
      run_linked bootstrap --non-interactive --yes
      ;;
    provision|upgrade)
      run_linked "$command" --non-interactive
      ;;
    *)
      run_linked "$command"
      ;;
  esac
  assert_status 3 "$command refuses a linked worktree"
  assert_contains "linked/disposable worktree" \
    "$command explains linked-worktree refusal"
done

run_fixture apply --unknown
assert_status 2 "unknown command options fail as usage errors"

run_fixture provision --non-interactive \
  --trust-formula example/tap/unreviewed
assert_status 3 "unreviewed formula trust requires action"
assert_contains "not in dotfiles-trusted-formulae" \
  "formula trust is constrained by the manifest"

run_linked_installer
assert_status 3 "installer refuses a linked checkout"

if [ -e "$HOST_MUTATION_MARKER" ]; then
  printf 'not ok - a test attempted a guarded host mutation\n'
  FAILURES=$((FAILURES + 1))
else
  printf 'ok - no test attempted a guarded host mutation\n'
fi

if [ "$FAILURES" -ne 0 ]; then
  printf '%s lifecycle test(s) failed\n' "$FAILURES" >&2
  exit 1
fi

printf 'All lifecycle tests passed.\n'
