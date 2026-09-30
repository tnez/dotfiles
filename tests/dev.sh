#!/usr/bin/env bash
# Exercise the Omarchy project launcher against an isolated tmux server.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEV="$ROOT/omarchy/dot-local/bin/dev"
REAL_TMUX=$(command -v tmux) || {
  printf 'BLOCKED: tmux is unavailable\n' >&2
  exit 2
}
TEST_ROOT=$(mktemp -d -t dotfiles-dev.XXXXXX)
SOCKET="dotfiles-dev-$$"
BIN="$TEST_ROOT/bin"
HOME="$TEST_ROOT/home"
CALLS="$TEST_ROOT/calls.log"
mkdir -p "$BIN" "$HOME"
export HOME PATH="$BIN:/usr/bin:/bin" SHELL=/bin/bash
export DEV_TEST_REAL_TMUX="$REAL_TMUX" DEV_TEST_SOCKET="$SOCKET"
export DEV_TEST_CALLS="$CALLS"
: > "$CALLS"

cleanup() {
  env -u TMUX "$REAL_TMUX" -L "$SOCKET" kill-server \
    >/dev/null 2>&1 || true
  rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local file=$1 text=$2 description=$3
  grep -Fq -- "$text" "$file" || fail "$description"
}

cat > "$BIN/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case ${1-} in
  attach-session)
    printf 'attach' >> "$DEV_TEST_CALLS"
    printf ' <%s>' "${@:2}" >> "$DEV_TEST_CALLS"
    printf '\n' >> "$DEV_TEST_CALLS"
    exit 0
    ;;
  list-clients)
    if [[ ${DEV_TEST_INSIDE:-0} == 1 ]]; then
      printf '%s\n' \
        "${DEV_TEST_CLIENTS:-$DEV_TEST_CLIENT|$DEV_TEST_PANE}"
      exit 0
    fi
    ;;
  switch-client)
    printf 'switch' >> "$DEV_TEST_CALLS"
    printf ' <%s>' "${@:2}" >> "$DEV_TEST_CALLS"
    printf '\n' >> "$DEV_TEST_CALLS"
    exit 0
    ;;
esac
exec "$DEV_TEST_REAL_TMUX" -L "$DEV_TEST_SOCKET" -f /dev/null "$@"
EOF
cat > "$BIN/nvim" <<'EOF'
#!/usr/bin/env bash
printf 'nvim|cwd=%s' "$PWD" >> "$DEV_TEST_CALLS"
for arg in "$@"; do printf '|%s' "$arg" >> "$DEV_TEST_CALLS"; done
printf '\n' >> "$DEV_TEST_CALLS"
exec sleep 300
EOF
cat > "$BIN/pi" <<'EOF'
#!/usr/bin/env bash
printf 'pi|cwd=%s' "$PWD" >> "$DEV_TEST_CALLS"
for arg in "$@"; do printf '|%s' "$arg" >> "$DEV_TEST_CALLS"; done
printf '\n' >> "$DEV_TEST_CALLS"
exec sleep 300
EOF
cat > "$BIN/git" <<'EOF'
#!/usr/bin/env bash
printf 'git called\n' >> "$DEV_TEST_CALLS"
exit 99
EOF
chmod +x "$BIN/tmux" "$BIN/nvim" "$BIN/pi" "$BIN/git"

wait_for_log() {
  local text=$1 attempt
  for ((attempt = 0; attempt < 50; attempt++)); do
    grep -Fq -- "$text" "$CALLS" && return 0
    sleep 0.1
  done
  fail "timed out waiting for '$text'"
}

run_dev() {
  local directory=$1
  (cd "$directory" && env -u TMUX -u TMUX_PANE "$DEV")
}

project="$TEST_ROOT/work space/project"
mkdir -p "$project"
run_dev "$project" > "$TEST_ROOT/first.log"
session=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-sessions -F '#{session_name}')
[[ -n $session ]] || fail 'new project session was not created'
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  show-option -qv -t "$session" @dev_workflow_root) == "$project" ]] || \
  fail 'session ownership path was not recorded'
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  show-option -qv -t "$session" @dev_workflow_ready) == 1 ]] || \
  fail 'new session was not marked ready'
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-windows -t "$session" -F '#{window_name}') == dev ]] || \
  fail 'new window was not named dev'
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  show-window-options -v -t "$session:dev" automatic-rename) == off ]] || \
  fail 'window automatic rename was not disabled locally'
