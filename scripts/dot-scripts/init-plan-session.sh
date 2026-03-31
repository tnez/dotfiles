#!/bin/bash
# Initialize plan session with dottie agent and notes windows

SESSION_NAME="plan"
AGENT_WINDOW="dottie"
NOTES_WINDOW="notes"

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Plan session already running"
  exit 0
fi

# Create new session in PARA directory
tmux new-session -d -s "$SESSION_NAME" -c "$HOME/PARA" -n "$AGENT_WINDOW"

# Start claude code (issue /reconstruct once it's up)
tmux send-keys -t "$SESSION_NAME:$AGENT_WINDOW" "claude --permission-mode auto" Enter

# Create notes window
tmux new-window -t "$SESSION_NAME" -n "$NOTES_WINDOW" -c "$HOME/PARA"
tmux send-keys -t "$SESSION_NAME:$NOTES_WINDOW" "nvim $HOME/PARA" Enter

echo "Plan session initialized with windows: $AGENT_WINDOW, $NOTES_WINDOW"
