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
echo "Lockfile update (optional):"
echo "  The lockfile tracks package versions at last successful 'brew bundle install'."
echo "  To update it, all packages in Brewfile must be installed:"
echo ""
echo "  cd ~/Code/tnez/dotfiles"
echo "  brew bundle install --global  # This will install missing packages"
echo "  git add brew/Brewfile.lock.json"
echo "  git commit -m 'chore(brew): update lockfile $(date +%Y-%m-%d)'"
