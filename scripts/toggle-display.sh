#!/bin/bash

is_connected () {
  [ $1 -gt 0 ]
}

DP1=$(xrandr | egrep -c '^DP-1 connected')
DP2=$(xrandr | egrep -c '^DP-2 connected')

# Turn off the internal monitor if we are connected to an external monitor.
# Note: I never use the laptop monitor when connected to external. If you do you
# will need to tweak this.
if is_connected $DP1 || is_connected $DP2; then
  xrandr --output eDP-1 --off
else
  xrandr --output eDP-1 --auto --mode 1920x1080
fi

# Turn on DP-1 if it is connected
if is_connected $DP1; then
  xrandr --output DP-1 --auto
fi

# Turn on DP-2 if it is connected
if is_connected $DP2; then
  xrandr --output DP-2 --auto
fi
