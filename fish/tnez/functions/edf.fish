function edf -a pattern -d "Open a file from Downloads in editor"
  if test -z "$pattern"
    set pattern .
  end

  edit (fdfind --type f $pattern $HOME/Downloads | fzf)
end
