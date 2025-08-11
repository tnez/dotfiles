#!/bin/bash
# Fuzzy find directory and move files/directories

selected_files="$@"

if [ -z "$selected_files" ]; then
    echo "Error: No files selected"
    exit 1
fi

# Use fd and fzf to select target directory
target_dir=$(fd --type d --hidden --exclude .git . ~ | fzf --prompt="Move to: " --height=40% --reverse)

if [ -z "$target_dir" ]; then
    echo "No directory selected"
    exit 1
fi

# Expand tilde if present
target_dir="${target_dir/#\~/$HOME}"

# Create directory if it doesn't exist
mkdir -p "$target_dir"

# Move files
for file in $selected_files; do
    basename=$(basename "$file")
    echo "Moving $basename to $target_dir"
    mv "$file" "$target_dir/"
done

echo "Files moved successfully to $target_dir"