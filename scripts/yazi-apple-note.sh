#!/bin/bash
# Create Apple Note with file attachment

file="$1"
if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
fi

osascript <<EOF
tell application "Notes"
    set theFile to POSIX file "$file"
    set fileName to name of (info for theFile)
    set newNote to make new note at folder "Notes" of default account
    set name of newNote to "File: " & fileName
    set body of newNote to "Attached file: " & fileName & return & return & "Path: $file" & return & return
    make new attachment at end of attachments of newNote with data theFile
    activate
end tell
EOF