#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
REPO_ROOT=${SCRIPT_DIR%/*}
TMPDIR_TEST=$(mktemp -d -t dotfiles-fnm-tests.XXXXXX)
HOME_TEST=$TMPDIR_TEST/home
BIN_TEST=$HOME_TEST/.local/bin

cleanup() {
  rm -rf "$TMPDIR_TEST"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$BIN_TEST" "$HOME_TEST/fnm-node/bin"

printf '#!/bin/sh\nexit 0\n' > "$HOME_TEST/.local/bin/node"
printf '#!/bin/sh\nexit 0\n' > "$HOME_TEST/fnm-node/bin/node"
chmod +x "$HOME_TEST/.local/bin/node" "$HOME_TEST/fnm-node/bin/node"

cat > "$BIN_TEST/fnm" <<'EOF'
#!/bin/sh

printf '%s\n' "$*" >> "$HOME/fnm.log"

if [ "$1" = env ]; then
  case "$4" in
    zsh)
      cat <<'ZSH'
export PATH="$HOME/fnm-node/bin:$PATH"
fnm() { command fnm "$@"; }
fnm_use_on_cd() { :; }
autoload -Uz add-zsh-hook
add-zsh-hook chpwd fnm_use_on_cd
ZSH
      ;;
    bash)
      cat <<'BASH'
export PATH="$HOME/fnm-node/bin:$PATH"
fnm() { command fnm "$@"; }
BASH
      ;;
  esac
  exit 0
fi

exit 0
EOF
chmod +x "$BIN_TEST/fnm"

# shellcheck disable=SC2016
bash_node=$(env -i HOME="$HOME_TEST" PATH="$BIN_TEST:/usr/bin:/bin" \
  /bin/bash -c '. "$1"; command -v node' profile-test \
  "$REPO_ROOT/profile/dot-profile")
test "$bash_node" = "$HOME_TEST/fnm-node/bin/node"
/usr/bin/grep -qx 'use default --silent-if-unchanged' "$HOME_TEST/fnm.log"

# shellcheck disable=SC2016
zsh_result=$(env -i HOME="$HOME_TEST" PATH="$BIN_TEST:/usr/bin:/bin" \
  /bin/zsh -fc '
    source "$1"
    source "$2"
    print -r -- "$(command -v node)"
    alias cd
    print -r -- "${chpwd_functions[*]}"
  ' zsh-test "$REPO_ROOT/profile/dot-profile" "$REPO_ROOT/zsh/dot-zshrc")

printf '%s\n' "$zsh_result" | /usr/bin/grep -qx \
  "$HOME_TEST/fnm-node/bin/node"
printf '%s\n' "$zsh_result" | /usr/bin/grep -qx "cd=z"
printf '%s\n' "$zsh_result" | /usr/bin/grep -Eq \
  '(^| )fnm_use_on_cd( |$)'

printf 'All fnm tests passed.\n'
