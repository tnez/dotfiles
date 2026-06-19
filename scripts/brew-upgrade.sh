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
echo "Installed-state snapshot (optional):"
echo "  Homebrew no longer provides a true Brewfile lockfile."
echo "  To snapshot the current installed state:"
echo ""
echo "  cd ~/Code/tnez/dotfiles"
echo "  brew bundle dump --file=brew/Brewfile.snapshot --force"
echo "  git add brew/Brewfile.snapshot"
echo "  git commit -m 'brew: refresh installed snapshot $(date +%Y-%m-%d)'"
