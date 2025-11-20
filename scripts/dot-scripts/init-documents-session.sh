#!/bin/bash
# Initialize persistent Documents session with file manager and knowledge agent

SESSION_NAME="docs"
AGENT_WINDOW="kb-agent"
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

# Get today's date for log entries
today=$(date +"%Y-%m-%d")

# Start Claude in agent window with knowledgebase prompt
tmux send-keys -t "$SESSION_NAME:$AGENT_WINDOW" "claude --permission-mode bypassPermissions --append-system-prompt 'You are operating inside a knowledgebase with automation context in \`.agents/**\`. Read README.md and .agents/README.md to get your bearings. Use deep reasoning and search for relationships when answering queries. Cite your sources and distinguish between knowledgebase content and training data. If you cannot answer a question, create a LOG--${today}.md entry in \$HOME/Documents/INBOX.'" Enter

echo "Documents session initialized with windows: $FILES_WINDOW, $AGENT_WINDOW"
