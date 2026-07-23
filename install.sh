#!/bin/bash

set -u

DEFAULT_CHECKOUT=$HOME/Code/tnez/dotfiles/main
REPOSITORY=https://github.com/tnez/dotfiles.git
CHECKOUT=
ORIGIN=
NON_INTERACTIVE=0
ASSUME_YES=0
TRUST_FORMULAE=()

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Locate or clone the canonical dotfiles checkout, then run its local bootstrap.

Options:
  --path PATH             Canonical checkout path
  --non-interactive       Never prompt; use --path or the default path
  --yes                   Skip routine bootstrap confirmation
  --trust-formula NAME    Pass explicit reviewed formula trust to bootstrap
  -h, --help              Show this help
EOF
}

action_required() {
  printf 'ACTION_REQUIRED: %s\n' "$*" >&2
}

expand_home() {
  case "$1" in
    '~') printf '%s\n' "$HOME" ;;
    \~/*) printf '%s/%s\n' "$HOME" "${1#\~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --path)
      [ "$#" -ge 2 ] || {
        printf 'ERROR: --path requires a value.\n' >&2
        exit 2
      }
      CHECKOUT=$2
      shift
      ;;
    --path=*) CHECKOUT=${1#*=} ;;
    --non-interactive) NON_INTERACTIVE=1 ;;
    --yes) ASSUME_YES=1 ;;
    --trust-formula)
      [ "$#" -ge 2 ] || {
        printf 'ERROR: --trust-formula requires a value.\n' >&2
        exit 2
      }
      TRUST_FORMULAE+=("$2")
      shift
      ;;
    --trust-formula=*) TRUST_FORMULAE+=("${1#*=}") ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'ERROR: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

if [ "$(uname -s 2>/dev/null)" != Darwin ]; then
  printf 'ERROR: these dotfiles support macOS only.\n' >&2
  exit 1
fi

if [ -z "$CHECKOUT" ]; then
  CHECKOUT=$DEFAULT_CHECKOUT
  if [ "$NON_INTERACTIVE" -eq 0 ]; then
    if [ ! -r /dev/tty ]; then
      action_required "interactive checkout selection needs a terminal"
      exit 3
    fi
    printf 'Canonical checkout [%s]: ' "$DEFAULT_CHECKOUT" > /dev/tty
    IFS= read -r answer < /dev/tty || answer=
    [ -n "$answer" ] && CHECKOUT=$answer
  fi
fi
CHECKOUT=$(expand_home "$CHECKOUT")

if [ -f "$CHECKOUT/.git" ]; then
  action_required "checkout is a linked/disposable worktree: $CHECKOUT"
  exit 3
fi

command -v git >/dev/null 2>&1 || {
  printf 'ERROR: git is required to validate or clone %s\n' \
    "$REPOSITORY" >&2
  exit 1
}

if [ -d "$CHECKOUT/.git" ]; then
  ORIGIN=$(git -C "$CHECKOUT" config --get remote.origin.url \
    2>/dev/null || true)
  case "$ORIGIN" in
    https://github.com/tnez/dotfiles|https://github.com/tnez/dotfiles.git|\
git@github.com:tnez/dotfiles.git|ssh://git@github.com/tnez/dotfiles.git) ;;
    *)
      action_required "existing checkout has an unexpected origin: $ORIGIN"
      exit 3
      ;;
  esac
  printf 'Reusing existing checkout: %s\n' "$CHECKOUT"
elif [ -e "$CHECKOUT" ]; then
  action_required "checkout path exists but is not a primary Git checkout"
  exit 3
else
  mkdir -p "$(dirname "$CHECKOUT")" || exit 1
  git clone "$REPOSITORY" "$CHECKOUT" || exit 1
fi

if [ ! -x "$CHECKOUT/dotfiles" ]; then
  action_required "repository-local CLI is missing or not executable"
  printf 'Update the checkout at %s, inspect it, and retry.\n' "$CHECKOUT" >&2
  exit 3
fi

bootstrap_options=()
[ "$NON_INTERACTIVE" -eq 1 ] && bootstrap_options+=(--non-interactive)
[ "$ASSUME_YES" -eq 1 ] && bootstrap_options+=(--yes)
if [ "${#TRUST_FORMULAE[@]}" -gt 0 ]; then
  for formula in "${TRUST_FORMULAE[@]}"; do
    bootstrap_options+=(--trust-formula "$formula")
  done
fi

if [ "${#bootstrap_options[@]}" -gt 0 ]; then
  exec "$CHECKOUT/dotfiles" bootstrap "${bootstrap_options[@]}"
else
  exec "$CHECKOUT/dotfiles" bootstrap
fi
