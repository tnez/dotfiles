function tj -d "Attach to a running tmux session"
  tmux attach -t (tmux list-sessions | fzf --preview="" --reverse | cut -d: -f1)
end

