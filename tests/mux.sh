#!/usr/bin/env bash
# Only fake players, a disposable home, and a private tmux socket are used.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
REAL_TMUX=$(command -v tmux) || { echo 'BLOCKED: tmux missing'; exit 2; }
TEST_ROOT=$(mktemp -d -t dotfiles-mux.XXXXXX)
SOCKET="$TEST_ROOT/server"
BIN="$TEST_ROOT/bin"
REPO="$TEST_ROOT/repo"
export HOME="$TEST_ROOT/home"
export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
export XDG_RUNTIME_DIR="$TEST_ROOT/runtime" SHELL=/bin/bash
export PATH="$BIN:/usr/bin:/bin"
unset TMUX TMUX_PANE TMUX_TMPDIR CLIAMP_CONFIG_DIR
mkdir -p "$BIN" "$HOME" "$XDG_RUNTIME_DIR" "$REPO/.git"
cp -R "$ROOT/omarchy" "$ROOT/cliamp" "$REPO/"
MUX="$REPO/omarchy/dot-local/bin/mux"
CALLS="$TEST_ROOT/calls"
RANKS="$TEST_ROOT/ranks"
FAIL_FILE="$TEST_ROOT/fail-player"
export MUX_TEST_REAL_TMUX="$REAL_TMUX" MUX_TEST_SOCKET="$SOCKET"
export MUX_TEST_CALLS="$CALLS" MUX_TEST_RANKS="$RANKS"
export MUX_TEST_FAIL_FILE="$FAIL_FILE" MUX_TEST_ROOT="$TEST_ROOT"
printf '#|0\n' > "$RANKS"
: > "$CALLS"
cleanup() {
  env -u TMUX "$REAL_TMUX" -S "$SOCKET" kill-server 2>/dev/null || true
  rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT
fail() {
  printf 'FAIL: %s\n' "$*" >&2
  [[ ! -f $CALLS ]] || tail -n 20 "$CALLS" >&2
  [[ ! -f $TEST_ROOT/first ]] || tail -n 10 "$TEST_ROOT/first" >&2
  exit 1
}
mt() { "$REAL_TMUX" -S "$SOCKET" -f "$TEST_ROOT/tmux.conf" "$@"; }
contains() { grep -Fq -- "$2" "$1" || fail "$3"; }
expect_failure() {
  if "$@" > "$TEST_ROOT/error" 2>&1; then
    fail "unexpected success: $*"
  fi
}
wait_log() {
  local text=$1 i
  for ((i=0; i<100; i++)); do
    grep -Fq -- "$text" "$CALLS" && return 0
    sleep 0.05
  done
  fail "timed out: $text"
}

# Do not run real lifecycle commands even in the fixture home.
printf '#!/bin/sh\nexit 0\n' > "$REPO/dotfiles"
chmod +x "$REPO/dotfiles"
python3 "$REPO/cliamp/mux-profile" apply --yes > "$TEST_ROOT/setup"
mkdir -p "$XDG_CONFIG_HOME/mux"
cp "$REPO"/omarchy/dot-config/mux/* "$XDG_CONFIG_HOME/mux/"
revision=$(<"$XDG_CONFIG_HOME/mux/hud-revision")
hud_dir="$XDG_DATA_HOME/dotfiles/hud/$revision"
mkdir -p "$hud_dir"
cat > "$TEST_ROOT/tmux.conf" <<'EOF'
set -g default-shell /bin/bash
set -g default-command 'exec /usr/bin/sleep 300'
EOF
cat > "$BIN/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ $1 == -S && $2 == /tmp/tmux-$UID/default ]] || exit 90
shift 2
[[ ${1:-} != -N ]] || shift
case ${1:-} in
  attach-session|switch-client)
    printf '%s' "$1" >> "$MUX_TEST_CALLS"
    printf ' <%s>' "${@:2}" >> "$MUX_TEST_CALLS"
    printf '\n' >> "$MUX_TEST_CALLS"
    exit 0
    ;;
  list-clients)
    if [[ -n ${MUX_TEST_CLIENTS:-} ]]; then
      printf '%s\n' "$MUX_TEST_CLIENTS"
      exit 0
    fi
    ;;
  list-sessions)
    if [[ ${MUX_TEST_INSPECT_FAIL:-0} == 1 ]]; then
      printf 'simulated permission error\n' >&2
      exit 70
    fi
    # Test the ordering algorithm deterministically; all identity/ownership
    # fields come from real tmux. Native attachment timestamps are smoke scope.
    "$MUX_TEST_REAL_TMUX" -S "$MUX_TEST_SOCKET" \
      -f "$MUX_TEST_ROOT/tmux.conf" "$@" |
      awk -F'|' 'NR==FNR {rank[$1]=$2; next}
        {$4=($1 in rank ? rank[$1] : $4); print}' OFS='|' \
        "$MUX_TEST_RANKS" -
    exit "${PIPESTATUS[0]}"
    ;;
esac
exec "$MUX_TEST_REAL_TMUX" -S "$MUX_TEST_SOCKET" \
  -f "$MUX_TEST_ROOT/tmux.conf" "$@"
EOF
cat > "$hud_dir/hud" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${3:-} == --check-config ]]; then
  [[ ! -e $MUX_TEST_ROOT/invalid-hud ]]
  exit
fi
printf 'hud|cwd=%s|%s|%s\n' "$PWD" "$1" "$2" >> "$MUX_TEST_CALLS"
[[ ! -e $MUX_TEST_FAIL_FILE ]] || exit 7
exec /usr/bin/sleep 300
EOF
cat > "$BIN/cliamp" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'cliamp|cwd=%s|profile=%s' "$PWD" "$CLIAMP_CONFIG_DIR" \
  >> "$MUX_TEST_CALLS"
printf '|%s' "$@" >> "$MUX_TEST_CALLS"
printf '|navidrome=%s|lyrion=%s\n' "${NAVIDROME_URL:-}" "${LYRION_URL:-}" \
  >> "$MUX_TEST_CALLS"
[[ ! -e $MUX_TEST_FAIL_FILE ]] || exit 7
exec /usr/bin/sleep 300
EOF
chmod +x "$BIN/tmux" "$BIN/cliamp" "$hud_dir/hud" "$MUX"
[[ $(command -v cliamp) == "$BIN/cliamp" ]] || fail 'fixture player isolation'

# Missing prerequisites and custom sockets must not create even a server.
expect_failure env TMUX=/tmp/isolated-test,1,0 "$MUX"
contains "$TEST_ROOT/error" 'custom tmux socket' 'custom server not refused'
expect_failure env TMUX_TMPDIR="$TEST_ROOT" "$MUX"
[[ ! -S $SOCKET ]] || fail 'rejected invocation started a server'
expect_failure "$MUX" --check
[[ ! -e $XDG_RUNTIME_DIR/dotfiles-mux-$UID ]] || fail 'check created a lock'
expect_failure env MUX_TEST_INSPECT_FAIL=1 "$MUX"
contains "$TEST_ROOT/error" 'cannot inspect tmux server' \
  'inspection error was mistaken for an empty server'
printf 'preserve lock contents\n' > \
  "$XDG_RUNTIME_DIR/dotfiles-mux-$UID/entry.lock"
mv "$hud_dir/hud" "$hud_dir/hud.saved"
expect_failure "$MUX"
contains "$TEST_ROOT/error" 'pinned HUD build missing' \
  'missing HUD not explained'
mv "$hud_dir/hud.saved" "$hud_dir/hud"
touch "$TEST_ROOT/invalid-hud"
expect_failure "$MUX"
rm "$TEST_ROOT/invalid-hud"
[[ ! -S $SOCKET ]] || fail 'bad inputs started a server'
printf 'ok - custom sockets and bad inputs fail before tmux mutation\n'

# Raw server creation and reload are entirely vanilla.
mt new-session -d -s ordinary
mt source-file "$TEST_ROOT/tmux.conf"
[[ ! -s $CALLS ]] || fail 'vanilla tmux or reload started utilities'
mt kill-session -t ordinary
printf 'ok - raw tmux creation and reload have no utility hooks\n'

project="$TEST_ROOT/chosen directory"
mkdir -p "$project"
(cd "$project" && NAVIDROME_URL=forbidden LYRION_URL=forbidden "$MUX") \
  > "$TEST_ROOT/first"
wait_log 'hud|'
wait_log 'cliamp|'
[[ $(mt list-sessions -F '#{session_id}' | wc -l) == 3 ]] || \
  fail 'expected exactly two utilities and one shell'
hud=$(mt display-message -p -t '=mux-hud:' '#{session_id}')
music=$(mt display-message -p -t '=mux-cliamp:' '#{session_id}')
work=$(mt display-message -p -t '=Work:' '#{session_id}')
contains "$CALLS" "hud|cwd=$HOME|--config|$XDG_CONFIG_HOME/mux/hud.toml" \
  'wrong HUD startup'
contains "$CALLS" \
  "cliamp|cwd=$HOME|profile=$XDG_CONFIG_HOME/cliamp/profiles/mux" \
  'wrong cliamp profile or cwd'
contains "$CALLS" \
  '|--no-auto-play|--no-shuffle|--repeat|off|--provider|radio|--playlist|work' \
  'silent named-playlist arguments missing'
contains "$CALLS" '|navidrome=|lyrion=' 'provider environment leaked'
contains "$CALLS" "attach-session <-t> <$work>" 'landed in a utility'
[[ $(mt display-message -p -t "$work" '#{pane_current_path}') == "$project" ]] \
  || fail 'new shell lost invoking cwd'
"$MUX" --check > "$TEST_ROOT/check"
contains "$XDG_RUNTIME_DIR/dotfiles-mux-$UID/entry.lock" \
  'preserve lock contents' 'entry truncated an existing lock file'
printf 'ok - first entry creates independent utilities and a normal shell\n'

# Renames, additional panes/windows and arbitrary running processes survive.
mt rename-session -t "$hud" dashboard
mt rename-session -t "$music" listening
mt new-window -d -t "$music" -n extra
before=$(mt list-panes -a -F '#{pane_id}|#{pane_pid}|#{pane_start_command}')
"$MUX" > "$TEST_ROOT/repeat"
after=$(mt list-panes -a -F '#{pane_id}|#{pane_pid}|#{pane_start_command}')
[[ $after == "$before" ]] || fail 'repeat entry changed panes or processes'
[[ $(grep -c '^hud|' "$CALLS") == 1 ]] || fail 'HUD relaunched'
[[ $(grep -c '^cliamp|' "$CALLS") == 1 ]] || fail 'cliamp relaunched'
printf 'ok - renamed utilities and modified sessions are preserved\n'

second=$(mt new-session -d -P -F '#{session_id}' -s second)
printf '#|0\n%s|100\n%s|200\n%s|999\n%s|999\n' \
  "$work" "$second" "$hud" "$music" > "$RANKS"
"$MUX" > "$TEST_ROOT/ranked"
contains "$TEST_ROOT/ranked" "opening $second" 'did not choose last attachment'
printf '#|0\n%s|200\n%s|200\n' "$work" "$second" > "$RANKS"
"$MUX" > "$TEST_ROOT/tie"
contains "$TEST_ROOT/tie" "opening $work" 'timestamp tie is not deterministic'
# Background output does not contribute to the rank at all.
mt display-message -p -t "$second" '#{session_activity}' >/dev/null
printf 'ok - last attachment selects a non-utility with stable ties\n'

: > "$CALLS"
env TMUX="/tmp/tmux-$UID/default,1,0" TMUX_PANE=%99 \
  MUX_TEST_CLIENTS=$'/dev/pts/a|%99\n/dev/pts/b|%98' "$MUX" \
  > "$TEST_ROOT/inside"
contains "$CALLS" 'switch-client <-c> </dev/pts/a>' 'wrong client switched'
before=$(mt list-panes -a -F '#{pane_id}|#{pane_pid}')
expect_failure env TMUX="/tmp/tmux-$UID/default,1,0" TMUX_PANE=%99 \
  MUX_TEST_CLIENTS=$'/dev/pts/a|%99\n/dev/pts/b|%99' "$MUX"
expect_failure env TMUX="/tmp/tmux-$UID/default,1,0" TMUX_PANE=%99 \
  MUX_TEST_CLIENTS='/dev/pts/b|%98' "$MUX"
[[ $(mt list-panes -a -F '#{pane_id}|#{pane_pid}') == "$before" ]] || \
  fail 'ambiguous/missing client changed sessions'
printf 'ok - only the unique invoking client can be switched\n'

# Disappearance is repaired on entry, not asynchronously.
mt set-window-option -g remain-on-exit on
mt send-keys -t "$hud:" C-c
for ((i=0; i<100; i++)); do
  mt has-session -t "$hud" 2>/dev/null || break
  sleep 0.05
done
[[ $(mt list-sessions -F '#{@mux_role}' | grep -c '^hud$' || true) == 0 ]] || \
  fail 'HUD was unexpectedly respawned'
"$MUX" > "$TEST_ROOT/race-a" 2>&1 & a=$!
"$MUX" > "$TEST_ROOT/race-b" 2>&1 & b=$!
wait "$a" || fail 'first concurrent entry failed'
wait "$b" || fail 'second concurrent entry failed'
[[ $(mt list-sessions -F '#{@mux_role}' | grep -c '^hud$') == 1 ]] || \
  fail 'concurrent entry duplicated HUD'
[[ $(mt list-sessions -F '#{@mux_role}' | grep -c '^cliamp$') == 1 ]] || \
  fail 'concurrent entry duplicated cliamp'
printf 'ok - concurrent re-entry restores only missing utilities\n'

hud=$(mt display-message -p -t '=mux-hud:' '#{session_id}')
mt set-option -t "$hud" @mux_ready 0
expect_failure "$MUX"
contains "$TEST_ROOT/error" 'incomplete hud' 'incomplete session accepted'
mt set-option -t "$hud" @mux_ready 1
mt kill-session -t "$hud"
mt new-session -d -s mux-hud
before=$(mt list-panes -a -F '#{pane_id}|#{pane_pid}')
expect_failure "$MUX"
contains "$TEST_ROOT/error" 'unowned name collision' 'unowned session adopted'
[[ $(mt list-panes -a -F '#{pane_id}|#{pane_pid}') == "$before" ]] || \
  fail 'collision changed existing sessions'
printf 'ok - incomplete and unowned sessions are not repaired or adopted\n'

mt kill-session -t '=mux-hud'
"$MUX" > "$TEST_ROOT/restore"
# Only-utilities case: preserve both, create a shell, never attach to either.
mt kill-session -t "$work"
mt kill-session -t "$second"
"$MUX" > "$TEST_ROOT/only-utilities"
[[ $(mt list-sessions -F '#{session_id}' | wc -l) == 3 ]] || \
  fail 'only-utilities entry did not create exactly one shell'
work=$(mt display-message -p -t '=Work:' '#{session_id}')
contains "$TEST_ROOT/only-utilities" "opening $work" 'utility stole focus'
printf 'ok - utility-only server gets a normal shell destination\n'

# Duplicate ownership and dead panes need inspection, never implicit repair.
duplicate=$(mt new-session -d -P -F '#{session_id}' -s duplicate)
mt set-option -t "$duplicate" @mux_role cliamp
mt set-option -t "$duplicate" @mux_ready 1
expect_failure "$MUX"
contains "$TEST_ROOT/error" 'multiple sessions claim cliamp' \
  'duplicate ownership not rejected'
mt kill-session -t "$duplicate"
hud=$(mt display-message -p -t '=mux-hud:' '#{session_id}')
mt set-window-option -t "$hud:" remain-on-exit on
mt send-keys -t "$hud:" C-c
for ((i=0; i<100; i++)); do
  [[ $(mt list-panes -t "$hud:" -F '#{pane_dead}') == 1 ]] && break
  sleep 0.05
done
expect_failure "$MUX"
contains "$TEST_ROOT/error" 'dead pane' 'dead pane silently repaired'
mt kill-session -t "$hud"
printf 'ok - duplicate claims and dead panes need explicit inspection\n'

# Missing profile or executable must not start HUD as a partial success.
profile="$XDG_CONFIG_HOME/cliamp/profiles/mux"
mt kill-session -t "$music"
mv "$profile" "$profile.saved"
expect_failure "$MUX"
[[ $(mt list-sessions -F '#{session_id}' | wc -l) == 1 ]] || \
  fail 'missing profile partially started utilities'
mv "$profile.saved" "$profile"
restricted="$TEST_ROOT/restricted-bin"
mkdir "$restricted"
for program in bash python3 realpath flock mkdir awk; do
  ln -s "$(command -v "$program")" "$restricted/$program"
done
ln -s "$BIN/tmux" "$restricted/tmux"
expect_failure env PATH="$restricted" "$MUX"
contains "$TEST_ROOT/error" 'required program missing: cliamp' \
  'missing player not reported'
[[ $(mt list-sessions -F '#{session_id}' | wc -l) == 1 ]] || \
  fail 'missing player partially started utilities'
printf 'ok - missing player/profile prevents partial utility startup\n'

# Immediate app exit is a failure, not an empty success or a restart loop.
before=$(mt list-panes -t "$work:" \
  -F '#{pane_id}|#{pane_pid}|#{pane_start_command}')
touch "$FAIL_FILE"
expect_failure "$MUX"
rm "$FAIL_FILE"
[[ $(mt list-panes -t "$work:" \
  -F '#{pane_id}|#{pane_pid}|#{pane_start_command}') == "$before" ]] || \
  fail 'launch failure disturbed shell'
printf 'ok - launch failure is visible and preserves unrelated work\n'
