#!/bin/bash
# Add a new Homebrew package
# Usage: ./scripts/brew-add.sh <package> [--cask]

set -eu

SCRIPT_DIR=$(cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd)
REPO_ROOT=${SCRIPT_DIR%/*}
BREWFILE=$REPO_ROOT/brew/Brewfile

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <package> [--cask]"
  echo "Example: $0 shellcheck"
  echo "Example: $0 firefox --cask"
  exit 1
fi

PACKAGE="$1"
IS_CASK=""
if [ "${2:-}" = "--cask" ]; then
  IS_CASK="--cask"
fi

echo "Installing $PACKAGE..."
if [ -n "$IS_CASK" ]; then
  brew install --cask "$PACKAGE"
else
  brew install "$PACKAGE"
fi

echo "Adding to Brewfile..."
if [ -n "$IS_CASK" ]; then
  brew bundle add --file="$BREWFILE" --cask "$PACKAGE"
else
  brew bundle add --file="$BREWFILE" "$PACKAGE"
fi

echo ""
echo "✓ $PACKAGE installed and added to Brewfile"
echo ""
echo "Next steps:"
echo "  1. Edit $BREWFILE to add a description and place it alphabetically"
echo "  2. Review the repository diff"
echo "  3. git commit -m 'chore(brew): add $PACKAGE'"
