#!/usr/bin/env bash
# Upgrade Homebrew packages
# Usage: ./scripts/brew-upgrade.sh

set -e

echo "Updating Homebrew..."
brew update

echo ""
echo "Upgrading packages..."
brew upgrade

echo ""
echo "Cleaning up..."
brew cleanup

echo ""
echo "✓ Packages upgraded"
echo ""
echo "Brewfile is the source of truth."
echo "  To converge on it: brew bundle install --global"
echo "  To prune extras:   brew bundle cleanup --force --file=brew/Brewfile"
echo ""
echo "  cd ~/Code/tnez/dotfiles"
echo "  brew bundle install --global"