panes=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$session:dev" -F '#{pane_current_path}')
[[ $(grep -c . <<<"$panes") == 3 ]] ||
  fail 'new layout does not have three panes'
while IFS= read -r pane_path; do
  [[ $pane_path == "$project" ]] || fail "wrong pane directory: $pane_path"
done <<<"$panes"
positions=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$session:dev" -F '#{pane_top},#{pane_left}')
grep -Eq '^0,0$' <<<"$positions" || fail 'editor is not upper-left'
grep -Eq '^0,[1-9][0-9]*$' <<<"$positions" || fail 'agent is not upper-right'
grep -Eq '^[1-9][0-9]*,0$' <<<"$positions" ||
  fail 'shell is not across the bottom'
editor_pane=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$session:dev" -F '#{pane_id}' | head -n1)
active_pane=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  display-message -p -t "$session:dev" '#{pane_id}')
[[ $active_pane == "$editor_pane" ]] || fail 'editor is not initially focused'
read -r window_height window_width < <(
  "$REAL_TMUX" -L "$SOCKET" -f /dev/null \
    display-message -p -t "$session:dev" '#{window_height} #{window_width}'
)
pane_sizes=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$session:dev" -F '#{pane_height},#{pane_width}')
expected_shell_height=$((window_height * 15 / 100))
expected_agent_width=$((window_width * 30 / 100))
agent_width=$(tail -n +2 <<<"$pane_sizes" | head -n1 | cut -d, -f2)
[[ $agent_width == "$expected_agent_width" ]] || \
  fail 'agent pane does not use 30% of the upper width'
shell_height=$(tail -n1 <<<"$pane_sizes" | cut -d, -f1)
[[ $shell_height == "$expected_shell_height" ]] || \
  fail 'shell pane does not use 15% of the window height'
wait_for_log "nvim|cwd=$project|."
assert_contains "$CALLS" "pi|cwd=$project|--append-system-prompt|" \
  'Pi did not receive startup context'
assert_contains "$CALLS" 'do not assume or impose them' \
  'startup context does not describe conditional VCS preferences'
assert_contains "$CALLS" 'attach' 'outside-tmux invocation did not attach'
! grep -Fq 'git called' "$CALLS" || fail 'launcher invoked git'
printf 'ok - new path starts editor/agent/shell layout and passes context\n'

pane_ids_before=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$session:dev" -F '#{pane_id}')
"$REAL_TMUX" -L "$SOCKET" -f /dev/null new-window \
  -t "$session" -n extra -c "$project" >/dev/null
renamed_session="${session}-renamed"
"$REAL_TMUX" -L "$SOCKET" -f /dev/null rename-session \
  -t "$session" "$renamed_session"
session=$renamed_session
run_dev "$project" > "$TEST_ROOT/repeat.log"
pane_ids_after=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$session:dev" -F '#{pane_id}')
[[ $pane_ids_after == "$pane_ids_before" ]] || \
  fail 're-entry rebuilt or replaced existing panes'
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-windows -t "$session" -F '#{window_id}' | grep -c .) == 2 ]] || \
  fail 're-entry removed or duplicated a window'
ln -s "$project" "$TEST_ROOT/project-alias"
run_dev "$TEST_ROOT/project-alias" > "$TEST_ROOT/alias.log"
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-sessions -F '#{session_name}' | grep -c .) == 1 ]] || \
  fail 'canonical symlink alias created a duplicate session'
printf 'ok - re-entry and canonical symlink preserve the existing session\n'

second_project="$TEST_ROOT/other/project"
mkdir -p "$second_project"
run_dev "$second_project" > "$TEST_ROOT/second-project.log"
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-sessions -F '#{session_name}' | grep -c .) == 2 ]] || \
  fail 'different paths with the same basename shared a session'
printf 'ok - different project paths get distinct sessions\n'

race_project="$TEST_ROOT/concurrent"
mkdir -p "$race_project"
run_dev "$race_project" > "$TEST_ROOT/race-one.log" 2>&1 &
race_one=$!
run_dev "$race_project" > "$TEST_ROOT/race-two.log" 2>&1 &
race_two=$!
wait "$race_one" || true
wait "$race_two" || true
owned_sessions=0
while IFS= read -r candidate; do
  owner=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
    show-option -qv -t "$candidate" @dev_workflow_root)
  if [[ $owner == "$race_project" ]]; then
    owned_sessions=$((owned_sessions + 1))
    race_session=$candidate
  fi
