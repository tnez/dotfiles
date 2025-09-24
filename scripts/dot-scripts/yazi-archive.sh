#!/bin/bash
# Move files/directories to archive directory

ARCHIVE_DIR="$HOME/Documents/ARCHIVE"

# Check if any files were passed
if [ $# -eq 0 ]; then
    echo "Error: No files selected"
    exit 1
fi

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Move files - properly handle spaces in filenames
moved_count=0
failed_count=0

for file in "$@"; do
    if [ -e "$file" ]; then
        basename=$(basename "$file")

        # Check if file already exists in archive
        if [ -e "$ARCHIVE_DIR/$basename" ]; then
            # Add timestamp to filename if it already exists
            timestamp=$(date +%Y%m%d_%H%M%S)
            name="${basename%.*}"
            ext="${basename##*.}"
            if [ "$name" = "$basename" ]; then
                # No extension
                new_basename="${basename}_${timestamp}"
            else
                # Has extension
                new_basename="${name}_${timestamp}.${ext}"
            fi
            echo "File exists, archiving as '$new_basename'"
            target_path="$ARCHIVE_DIR/$new_basename"
        else
            target_path="$ARCHIVE_DIR/$basename"
        fi

        echo "Archiving '$basename' to ARCHIVE"
        if mv "$file" "$target_path"; then
            ((moved_count++))
        else
            echo "Failed to archive '$basename'"
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
        echo "✓ 1 file archived successfully"
    else
        echo "✓ $moved_count files archived successfully"
    fi
else
    echo "Archived: $moved_count, Failed: $failed_count"
    exit 1
fi