#!/bin/bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Tmux Keys I Care About
======================

Prefix
------

  Prefix          Ctrl-Space
  Prefix H        This help sheet
  Prefix ?        Full tmux key list
  Prefix R        Reload ~/.tmux.conf

Sessions
--------

  Ctrl-t          Open sesh picker in a popup

Panes
-----

  Prefix /        Split pane right, same directory
  Prefix -        Split pane down, same directory
  Prefix x        Kill pane without confirmation
  Ctrl-h/j/k/l    Move between panes, Neovim-aware
  Alt-h/j/k/l     Resize panes, Neovim-aware

Windows
-------

  Prefix c        New window
  Prefix r        Rename window
  Prefix h        Previous window
  Prefix l        Next window

Copy Mode
---------

  Prefix v        Enter copy mode
  v               Begin selection
  V               Select line
  Ctrl-v          Rectangle selection
  y               Copy selection to clipboard
  q / Esc         Exit copy mode

Popups
------

  Prefix m        Mission control dashboard
  Prefix ,        Quick agent
  Prefix g        Git popup
  Prefix G        GitHub workbench help
  Prefix i        GitHub dashboard
  Prefix P        All PRs picker
  Prefix p        Review-requested PRs picker
  Prefix Ctrl-p   Changes-requested PRs picker
  Prefix y        Ready issues picker
  Prefix I        Inbox popup
  Prefix n        Quick note
  Prefix t        Top/process popup
EOF
}

if [[ -t 1 ]] && command -v less >/dev/null 2>&1; then
  show_help | less
else
  show_help
fi
