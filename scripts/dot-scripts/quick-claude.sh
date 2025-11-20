#!/bin/bash
# Attach to persistent knowledge agent in Documents session

SESSION_NAME="docs"
AGENT_WINDOW="kb-agent"

# Ensure Documents session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  ~/.scripts/init-documents-session.sh
fi

# Attach to agent window in popup-friendly way
tmux display-popup -E -w 80% -h 80% "tmux attach-session -t $SESSION_NAME:$AGENT_WINDOW"
