#!/usr/bin/env bash
# Add a new Homebrew package
# Usage: ./scripts/brew-add.sh <package> [--cask]

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <package> [--cask]"
  echo "Example: $0 shellcheck"
  echo "Example: $0 firefox --cask"
  exit 1
fi

PACKAGE="$1"
IS_CASK=""
if [ "$2" = "--cask" ]; then
  IS_CASK="--cask"
fi

echo "Installing $PACKAGE..."
if [ -n "$IS_CASK" ]; then
  brew install --cask "$PACKAGE"
else
  brew install "$PACKAGE"
fi

echo "Adding to Brewfile..."
brew bundle add $IS_CASK "$PACKAGE" --global

echo ""
echo "✓ $PACKAGE installed and added to Brewfile"
echo ""
echo "Next steps:"
echo "  1. Edit ~/Code/tnez/dotfiles/brew/Brewfile to add description comment and place alphabetically"
echo "  2. cd ~/Code/tnez/dotfiles && git add brew/Brewfile"
echo "  3. git commit -m 'chore(brew): add $PACKAGE'"
