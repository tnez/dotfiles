#!/bin/bash

is_connected () {
  [ $1 -gt 0 ]
}

eDP1=$(xrandr | egrep -c '^eDP-1 connected')
DP1=$(xrandr | egrep -c '^DP-1 connected')
DP2=$(xrandr | egrep -c '^DP-2 connected')
DP11=$(xrandr | egrep -c '^DP-1-1 connected')
DP12=$(xrandr | egrep -c '^DP-1-2 connected')

# Logging for debugging
# TODO: put this behind a `debug` option
echo "eDP-1: $eDP1"
echo "DP-1: $DP1"
echo "DP-2: $DP2"
echo "DP-1-1: $DP11"
echo "DP-1-2: $DP12"

# Turn off the internal monitor if we are connected to an external monitor.
# Note: I never use the laptop monitor when connected to external. If you do you
# will need to tweak this.
if \
  is_connected $DP1 || \
  is_connected $DP2 || \
  is_connected $DP11 || \
  is_connected $DP12;
then
  xrandr --output eDP-1 --off
else
  xrandr --output eDP-1 --auto --mode 1920x1080
fi

if is_connected $DP1; then
  xrandr --output DP-1 --auto
else
  xrandr --output DP-1 --off
fi

if is_connected $DP2; then
  xrandr --output DP-2 --auto
else
  xrandr --output DP-2 --off
fi

if is_connected $DP11; then
  xrandr --output DP-1-1 --auto
else
  xrandr --output DP-1-1 --off
fi

if is_connected $DP12; then
  xrandr --output DP-1-2 --auto
else
  xrandr --output DP-1-2 --off
fi
