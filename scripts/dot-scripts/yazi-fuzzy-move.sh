#!/bin/bash
# Fuzzy find directory and move files/directories

# Check if any files were passed
if [ $# -eq 0 ]; then
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

# Move files - properly handle spaces in filenames
moved_count=0
failed_count=0

for file in "$@"; do
    if [ -e "$file" ]; then
        basename=$(basename "$file")
        echo "Moving '$basename' to '$target_dir'"
        if mv "$file" "$target_dir/"; then
            ((moved_count++))
        else
            echo "Failed to move '$basename'"
            ((failed_count++))
        fi
    else
        echo "File not found: '$file'"
        ((failed_count++))
    fi
done

# Report results
if [ $failed_count -eq 0 ]; then
    if [ $moved_count -eq 1 ]; then
        echo "1 file moved successfully to $target_dir"
    else
        echo "$moved_count files moved successfully to $target_dir"
    fi
else
    echo "Moved: $moved_count, Failed: $failed_count"
    exit 1
fi