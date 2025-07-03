#!/bin/bash
# Create Apple Reminder with file attachment

file="$1"
name="$2"

if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
fi

if [ -z "$name" ]; then
    echo -n "Enter reminder name: "
    read name
fi

osascript <<EOF
tell application "Reminders"
    set theFile to POSIX file "$file"
    set fileName to name of (info for theFile)
    set newReminder to make new reminder with properties {name:"$name", body:"File: " & fileName & return & "Path: $file"}
    activate
end tell
EOF