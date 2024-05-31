function tp -d "Attach to a tmux session based on dirname"
  set bookmarked_dir (pwd)

  set target_readme (fd '[readme|README].md' $HOME/Code | fzf --height=90% --preview 'bat --color=always {}')
  set target_dir (dirname "$target_readme")
  cd "$target_dir"

  set session_name (echo "$target_dir" | xargs basename | tr . -)

  tmux -2 new-session -As "$session_name"

  cd "$bookmarked_dir"
end
