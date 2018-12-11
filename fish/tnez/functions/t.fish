function t -d "Attach to a tmux session based on dirname"
  if test "$argv[1]" = "--project"
    set bookmarked_dir (pwd)

    cd "$HOME/Projects/$argv[2]"
    _open_or_attach_to_session "$argv[2]"

    cd "$bookmarked_dir"
  else
    _open_or_attach_to_session "$argv[1]"
  end
end

function _open_or_attach_to_session
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

complete -x -c t -d 'Connect to existing session' -a "(tmux list-sessions -F '#{session_name}')"
complete -x -c t -l project -d 'Start/Connect to project session' -a "(ls $HOME/Projects)"
