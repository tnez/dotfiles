#!/bin/bash

# Check if there's already a quick note on the Desktop
existing_note=$(find "$HOME/Desktop" -name "NOTE--*.md" -type f | sort | tail -n 1)

if [ -n "$existing_note" ]; then
  # Use existing note
  note_file="$existing_note"
else
  # Create new note with timestamp
  timestamp=$(date +"%Y%m%d-%H%M%S")
  note_file="$HOME/Desktop/NOTE--${timestamp}.md"

  # Create the file with a header
  cat >"$note_file" <<EOF
# Quick Note - $(date +"%Y-%m-%d %H:%M:%S")

EOF
fi

# Open in neovim
nvim "$note_file"
