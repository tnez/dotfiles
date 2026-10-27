#!/usr/bin/env bash
# Verify the XDG entrypoint with disposable Omarchy defaults and servers.
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

prefix_binding() {
  tmux_cmd list-keys -T prefix -F '#{key_string}|#{key_command}' | \
    awk -F '|' -v key="$1" '$1 == key'
}

assert_reload_binding() {
  local expected=$1 actual
  actual=$(prefix_binding q)
  grep -Fq -- "source-file $expected" <<<"$actual" || \
    fail "prefix q must reload $expected; got: $actual"
}

assert_shared_workflow_bindings() {
  assert_option "$(prefix_binding l)" 'l|last-window' 'last-used window'
  assert_option "$(prefix_binding n)" 'n|next-window' 'next window'
  assert_option "$(prefix_binding c)" \
    'c|new-window -c "#{pane_current_path}"' 'new window directory'
  local agent_binding
  agent_binding=$(prefix_binding a)
  assert_binding "$agent_binding" 'detach-client' 'agent popup hide'
  assert_binding "$agent_binding" \
    'XDG_CONFIG_HOME:.*[.]config[}]/tmux/agent-popup' 'agent popup launcher'
  local copy_bindings
  copy_bindings=$(tmux_cmd list-keys -T copy-mode-vi)
  assert_binding "$copy_bindings" \
    ' v[[:space:]]+send-keys -X begin-selection$' 'copy-mode v selection'
  assert_binding "$copy_bindings" \
    ' y[[:space:]]+send-keys -X copy-selection-and-cancel$' 'copy-mode y copy'
}

for scenario in Linux Darwin Linux-custom Darwin-custom; do
  platform=${scenario%%-*}
  ACTIVE_HOME="$TEST_ROOT/$scenario"
  ACTIVE_SOCKET="dotfiles-tmux-${scenario}-$$"
  bin="$ACTIVE_HOME/bin"
  config_home="$ACTIVE_HOME/.config"
  if [[ $scenario == *-custom ]]; then
    config_home="$ACTIVE_HOME/custom-config"
  fi
  mkdir -p "$bin" "$config_home/tmux"
  config="$config_home/tmux/tmux.conf"
  ln -s "$ROOT/tmux/dot-config/tmux/tmux.conf" "$config"

  # Model Omarchy's shipped defaults, not a second user entrypoint.
  host_config="$ACTIVE_HOME/.local/share/omarchy/config/tmux/tmux.conf"
  if [[ $platform == Linux ]]; then
    mkdir -p "$(dirname "$host_config")"
    cat > "$host_config" <<'EOF'
set -g prefix C-Space
set -g prefix2 C-b
set -g default-terminal "tmux-256color"
set -g base-index 1
setw -g pane-base-index 1
set -g mouse on
set -g renumber-windows on
setw -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
set -g extended-keys on
set -g extended-keys-format csi-u
set -g escape-time 0
set -g detach-on-destroy off
set -sg escape-time 10
set -ag terminal-overrides ",*:RGB"
bind c new-window -c "#{pane_current_path}"
bind h split-window -v -c "#{pane_current_path}"
bind v split-window -h -c "#{pane_current_path}"
bind r command-prompt -I "#W" "rename-window -- '%%'"
bind R command-prompt -I "#S" "rename-session -- '%%'"
bind x kill-pane
bind ? display-message "Omarchy help"
bind q source-file ~/.config/tmux/tmux.conf \; display "Configuration reloaded"
# Stock Omarchy status layout; colors come from the terminal palette.
set -g status-position top
set -g status-interval 5
set -g status-left-length 30
set -g status-right-length 50
set -g window-status-separator ""
set -g status-style "bg=default,fg=default"
set -g status-left "#[fg=black,bg=blue,bold] #S #[bg=default] "
set -g status-right "#[fg=blue]"
set -ag status-right "#{?pane_in_mode,COPY ,}"
set -ag status-right "#{?client_prefix,PREFIX ,}"
set -ag status-right "#{?window_zoomed_flag,ZOOM ,}#[fg=brightblack]#h "
set -g window-status-format "#[fg=brightblack] #I:#W "
set -g window-status-current-format "#[fg=blue,bold] #I:#W "
EOF
  fi
  cat > "$bin/uname" <<'EOF'
