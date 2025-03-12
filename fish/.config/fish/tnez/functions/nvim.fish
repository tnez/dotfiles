function nvim
  if test -d .venv
    if test -f poetry.lock
      echo "Found .venv directory and poetry.lock, running 'poetry run nvim'"
      poetry run /usr/bin/env nvim $argv
    else if test -f uv.lock
      echo "Found .venv directory and uv.lock, running 'uv run nvim'"
      uv run /usr/bin/env nvim $argv
    else
      echo "Found .venv directory but no lock file, running 'nvim'"
      /usr/bin/env nvim $argv
    end

  else
     echo "No .venv directory found, running 'nvim'"
     /usr/bin/env nvim $argv
  end
end
