#!/bin/bash
# Pick a sesh target with Television, then connect from this shell/tmux context.

selection="$(tv sesh)" || exit $?

if [[ -z "$selection" ]]; then
  exit 0
fi

exec sesh connect "$selection"
