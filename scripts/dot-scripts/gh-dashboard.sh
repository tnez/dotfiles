#!/bin/bash
# GH dashboard — notifications, review requests, open PRs, assigned issues

BLUE='\033[1;34m'
DIM='\033[2m'
RESET='\033[0m'

run_dashboard() {
  echo -e "${BLUE}=== Notifications ===${RESET}"
  gh api notifications --jq '.[] | "  \(.subject.title) (\(.repository.full_name)) [\(.reason)]"' 2>/dev/null || echo "  (none)"
  echo ""

  echo -e "${BLUE}=== PRs Needing Review ===${RESET}"
  gh search prs --review-requested=@me --state=open --limit 10 \
    --json title,repository,url \
    --jq '.[] | "  \(.title) (\(.repository.nameWithOwner))\n    \(.url)"' 2>/dev/null || echo "  (none)"
  echo ""

  echo -e "${BLUE}=== My Open PRs ===${RESET}"
  gh pr status 2>/dev/null | tail -n +2
  echo ""

  echo -e "${BLUE}=== Assigned Issues ===${RESET}"
  gh search issues --assignee=@me --state=open --limit 10 \
    --json title,repository,url \
    --jq '.[] | "  \(.title) (\(.repository.nameWithOwner))\n    \(.url)"' 2>/dev/null || echo "  (none)"

  echo ""
  echo -e "${DIM}Last refreshed: $(date '+%H:%M:%S')${RESET}"
}

if [[ "$1" == "--once" ]]; then
  run_dashboard
  echo ""
  echo "Press any key to close..."
  read -n 1 -s
else
  while true; do
    clear
    run_dashboard
    sleep 300
  done
fi
