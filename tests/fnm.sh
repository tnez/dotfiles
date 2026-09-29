#!/bin/bash
# Historical entrypoint: now tests mise and the shared environment, not fnm.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TEMP=$(mktemp -d -t dotfiles-shell.XXXXXX)
trap 'rm -rf "$TEMP"' EXIT
export HOME="$TEMP/home"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/mise/shims"
cp "$ROOT/profile/dot-profile" "$HOME/.profile"
cp "$ROOT/bash/dot-bashrc" "$HOME/.bashrc"
cp "$ROOT/bash/dot-bash_aliases" "$HOME/.bash_aliases"
cat > "$HOME/.local/bin/mise" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$HOME/mise.log"
case "$*" in
  'activate bash'|'activate zsh') printf 'export MISE_TEST_ACTIVE=1\n' ;;
  *) exit 99 ;;
esac
EOF
chmod +x "$HOME/.local/bin/mise"
# Use a marker for accidental legacy manager activation.
for tool in fnm pyenv; do
  printf '#!/bin/sh\ntouch "$HOME/legacy-manager-called"\nexit 99\n' \
    > "$HOME/.local/bin/$tool"
  chmod +x "$HOME/.local/bin/$tool"
done
cat > "$HOME/.profile.local" <<'EOF'
export TNEZDEV_KNOWLEDGE_BASE_ROOT="$HOME/kb with spaces"
export EDITOR=vi
EOF
# shellcheck disable=SC2016
env -i HOME="$HOME" PATH=/usr/bin:/bin /bin/sh -c '
  . "$HOME/.profile"
  first=$PATH
  . "$HOME/.profile"
  test "$PATH" = "$first"
  test "$EDITOR" = vi
  test "$TNEZDEV_KNOWLEDGE_BASE_ROOT" = "$HOME/kb with spaces"
  test "${PATH%%:*}" = "$HOME/.local/share/mise/shims"
'
test ! -e "$HOME/mise.log"
printf 'ok - POSIX profile is idempotent, uses shims, and preserves overrides\n'
# shellcheck disable=SC2016
env -i HOME="$HOME" PATH=/usr/bin:/bin bash --noprofile --norc -c \
  '. "$HOME/.bashrc"; test -z "${MISE_TEST_ACTIVE:-}"'
# shellcheck disable=SC2016
env -i HOME="$HOME" PATH=/usr/bin:/bin bash --noprofile --norc -ic \
  '. "$HOME/.bashrc"; test "$MISE_TEST_ACTIVE" = 1; alias lg' \
  > "$TEMP/bash.log" 2>&1
grep -qx 'activate bash' "$HOME/mise.log"
test ! -e "$HOME/legacy-manager-called"
printf 'ok - Bash activates mise only interactively\n'
if ! command -v zsh >/dev/null 2>&1; then
  printf 'BLOCKED: zsh unavailable; native zsh startup not verified\n' >&2
  exit 2
fi
# shellcheck disable=SC2016
env -i HOME="$HOME" PATH=/usr/bin:/bin zsh -f -ic \
  'source "$1"; test "$MISE_TEST_ACTIVE" = 1; alias lg' \
  shell-test "$ROOT/zsh/dot-zshrc" > "$TEMP/zsh.log" 2>&1
grep -qx 'activate zsh' "$HOME/mise.log"
test ! -e "$HOME/legacy-manager-called"
printf 'ok - interactive Zsh activates mise without legacy workflows\n'
