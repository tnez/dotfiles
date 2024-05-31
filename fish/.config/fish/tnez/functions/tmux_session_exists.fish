function tmux_session_exists -a session_name
  tmux list-sessions | sed -E 's/:.*$//' | grep -q "^$session_name\$"
end