done < <("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-sessions -F '#{session_name}')
[[ $owned_sessions == 1 ]] || \
  fail 'concurrent entry created duplicate project sessions'
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$race_session:dev" -F '#{pane_id}' | grep -c .) == 3 ]] || \
  fail 'concurrent entry produced an incomplete layout'
dev_windows=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-windows -t "$race_session" -F '#{window_name}' | grep -xc dev)
[[ $dev_windows == 1 ]] || fail 'concurrent entry duplicated the dev window'
printf 'ok - concurrent entry creates at most one project layout\n'

: > "$CALLS"
env TMUX=fake-socket,1,0 TMUX_PANE=%99 \
  DEV_TEST_INSIDE=1 DEV_TEST_CLIENT=/dev/pts/test-client \
  DEV_TEST_PANE=%99 bash -c 'cd "$1" && "$2"' _ "$project" "$DEV" \
  > "$TEST_ROOT/inside.log" || fail 'inside-tmux invocation failed'
assert_contains "$CALLS" 'switch <-c> </dev/pts/test-client>' \
  'inside-tmux invocation did not select the invoking client'
! grep -Fq 'attach' "$CALLS" || fail 'inside-tmux invocation nested attach'
printf 'ok - inside-tmux invocation switches the invoking client\n'

: > "$CALLS"
ambiguous_project="$TEST_ROOT/ambiguous"
mkdir -p "$ambiguous_project"
sessions_before=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-sessions -F '#{session_name}' | grep -c .)
if env TMUX=fake-socket,1,0 TMUX_PANE=%99 DEV_TEST_INSIDE=1 \
  DEV_TEST_CLIENTS=$'/dev/pts/a|%99\n/dev/pts/b|%99' \
  bash -c 'cd "$1" && "$2"' _ "$ambiguous_project" "$DEV" \
  > "$TEST_ROOT/ambiguous.log" 2>&1; then
  fail 'ambiguous tmux client selection was accepted'
fi
! grep -Fq 'switch' "$CALLS" || \
  fail 'ambiguous client selection switched a client'
sessions_after=$("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-sessions -F '#{session_name}' | grep -c .)
[[ $sessions_after == "$sessions_before" ]] || \
  fail 'ambiguous selection created a project session'
printf 'ok - ambiguous client selection is rejected without creating state\n'

collision="$TEST_ROOT/collision"
mkdir -p "$collision"
hash=$(printf '%s' "$collision" | sha256sum)
hash=${hash%% *}
collision_session="dev-collision-${hash:0:12}"
"$REAL_TMUX" -L "$SOCKET" -f /dev/null new-session -d \
  -s "$collision_session" -c "$collision"
if run_dev "$collision" > "$TEST_ROOT/collision.log" 2>&1; then
  fail 'unowned session-name collision was accepted'
fi
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$collision_session" -F '#{pane_id}' | grep -c .) == 1 ]] || \
  fail 'collision handling modified the unowned session'
printf 'ok - unowned session collision is reported without takeover\n'

incomplete="$TEST_ROOT/incomplete"
mkdir -p "$incomplete"
hash=$(printf '%s' "$incomplete" | sha256sum)
hash=${hash%% *}
incomplete_session="dev-incomplete-${hash:0:12}"
"$REAL_TMUX" -L "$SOCKET" -f /dev/null new-session -d \
  -s "$incomplete_session" -c "$incomplete"
"$REAL_TMUX" -L "$SOCKET" -f /dev/null set-option \
  -t "$incomplete_session" @dev_workflow_root "$incomplete"
if run_dev "$incomplete" > "$TEST_ROOT/incomplete.log" 2>&1; then
  fail 'incomplete owned session was silently resumed'
fi
[[ $("$REAL_TMUX" -L "$SOCKET" -f /dev/null \
  list-panes -t "$incomplete_session" -F '#{pane_id}' | grep -c .) == 1 ]] || \
  fail 'incomplete-session handling modified existing state'
printf 'ok - incomplete session is reported without repair\n'

no_pi="$TEST_ROOT/no-pi"
mkdir -p "$no_pi" "$TEST_ROOT/missing"
ln -s "$BIN/tmux" "$no_pi/tmux"
ln -s "$BIN/nvim" "$no_pi/nvim"
if (cd "$TEST_ROOT/missing" && env -u TMUX -u TMUX_PANE \
  PATH="$no_pi:/usr/bin:/bin" "$DEV") >/dev/null 2>&1; then
  fail 'missing Pi executable was accepted'
fi
printf 'ok - missing required program fails before activation\n'
