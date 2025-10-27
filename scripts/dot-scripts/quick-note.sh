#!/bin/bash

timestamp=$(date +"%Y%m%d-%H%M%S")
note_file="$HOME/Desktop/NOTE--${timestamp}.md"

# Create the file with a header
cat >"$note_file" <<EOF
# Quick Note - $(date +"%Y-%m-%d %H:%M:%S")

EOF

# Open in neovim
nvim "$note_file"
