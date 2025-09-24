#!/bin/bash
# Create Apple Reminder with file attachment using better integration

file="$1"

if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
fi

# Get absolute path
abs_path=$(realpath "$file")
filename=$(basename "$file")

# Prompt for reminder details
echo -n "Reminder title: "
read title

echo -n "Reminder notes (optional): "
read notes

echo -n "Due date (e.g., 'tomorrow', 'next Monday', or leave empty): "
read due_date

# Build AppleScript
if [ -n "$due_date" ]; then
    osascript <<EOF
tell application "Reminders"
    set theFile to POSIX file "$abs_path"
    set theDate to date string of ((current date) + 1 * days)
    
    try
        -- Parse natural language date
        set dueDate to date "$due_date"
    on error
        -- Default to tomorrow if parsing fails
        set dueDate to (current date) + 1 * days
    end try
    
    set theReminder to make new reminder with properties {name:"$title", body:"📎 $filename" & return & return & "$notes" & return & return & "File: $abs_path", remind me date:dueDate}
    
    -- Open Reminders to show the new reminder
    activate
end tell
EOF
else
    osascript <<EOF
tell application "Reminders"
    set theFile to POSIX file "$abs_path"
    
    set theReminder to make new reminder with properties {name:"$title", body:"📎 $filename" & return & return & "$notes" & return & return & "File: $abs_path"}
    
    -- Open Reminders to show the new reminder
    activate
end tell
EOF
fi

echo "✅ Reminder created: $title"