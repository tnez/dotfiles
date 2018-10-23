#!/usr/bin/env bash

read cwd

KITTY_EXE="/Applications/kitty.app/Contents/MacOS/kitty"

$KITTY_EXE --single-instance -d "$cwd"
