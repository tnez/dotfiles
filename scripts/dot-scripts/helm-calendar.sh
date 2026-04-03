#!/bin/bash
# Calendar view — today + tomorrow via icalBuddy

BLUE='\033[1;34m'
DIM='\033[2m'
RESET='\033[0m'

while true; do
  clear
  echo -e "${BLUE}=== Today ===${RESET}"
  icalBuddy -n -nc -nrd -ea eventsToday 2>/dev/null || echo "  (no events)"
  echo ""
  echo -e "${BLUE}=== Tomorrow ===${RESET}"
  icalBuddy -n -nc -nrd -ea eventsToday+1 2>/dev/null || echo "  (no events)"
  echo ""
  echo -e "${DIM}Last refreshed: $(date '+%H:%M:%S')${RESET}"
  sleep 600
done
