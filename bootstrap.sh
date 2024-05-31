#!/usr/bin/env bash


# Ensure `brew` is installed
if ! command -v brew &> /dev/null; then
  echo "Brew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install brew packages
brew bundle install --file=Brewfile

# First, stow stow, so that the ignore file is respected
stow --target=$HOME stow

# Stow all packages
for package in $(ls -d */); do
  echo "Stowing $package..."
  stow --target=$HOME $package
done
