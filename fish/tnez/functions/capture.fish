function capture -a title -d "Capture an item to my inbox"
  if test -z "$title"
    gh issue create --repo tnez/todo --label inbox
  else
    gh issue create --repo tnez/todo --label inbox --title "$title"
  end
end
