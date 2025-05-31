function cdp -a pattern -d "Change into a project directory"
  if test -z "$pattern"
    set pattern .
  end

  cd (fd --type d --max-depth 1 $pattern $HOME/code/* | fzf)
end
