#!/bin/sh

set -eu

resolved_path="$(/bin/zsh -l -c 'print -r -- "$PATH"')"

if [ -n "$resolved_path" ]; then
  /bin/launchctl setenv PATH "$resolved_path"
fi
