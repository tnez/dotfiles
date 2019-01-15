#!/usr/bin/env sh

echo $(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
