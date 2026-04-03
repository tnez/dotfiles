#!/bin/bash
# Due/overdue Apple Reminders via osascript

BLUE='\033[1;34m'
DIM='\033[2m'
RESET='\033[0m'

show_reminders() {
  osascript -e '
    set output to ""
    tell application "Reminders"
      set allLists to every list
      repeat with reminderList in allLists
        set listName to name of reminderList
        set dueItems to (every reminder of reminderList whose completed is false and due date is not missing value and due date ≤ (current date))
        repeat with r in dueItems
          set output to output & "  [" & listName & "] " & name of r & " (due " & short date string of due date of r & ")" & linefeed
        end repeat
      end repeat
    end tell
    if output is "" then
      return "  (no due reminders)"
    else
      return output
    end if
  ' 2>/dev/null || echo "  (could not access Reminders)"
}

while true; do
  clear
  echo -e "${BLUE}=== Due / Overdue Reminders ===${RESET}"
  show_reminders
  echo ""
  echo -e "${DIM}Last refreshed: $(date '+%H:%M:%S')${RESET}"
  sleep 600
done
