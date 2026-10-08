#!/usr/bin/env bash
# Test only the CLI handoff: fake Pi and fake clients, no live tmux mutation.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d -t dotfiles-dev-resize.XXXXXX)
trap 'rm -rf "$TEST_ROOT"' EXIT
REPO="$TEST_ROOT/repo space"
BIN="$TEST_ROOT/bin"
HOME="$TEST_ROOT/home"
CALLS="$TEST_ROOT/pi.log"
TMUX_CALLS="$TEST_ROOT/tmux.log"
mkdir -p "$REPO/omarchy/dot-local/bin" "$REPO/lib/dotfiles" \
  "$REPO/docs/runbooks" "$REPO/.git" "$BIN" "$HOME" \
  "$TEST_ROOT/unrelated project"
cp "$ROOT/omarchy/dot-local/bin/dev" "$REPO/omarchy/dot-local/bin/dev"
cp "$ROOT/lib/dotfiles/modules.sh" "$REPO/lib/dotfiles/modules.sh"
cp "$ROOT/docs/runbooks/dev-layout.md" "$REPO/docs/runbooks/dev-layout.md"
printf '#!/bin/bash\nexit 99\n' > "$REPO/dotfiles"
chmod +x "$REPO/dotfiles"
ln -s "$REPO/omarchy/dot-local/bin/dev" "$BIN/dev"
# Minimal PATH deliberately has no nvim, Git or Stow.
for program in bash realpath dirname; do
  ln -s "$(command -v "$program")" "$BIN/$program"
done

cat > "$BIN/pi" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
{
  printf 'cwd=%s\nTMUX=%s\nTMUX_PANE=%s\n' \
    "$PWD" "${TMUX:-}" "${TMUX_PANE:-}"
  for arg in "$@"; do printf 'arg=%s\n' "$arg"; done
  if IFS= read -r input; then
    printf 'stdin=%s\n' "$input"
  else
    printf 'stdin=EOF\n'
  fi
} > "$RESIZE_TEST_CALLS"
printf 'fixture Pi result\n'
exit "${RESIZE_TEST_PI_EXIT:-0}"
EOF
cat > "$BIN/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$1" >> "$RESIZE_TEST_TMUX_CALLS"
[[ $1 == list-clients ]] || exit 99
[[ ${RESIZE_TEST_TMUX_FAIL:-0} == 0 ]] || exit 1
printf '%s\n' "${RESIZE_TEST_CLIENTS:-/dev/pts/fixture|%99}"
EOF
cat > "$BIN/uname" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${RESIZE_TEST_OS:-Linux}"
EOF
cat > "$BIN/awk" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${RESIZE_TEST_RELEASE:-omarchy}"
EOF
chmod +x "$BIN/pi" "$BIN/tmux" "$BIN/uname" "$BIN/awk"
export RESIZE_TEST_CALLS="$CALLS" RESIZE_TEST_TMUX_CALLS="$TMUX_CALLS"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
contains() { grep -Fq -- "$2" "$1" || fail "$3"; }
run() {
  (cd "$TEST_ROOT/unrelated project" &&
    env PATH="$BIN" HOME="$HOME" TMUX=/tmp/fixture,1,0 TMUX_PANE=%99 \
      "$BIN/dev" "$@")
}
refused() {
  rm -f "$CALLS"
  if run "$@" > "$TEST_ROOT/refusal.log" 2>&1; then
    fail "accepted invalid invocation: $*"
  fi
  [[ ! -e $CALLS ]] || fail 'Pi ran after a failed prerequisite'
}

run --help > "$TEST_ROOT/help.log"
contains "$TEST_ROOT/help.log" 'dev resize' 'main help lacks resize'
run resize --help > "$TEST_ROOT/help.log"
contains "$TEST_ROOT/help.log" 'Invocation approves the refit' \
  'subcommand help lacks approval policy'
[[ ! -e $CALLS && ! -e $TMUX_CALLS ]] || fail 'help invoked Pi/tmux'
printf 'ok - help is dependency-free and documents explicit resize\n'

printf 'unrelated piped input\n' | run resize > "$TEST_ROOT/result.log"
contains "$TEST_ROOT/result.log" 'fixture Pi result' 'Pi output was swallowed'
contains "$CALLS" "cwd=$REPO" 'symlink did not resolve canonical checkout'
contains "$CALLS" 'TMUX=/tmp/fixture,1,0' 'tmux environment was lost'
contains "$CALLS" 'TMUX_PANE=%99' 'invoking pane was lost'
for flag in --print --no-session --no-approve --no-mcp; do
  contains "$CALLS" "arg=$flag" "missing Pi option $flag"
