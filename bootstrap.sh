#!/usr/bin/env bash

# Ensure `brew` is installed
if ! command -v brew &>/dev/null; then
  echo "Brew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install brew packages
brew bundle install --file=brew/Brewfile

# First, stow stow, so that the ignore file is respected
stow --target=$HOME stow

# Stow packages that use dotfiles pattern
for package in bash editorconfig env fish nvim tmux vim snippets starship lazygit lazyvim wezterm nushell yazi raycast zellij marimo bat aerospace sesh ripgrep ghostty; do
  echo "Stowing $package with --dotfiles..."
  stow --target=$HOME --dotfiles $package
done

# Stow packages that don't use dotfiles pattern
for package in git scripts; do
  if [ -d "$package" ]; then
    echo "Stowing $package..."
    stow --target=$HOME $package
  fi
done
