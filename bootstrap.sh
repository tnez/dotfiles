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

materialized_codex_skills=(reconstruct wrap)

remove_materialized_codex_skills() {
  for skill in "${materialized_codex_skills[@]}"; do
    dst="$HOME/.agents/skills/$skill/SKILL.md"
    rm -f "$dst"
  done
}

materialize_codex_skills() {
  # Codex currently skips symlinked SKILL.md files when loading user skills.
  # Keep these wrapper skills sourced from dotfiles, but materialize the live
  # entrypoints so both the desktop app and CLI load them from ~/.agents.
  for skill in "${materialized_codex_skills[@]}"; do
    src="$(pwd)/agents/dot-agents/skills/$skill/SKILL.md"
    dst="$HOME/.agents/skills/$skill/SKILL.md"

    mkdir -p "$(dirname "$dst")"
    rm -f "$dst"
    cp "$src" "$dst"
  done
}

# Stow packages that use dotfiles pattern
for package in */; do
  package="${package%/}"
  echo "Stowing $package with --dotfiles..."
  case "$package" in
    agents)
      remove_materialized_codex_skills
      stow --target="$HOME" --dotfiles --no-folding "$package"
      ;;
    codex)
      stow --target="$HOME" --dotfiles --no-folding "$package"
      ;;
    *)
      stow --target="$HOME" --dotfiles "$package"
      ;;
  esac
done

materialize_codex_skills
