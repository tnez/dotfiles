#!/bin/bash

is_connected () {
  [ $1 -gt 0 ]
}

eDP1=$(xrandr | egrep -c '^eDP1 connected')
DP1=$(xrandr | egrep -c '^DP1 connected')
DP11=$(xrandr | egrep -c '^DP1-1 connected')
DP12=$(xrandr | egrep -c '^DP1-2 connected')
DP2=$(xrandr | egrep -c '^DP2 connected')
DP21=$(xrandr | egrep -c '^DP2-1 connected')
DP22=$(xrandr | egrep -c '^DP2-2 connected')

# Logging for debugging
# TODO: put this behind a `debug` option
echo "eDP1: $eDP1"
echo "DP1: $DP1"
echo "DP1-1: $DP11"
echo "DP1-2: $DP12"
echo "DP2: $DP2"
echo "DP2-1: $DP21"
echo "DP2-2: $DP22"

# Turn off the internal monitor if we are connected to an external monitor.
# Note: I never use the laptop monitor when connected to external. If you do you
# will need to tweak this.
if \
  is_connected $DP1 || \
  is_connected $DP2 || \
  is_connected $DP11 || \
  is_connected $DP12 || \
  is_connected $DP21 || \
  is_connected $DP22;
then
  xrandr --output eDP1 --off
else
  xrandr --output eDP1 --auto --mode 2048x1152
fi

if is_connected $DP1; then
  # Note: applying temporary override while traveling, remove this when back
  # home.
  # xrandr --output DP1 --auto
  xrandr --output DP1 --mode 3200x1800
else
  xrandr --output DP1 --off
fi

if is_connected $DP2; then
  xrandr --output DP2 --auto
else
  xrandr --output DP2 --off
fi

if is_connected $DP11; then
  xrandr --output DP1-1 --auto
else
  xrandr --output DP1-1 --off
fi

if is_connected $DP12; then
  xrandr --output DP1-2 --auto
else
  xrandr --output DP1-2 --off
fi

if is_connected $DP21; then
  xrandr --output DP2-1 --auto
else
  xrandr --output DP2-1 --off
fi

if is_connected $DP22; then
  xrandr --output DP2-2 --auto
else
  xrandr --output DP2-2 --off
fi
