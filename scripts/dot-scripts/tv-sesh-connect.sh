#!/bin/bash
# Pick a sesh target with Television, then connect from this shell/tmux context.

selection="$(
  tv \
    --source-command 'sesh list --icons' \
    --ansi \
    --source-output '{strip_ansi|split: :1..|join: }' \
    --preview-command "$HOME/.scripts/tv-sesh-preview.sh '{}'"
)" || exit $?

if [[ -z "$selection" ]]; then
  exit 0
fi

if [[ -n "$TMUX" ]]; then
  exec sesh connect --switch "$selection"
fi

exec sesh connect "$selection"
