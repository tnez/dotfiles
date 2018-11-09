#!/usr/bin/env sh

if git status -sb | grep -q '\.\.\.'; then
  git push
else
  git push -u origin HEAD
fi
