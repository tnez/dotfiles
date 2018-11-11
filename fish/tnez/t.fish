function t -d "Attach to a tmux session based on dirname"
  if [ -z "$argv" ]
    set session_name (basename (PWD) | tr . -)
  else
    set session_name "$argv[1]"
  end

  if not is_running_in_tmux
    tmux -2 new-session -As "$session_name"
    return 0
  end

  if not tmux_session_exists "$session_name"
    set TMUX ''
    tmux -2 new-session -Ad -s "$session_name"
  end

  tmux switch-client -t "$session_name"
end
