#!/bin/bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR="DP-1"

if xrandr | grep "$EXTERNAL_MONITOR disconnected"; then
  xrandr --output "$EXTERNAL_MONITOR" --off \
    --output "$INTERNAL_MONITOR" --auto --mode 1920x1080
else
  xrandr --output "$INTERNAL_MONITOR" --off \
    --output "$EXTERNAL_MONITOR" --auto
fi
