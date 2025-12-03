#!/bin/bash
# Tmux status line helper - outputs git and path info for current pane
# Usage: tmux-status.sh <pane_path> <session_name>

pane_path="$1"
session_name="$2"
cd "$pane_path" 2>/dev/null || exit 0

# Get directory/repo name
dir_name=$(basename "$pane_path")

# Build output
output=""

# Check if in a git repo
if git rev-parse --is-inside-work-tree &>/dev/null; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  # Check for uncommitted changes
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    output=" ${branch} ○"
  else
    output=" ${branch}"
  fi
fi

# Add directory name only if different from session name
if [[ "$dir_name" != "$session_name" ]]; then
  output="${output} ${dir_name}"
fi

echo "$output"
