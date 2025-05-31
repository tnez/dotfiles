function get_secret -a key -d "Get the secret[key] from .secrets"
  set SECRETS_FILE ~/.secrets

  if test ! -e "$SECRETS_FILE"
    echo "[ERROR] Could not find ~/.secrets"
    return 1
  end

  if test -z "$key"
    echo "[ERROR] Please specify key with first argument"
    return 1
  end

  cat "$SECRETS_FILE" | while read -l entry
    set parsed (string split "=" $entry)

    if [ "$parsed[1]" = "$key" ]
      echo "$parsed[2]"
      return 0
    end

    echo "[ERROR] Did not find entry for: $key"
    return 1
  end
end
