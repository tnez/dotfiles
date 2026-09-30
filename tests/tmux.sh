#!/usr/bin/env bash
# Verify the personal tmux overlay with a disposable Omarchy-style config.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
command -v tmux >/dev/null || {
  printf 'BLOCKED: tmux is unavailable\n' >&2
  exit 2
}

TEST_ROOT=$(mktemp -d -t dotfiles-tmux.XXXXXX)
ACTIVE_HOME=
ACTIVE_SOCKET=
cleanup() {
  if [[ -n $ACTIVE_SOCKET ]]; then
    env -u TMUX HOME="$ACTIVE_HOME" \
      tmux -L "$ACTIVE_SOCKET" kill-server >/dev/null 2>&1 || true
  fi
  rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_option() {
  local actual=$1 expected=$2 name=$3
  [[ $actual == "$expected" ]] || \
    fail "$name: expected '$expected', got '$actual'"
}

assert_binding() {
  local bindings=$1 expected=$2 name=$3
  grep -Eq -- "$expected" <<<"$bindings" || \
    fail "$name binding is missing: $expected"
}

for platform in Linux Darwin; do
  ACTIVE_HOME="$TEST_ROOT/$platform"
  ACTIVE_SOCKET="dotfiles-tmux-${platform}-$$"
  bin="$ACTIVE_HOME/bin"
  mkdir -p "$bin" "$ACTIVE_HOME/.config/tmux"
  ln -s "$ROOT/tmux/dot-tmux.conf" "$ACTIVE_HOME/.tmux.conf"

  # Model Omarchy's later-loaded XDG config only on the Linux branch.
  if [[ $platform == Linux ]]; then
    cat > "$ACTIVE_HOME/.config/tmux/tmux.conf" <<'EOF'
set -g prefix C-Space
set -g prefix2 C-b
set -g default-terminal "tmux-256color"
set -g base-index 1
setw -g pane-base-index 1
set -g mouse on
set -g renumber-windows on
setw -g mode-keys vi
set -g extended-keys on
set -g extended-keys-format csi-u
set -g escape-time 0
set -g detach-on-destroy off
set -sg escape-time 10
set -ag terminal-overrides ",*:RGB"
bind h split-window -v -c "#{pane_current_path}"
bind v split-window -h -c "#{pane_current_path}"
bind r command-prompt -I "#W" "rename-window -- '%%'"
bind R command-prompt -I "#S" "rename-session -- '%%'"
bind x kill-pane
bind ? display-message "Omarchy help"
EOF
  fi
  cat > "$bin/uname" <<'EOF'
#!/bin/sh
printf '%s\n' "$TMUX_TEST_UNAME"
EOF
  chmod +x "$bin/uname"

  tmux_cmd() {
    env -u TMUX HOME="$ACTIVE_HOME" \
      XDG_CONFIG_HOME="$ACTIVE_HOME/.config" \
      PATH="$bin:$PATH" TMUX_TEST_UNAME="$platform" \
      tmux -L "$ACTIVE_SOCKET" "$@"
  }

  tmux_cmd -f /dev/null new-session -d -s test -c "$ACTIVE_HOME"
  tmux_cmd set-environment -g PATH "$bin:$PATH"
  tmux_cmd set-environment -g TMUX_TEST_UNAME "$platform"
  default_terminal=$(tmux_cmd show-options -gqv default-terminal)
  # tmux loads ~/.tmux.conf before its XDG user config.
  tmux_cmd source-file "$ACTIVE_HOME/.tmux.conf"
  if [[ $platform == Linux ]]; then
    tmux_cmd source-file "$ACTIVE_HOME/.config/tmux/tmux.conf"
  fi

  assert_option "$(tmux_cmd show-options -gqv prefix)" C-Space prefix
  if [[ $platform == Linux ]]; then
    assert_option "$(tmux_cmd show-options -gqv prefix2)" C-b prefix2
    assert_option \
      "$(tmux_cmd show-options -gqv default-terminal)" \
      tmux-256color default-terminal
    assert_option "$(tmux_cmd show-options -sqv escape-time)" 10 escape-time
    assert_option \
      "$(tmux_cmd show-options -gqv detach-on-destroy)" off \
      detach-on-destroy
    omarchy_overrides=$(tmux_cmd show-options -sqv terminal-overrides)
    if ! grep -Fq '*:RGB' <<<"$omarchy_overrides"; then
      fail 'Omarchy RGB terminal feature was lost'
    fi
    if grep -Fq 'xterm*:Tc' <<<"$omarchy_overrides"; then
      fail 'macOS terminal override leaked into Omarchy'
    fi
  else
    assert_option "$(tmux_cmd show-options -gqv prefix2)" None prefix2
    assert_option \
      "$(tmux_cmd show-options -gqv default-terminal)" \
      "$default_terminal" default-terminal
    assert_option "$(tmux_cmd show-options -sqv escape-time)" 0 escape-time
    assert_option \
      "$(tmux_cmd show-options -gqv detach-on-destroy)" off \
      detach-on-destroy
    mac_overrides=$(tmux_cmd show-options -sqv terminal-overrides)
    if ! grep -Fq 'xterm*:Tc' <<<"$mac_overrides"; then
      fail 'macOS RGB terminal override is missing'
    fi
  fi

  prefix_bindings=$(tmux_cmd list-keys -T prefix)
  assert_binding "$prefix_bindings" \
    ' -[[:space:]]+split-window -v -c "#\{pane_current_path\}"' 'prefix -'
  assert_binding "$prefix_bindings" \
    ' /[[:space:]]+split-window -h -c "#\{pane_current_path\}"' 'prefix /'
  assert_binding "$prefix_bindings" \
    'C-Space[[:space:]]+send-prefix' 'shared prefix'
  assert_binding "$prefix_bindings" \
    ' r[[:space:]]+command-prompt -I "#W"' 'prefix r'
  assert_binding "$prefix_bindings" \
    ' x[[:space:]]+kill-pane' 'prefix x'
  if [[ $platform == Linux ]]; then
    assert_binding "$prefix_bindings" \
      ' h[[:space:]]+split-window -v -c "#\{pane_current_path\}"' \
      'Omarchy prefix h'
    assert_binding "$prefix_bindings" \
      ' v[[:space:]]+split-window -h -c "#\{pane_current_path\}"' \
      'Omarchy prefix v'
    assert_binding "$prefix_bindings" \
      ' R[[:space:]]+command-prompt -I "#S"' 'Omarchy prefix R'
    assert_binding "$prefix_bindings" \
      ' \?[[:space:]]+display-message "Omarchy help"' 'Omarchy help'
  else
    assert_binding "$prefix_bindings" \
      ' h[[:space:]]+previous-window' 'macOS previous window'
    assert_binding "$prefix_bindings" \
      ' v[[:space:]]+copy-mode' 'macOS copy mode'
    assert_binding "$prefix_bindings" \
      ' l[[:space:]]+next-window' 'macOS next window'
    assert_binding "$prefix_bindings" \
      ' R[[:space:]]+source-file' 'macOS reload'
  fi

  root_bindings=$(tmux_cmd list-keys -T root)
  for key in C-h C-j C-k C-l M-h M-j M-k M-l; do
    binding_pattern="$key[[:space:]]+if-shell -F \"#{@pane-is-vim}\""
    if [[ $platform == Darwin || $key == C-* ]]; then
      assert_binding "$root_bindings" "$binding_pattern" \
        "$platform smart-splits $key"
    elif grep -Eq "$binding_pattern" <<<"$root_bindings"; then
      fail "Omarchy must not capture resize key $key"
    fi
  done

  tmux_cmd kill-server
  ACTIVE_SOCKET=
  printf 'ok - %s overlay preserves host bindings and adds split keys\n' \
    "$platform"
done

if grep -Eq 'display-popup|run-shell|scripts/|herdr|sesh|television' \
  "$ROOT/tmux/dot-tmux.conf"; then
  fail 'tmux overlay contains a retired workflow or popup'
fi
printf 'ok - overlay has no retired helper or popup dependencies\n'
