#!/usr/bin/env sh

battery_level=$($HOME/bin/battery-level.sh)

DEFAULT_BG="colour19"
fg="colour18"
bg="colour01"

if [ "$battery_level" -gt 20 ]; then
  bg="colour03"
fi

if [ "$battery_level" -gt 50 ]; then
  bg="colour02"
fi

echo "#[fg=$bg,bg=$DEFAULT_BG]#[fg=$fg,bg=$bg,bold] $battery_level% "
