#!/usr/bin/env bash

# Ensure `brew` is installed
if ! command -v brew &>/dev/null; then
  echo "Brew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Symlink Brewfile to home directory
# NOTE: We do not have `stow` available yet, so we need to do this manually
ln -sf "$(pwd)/brew/Brewfile" "$HOME/.Brewfile"

# Install brew packages
brew bundle install --global

# First, stow stow, so that the ignore file is respected
stow --target=$HOME --dotfiles stow

# Stow packages that use dotfiles pattern
for package in */; do
  echo "Stowing $package with --dotfiles..."
  stow --target=$HOME --dotfiles $package
done
