#!/bin/bash
# Attach to dottie persona in plan session

SESSION_NAME="plan"
AGENT_WINDOW="dottie"

# Ensure plan session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  ~/.scripts/init-plan-session.sh
fi

# Attach to agent window in popup-friendly way
tmux display-popup -E -w 80% -h 80% "tmux attach-session -t $SESSION_NAME:$AGENT_WINDOW"