done
contains "$CALLS" 'arg=read,bash' 'Pi tools are not scoped'
contains "$CALLS" "arg=$REPO/docs/runbooks/dev-layout.md" \
  'runbook is not supplied to Pi'
contains "$CALLS" 'approving preview then automatic' \
  'automatic application is not authorized'
contains "$CALLS" 'Target only verified dev-* sessions' 'scope is missing'
contains "$CALLS" 'Run doctor and plan; stop on ACTION_REQUIRED' \
  'lifecycle safety checks are missing from handoff'
contains "$CALLS" 'Do not ask for another confirmation' \
  'headless approval semantics are missing'
contains "$CALLS" 'Invoking client: /dev/pts/fixture' \
  'invoking client is not supplied'
contains "$CALLS" 'Do not confuse this headless run' \
  'temporary caller process is not distinguished from the agent role'
contains "$CALLS" 'stdin=EOF' 'unrelated stdin was consumed'
if grep -Eq '^arg=--(model|provider|approve|continue|resume)$' "$CALLS"; then
  fail 'wrapper overrides defaults/trust or resumes an unrelated session'
fi
printf 'ok - resize hands approved runbook to default headless Pi only\n'

run resize --check > "$TEST_ROOT/result.log"
contains "$CALLS" 'PREVIEW ONLY' 'check mode did not request preview'
contains "$CALLS" 'no mutations are approved' 'check mode authorizes mutation'
contains "$CALLS" 'Do not write receipts' 'check mode permits file writes'
if grep -Fq 'approving preview then automatic' "$CALLS"; then
  fail 'check mode contains application approval'
fi
printf 'ok - check mode requests read-only inspection without approval\n'

if RESIZE_TEST_PI_EXIT=17 run resize > "$TEST_ROOT/result.log" 2>&1; then
  fail 'Pi failure was hidden'
else
  status=$?
  [[ $status == 17 ]] || fail 'Pi exit status was not propagated'
fi
printf 'ok - Pi output and failure status propagate\n'

refused resize --unknown
refused resize --check extra
refused resize --help extra
refused resize other
printf 'ok - invalid arguments fail before Pi\n'

rm -f "$CALLS"
if (cd "$TEST_ROOT" && env -u TMUX -u TMUX_PANE PATH="$BIN" \
  HOME="$HOME" "$BIN/dev" resize) > "$TEST_ROOT/refusal.log" 2>&1; then
  fail 'outside-tmux resize was accepted'
fi
[[ ! -e $CALLS ]] || fail 'outside-tmux resize ran Pi'
contains "$TEST_ROOT/refusal.log" 'inside an attached tmux client' \
  'outside-tmux diagnostic is missing'
for clients in '/dev/pts/other|%1' \
  $'/dev/pts/a|%99\n/dev/pts/b|%99'; do
  RESIZE_TEST_CLIENTS=$clients refused resize
done
RESIZE_TEST_TMUX_FAIL=1 refused resize
rm -f "$CALLS"
if env -u TMUX_PANE PATH="$BIN" HOME="$HOME" TMUX=fixture \
  "$BIN/dev" resize > "$TEST_ROOT/refusal.log" 2>&1; then
  fail 'unknown invoking pane was accepted'
fi
[[ ! -e $CALLS ]] || fail 'unknown-pane resize ran Pi'
printf 'ok - absent, ambiguous and failed client inspection refuse handoff\n'

RESIZE_TEST_OS=Darwin refused resize
RESIZE_TEST_RELEASE=arch refused resize
mv "$REPO/.git" "$REPO/git-directory"
printf 'gitdir: disposable\n' > "$REPO/.git"
refused resize
contains "$TEST_ROOT/refusal.log" 'ACTION_REQUIRED' \
  'disposable-checkout refusal lacks ACTION_REQUIRED'
rm "$REPO/.git"
mv "$REPO/git-directory" "$REPO/.git"
printf 'ok - platform and primary-checkout boundaries are enforced\n'

mv "$REPO/docs/runbooks/dev-layout.md" "$TEST_ROOT/runbook"
refused resize
mv "$TEST_ROOT/runbook" "$REPO/docs/runbooks/dev-layout.md"
mv "$BIN/pi" "$TEST_ROOT/pi"
refused resize
contains "$TEST_ROOT/refusal.log" 'required program not found: pi' \
  'missing-Pi diagnostic is absent'
mv "$TEST_ROOT/pi" "$BIN/pi"
printf 'ok - missing runbook/Pi fail without mutation\n'

[[ $(sort -u "$TMUX_CALLS") == list-clients ]] || \
  fail 'wrapper issued tmux commands beyond read-only client inspection'
printf 'ok - wrapper itself performs no tmux mutation\n'
