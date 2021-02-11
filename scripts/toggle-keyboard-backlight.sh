#!/usr/bin/env bash

DEVICE=tpacpi::kbd_backlight

if [ $(brightnessctl --device="$DEVICE" | egrep -c 'Current brightness: 0 ') -gt 0 ]
then
  brightnessctl --device="$DEVICE" --quiet set 50%
else
  brightnessctl --device="$DEVICE" --quiet set 0
fi
