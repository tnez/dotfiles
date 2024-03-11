function nvim
  if test -d .venv
     echo "Found .venv directory, running 'poetry run nvim'"
     poetry run /usr/bin/env nvim $argv
  else
     echo "No .venv directory found, running 'nvim'"
     /usr/bin/env nvim $argv
  end
end
