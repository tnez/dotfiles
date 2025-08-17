#!/usr/bin/env bash

# Ensure `brew` is installed
if ! command -v brew &>/dev/null; then
  echo "Brew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install brew packages
brew bundle install --file=./.brew/Brewfile

# First, stow stow, so that the ignore file is respected
stow --target=$HOME --dotfiles stow

# Stow packages that use dotfiles pattern
for package in */; do
  echo "Stowing $package with --dotfiles..."
  stow --target=$HOME --dotfiles $package
done
