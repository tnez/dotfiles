#!/bin/bash
# Initialize persistent Documents session with file manager and dottie persona

SESSION_NAME="docs"
AGENT_WINDOW="dottie"
FILES_WINDOW="files"

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Documents session already running"
  exit 0
fi

# Create new session in Documents directory
tmux new-session -d -s "$SESSION_NAME" -c "$HOME/Documents" -n "$FILES_WINDOW"

# Start file manager (yazi) in first window
tmux send-keys -t "$SESSION_NAME:$FILES_WINDOW" "yazi" Enter

# Create agent window
tmux new-window -t "$SESSION_NAME" -n "$AGENT_WINDOW" -c "$HOME/Documents"

# Start dottie persona in interactive mode
tmux send-keys -t "$SESSION_NAME:$AGENT_WINDOW" "npx dot-agents personas run dottie --interactive" Enter

echo "Documents session initialized with windows: $FILES_WINDOW, $AGENT_WINDOW"
