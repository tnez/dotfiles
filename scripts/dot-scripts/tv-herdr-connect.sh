#!/bin/bash
# Pick an existing or sesh-inspired Herdr workspace with Television.

set -euo pipefail

selection="$(
  tv \
    --source-command "$HOME/.scripts/herdr-session.sh --list" \
    --preview-command "$HOME/.scripts/herdr-session.sh --preview '{}'"
)" || exit $?

[[ -z "$selection" ]] || exec "$HOME/.scripts/herdr-session.sh" "$selection"
