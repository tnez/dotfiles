function cdp -a pattern -d "Change into a project directory"
  if test -z "$pattern"
    set pattern .
  end

  cd (fdfind --type d --max-depth 1 $pattern $HOME/Projects/* | fzf)
end