#!/bin/sh
printf '%s\n' "$TMUX_TEST_UNAME"
EOF
  chmod +x "$bin/uname"

  tmux_cmd() {
    env -u TMUX HOME="$ACTIVE_HOME" \
      XDG_CONFIG_HOME="$config_home" \
      PATH="$bin:$PATH" TMUX_TEST_UNAME="$platform" \
      tmux -L "$ACTIVE_SOCKET" "$@"
  }

  tmux_cmd -f /dev/null new-session -d -s test -c "$ACTIVE_HOME"
  tmux_cmd set-environment -g PATH "$bin:$PATH"
  tmux_cmd set-environment -g TMUX_TEST_UNAME "$platform"
  default_terminal=$(tmux_cmd show-options -gqv default-terminal)
  # Model a retired popup lingering in an existing server.
  tmux_cmd bind-key p display-popup 'retired-review-popup'
  if [[ $platform == Darwin ]]; then
    # A reload must retire the old Mac shortcuts without restarting sessions.
    tmux_cmd bind-key h previous-window
    tmux_cmd bind-key l next-window
    tmux_cmd bind-key R source-file "$ACTIVE_HOME/.tmux.conf"
  fi
  # Migrate a running server explicitly; never restart it to change config.
  before=$(tmux_cmd display-message -p '#{pid}|#{pane_id}')
  tmux_cmd source-file "$config"
  assert_option "$(tmux_cmd display-message -p '#{pid}|#{pane_id}')" \
    "$before" 'reload preserves the server and pane'

  assert_option "$(tmux_cmd show-options -gqv prefix)" C-Space prefix
  assert_option "$(tmux_cmd show-options -gqv prefix2)" C-b prefix2
  if [[ $platform == Linux ]]; then
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

  reload_config="$config"
  assert_reload_binding "$reload_config"
  assert_shared_workflow_bindings
  prefix_bindings=$(tmux_cmd list-keys -T prefix)
  assert_binding "$prefix_bindings" \
    ' -[[:space:]]+split-window -v -c "#\{pane_current_path\}"' 'prefix -'
  assert_binding "$prefix_bindings" \
    ' /[[:space:]]+split-window -h -c "#\{pane_current_path\}"' 'prefix /'
  assert_binding "$prefix_bindings" \
    'C-Space[[:space:]]+send-prefix' 'shared prefix'
  assert_binding "$prefix_bindings" \
    'C-b[[:space:]]+send-prefix -2' 'secondary prefix forwarding'
  assert_binding "$prefix_bindings" \
    ' r[[:space:]]+command-prompt -I "#W"' 'prefix r'
  assert_binding "$prefix_bindings" \
    ' x[[:space:]]+kill-pane' 'prefix x'
  assert_binding "$prefix_bindings" \
    ' p[[:space:]]+paste-buffer -p$' 'prefix p paste'
  assert_binding "$prefix_bindings" \
    ' v[[:space:]]+copy-mode$' 'shared copy mode'
  assert_binding "$prefix_bindings" \
    ' R[[:space:]]+command-prompt -I "#S"' 'shared session rename'
  if [[ $platform == Linux ]]; then
    assert_binding "$prefix_bindings" \
      ' h[[:space:]]+split-window -v -c "#\{pane_current_path\}"' \
      'Omarchy prefix h'
    assert_binding "$prefix_bindings" \
      ' \?[[:space:]]+display-message "Omarchy help"' 'Omarchy help'
  else
    if [[ -n $(prefix_binding h) ]]; then
      fail 'macOS must retire the old prefix h binding'
    fi
  fi

  # Exercise the declared window actions in the isolated server. A directory
  # with spaces catches quoting regressions; no interactive shell is started.
  project="$ACTIVE_HOME/project with spaces"
  mkdir -p "$project"
  project=$(cd "$project" && pwd -P)
  anchor=$(tmux_cmd new-window -P -F '#{window_id}' -c "$project" \
    'exec sleep 60')
  tmux_cmd set-option -g default-command \
    'printf "tmux-copy-fixture\n"; exec sleep 60'
  action=$(prefix_binding c)
  tmux_cmd if-shell -F 1 "${action#*|}"
  created=$(tmux_cmd display-message -p '#{window_id}')
  [[ $created != "$anchor" ]] || fail 'prefix c did not create a window'
  assert_option "$(tmux_cmd display-message -p '#{pane_current_path}')" \
    "$project" 'new window inherits the active pane directory'
  action=$(prefix_binding l)
  tmux_cmd if-shell -F 1 "${action#*|}"
  assert_option "$(tmux_cmd display-message -p '#{window_id}')" \
    "$anchor" 'prefix l returns to the last-used window'
  tmux_cmd if-shell -F 1 "${action#*|}"
  assert_option "$(tmux_cmd display-message -p '#{window_id}')" \
    "$created" 'prefix l toggles back'

  # Wait for fixture output, then select and copy through tmux's own buffer.
  for ((attempt = 0; attempt < 100; attempt++)); do
    contents=$(tmux_cmd capture-pane -p)
    if grep -Fq 'tmux-copy-fixture' <<<"$contents"; then
      break
    fi
    sleep 0.02
  done
  grep -Fq 'tmux-copy-fixture' <<<"$contents" || fail 'missing copy fixture'
  tmux_cmd copy-mode
  tmux_cmd send-keys -X history-top
  tmux_cmd send-keys -X start-of-line
  tmux_cmd send-keys -X begin-selection
  tmux_cmd send-keys -X end-of-line
  assert_option "$(tmux_cmd display-message -p '#{selection_present}')" \
    1 'copy-mode selection'
  tmux_cmd send-keys -X copy-selection-and-cancel
  assert_option "$(tmux_cmd display-message -p '#{pane_in_mode}')" \
    0 'copy exits copy mode'
  assert_option "$(tmux_cmd show-buffer)" 'tmux-copy-fixture' 'copied text'
  printf 'ok - %s shared copy/window workflow behaves consistently\n' \
    "$platform"

  root_bindings=$(tmux_cmd list-keys -T root)
  for key in C-h C-j C-k C-l M-h M-j M-k M-l; do
    binding_pattern="${key}[[:space:]]+if-shell -F \"#{@pane-is-vim}\""
    if [[ $platform == Darwin || $key == C-* ]]; then
      assert_binding "$root_bindings" "$binding_pattern" \
        "$platform smart-splits $key"
    elif grep -Eq "$binding_pattern" <<<"$root_bindings"; then
      fail "Omarchy must not capture resize key $key"
    fi
  done

  # Both hosts should have the stock layout without fixed RGB colors.
  expected_right='#[fg=blue]#{?pane_in_mode,COPY ,}'
  expected_right+='#{?client_prefix,PREFIX ,}'
  expected_right+='#{?window_zoomed_flag,ZOOM ,}#[fg=brightblack]#h '
  for pass in initial reload; do
    assert_option "$(tmux_cmd show-options -gqv status)" on status
    assert_option "$(tmux_cmd show-options -gqv status-position)" top \
      status-position
    assert_option "$(tmux_cmd show-options -gqv status-justify)" left \
      status-justify
    assert_option "$(tmux_cmd show-options -gqv status-interval)" 5 \
      status-interval
    assert_option "$(tmux_cmd show-options -gqv status-left-length)" 30 \
      status-left-length
    assert_option "$(tmux_cmd show-options -gqv status-right-length)" 50 \
      status-right-length
    assert_option "$(tmux_cmd show-options -gqv status-style)" \
      'bg=default,fg=default' status-style
    assert_option "$(tmux_cmd show-options -gqv status-left)" \
      '#[fg=black,bg=blue,bold] #S #[bg=default] ' status-left
    assert_option "$(tmux_cmd show-options -gqv status-right)" \
      "$expected_right" status-right
    assert_option "$(tmux_cmd show-options -gwqv window-status-format)" \
      '#[fg=brightblack] #I:#W ' window-status-format
    assert_option \
      "$(tmux_cmd show-options -gwqv window-status-current-format)" \
      '#[fg=blue,bold] #I:#W ' window-status-current-format
    assert_option "$(tmux_cmd show-options -gwqv window-status-separator)" \
      '' window-status-separator
    if [[ $pass == initial ]]; then
      action=$(prefix_binding q)
      # key_command escapes separators for display; parse as tmux commands.
      action=${action//\\;/;}
      tmux_cmd if-shell -F 1 "${action#*|}"
    fi
  done
  assert_reload_binding "$reload_config"
  assert_shared_workflow_bindings
  printf 'ok - %s palette-based status layout survives reload\n' "$platform"

  if [[ $platform == Linux ]]; then
    # Custom base settings survive the personal settings applied after them.
    printf '\nset -g status-position bottom\n' >> "$host_config"
    printf 'set -g status-left "host-owned session"\n' >> "$host_config"
    tmux_cmd source-file "$host_config"
    host_status=$(tmux_cmd show-options -g | grep '^status')
    host_windows=$(tmux_cmd show-window-options -g | grep '^window-status')
    tmux_cmd source-file "$config"
    assert_option "$(tmux_cmd show-options -g | grep '^status')" \
      "$host_status" 'Omarchy status ownership'
    assert_option \
      "$(tmux_cmd show-window-options -g | grep '^window-status')" \
      "$host_windows" 'Omarchy window status ownership'
    printf 'ok - entrypoint preserves Omarchy base status\n'
  fi

  # Reloading the entrypoint must finish with personal copy mode.
  if [[ $platform == Linux ]]; then
    tmux_cmd source-file "$config"
    assert_binding "$(tmux_cmd list-keys -T prefix)" \
      ' v[[:space:]]+copy-mode$' 'Omarchy host reload copy mode'
  fi

  tmux_cmd kill-server
  # Exercise native startup queues, not just source-file into a running server.
  # No -f: exercise tmux's actual automatic discovery of the XDG config.
  tmux_cmd new-session -d -s fresh -c "$ACTIVE_HOME" \
    'exec sleep 60'
  assert_reload_binding "$reload_config"
  assert_shared_workflow_bindings
  fresh_bindings=$(tmux_cmd list-keys -T prefix)
  assert_binding "$fresh_bindings" \
    ' v[[:space:]]+copy-mode$' 'fresh server copy mode'
  assert_binding "$fresh_bindings" \
    ' R[[:space:]]+command-prompt -I "#S"' 'fresh server session rename'
  if [[ $platform == Linux ]]; then
    assert_binding "$fresh_bindings" \
      ' h[[:space:]]+split-window -v' 'fresh Omarchy split'
  elif [[ -n $(prefix_binding h) ]]; then
    fail 'fresh macOS server must leave prefix h unbound'
  fi
  tmux_cmd kill-server
  ACTIVE_SOCKET=
  printf 'ok - %s startup/reload preserves host keys with shared v/R/q\n' \
    "$platform"
done

if grep -Eq 'scripts/|herdr|sesh|television|retired-review' \
  "$ROOT/tmux/dot-config/tmux/tmux.conf"; then
  fail 'tmux overlay contains a retired workflow dependency'
fi
printf 'ok - overlay has no retired workflow dependencies\n'
