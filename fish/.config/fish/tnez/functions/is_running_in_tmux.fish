function is_running_in_tmux
  if test -z "$TMUX"
    return 1
  else
    return 0
  end
end
