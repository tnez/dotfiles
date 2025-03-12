#!/bin/bash

# This script will update the name variable in App.svelte every 5 seconds
# to demonstrate the auto-reload feature in Neovim

NAMES=("World" "Neovim" "Auto-reload" "Timer" "Background" "No Focus" "tmux")
APP_FILE="./src/App.svelte"

echo "Starting auto-update demo..."
echo "Open $APP_FILE in Neovim in another pane and watch it reload automatically"
echo "Press Ctrl+C to stop"

count=0
while true; do
  name=${NAMES[$count % ${#NAMES[@]}]}
  count=$((count + 1))
  
  # Update the file by replacing the 'let name = ...' line
  sed -i '' "s/let name = '.*';/let name = '$name';/" "$APP_FILE"
  
  echo "$(date +%H:%M:%S) - Updated name to: $name"
  sleep 5
done