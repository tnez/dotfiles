#!/usr/bin/env bash

set -euo pipefail

on_error() {
  local exit_code=$?
  echo "bootstrap failed at line $1" >&2
  exit "$exit_code"
}

trap 'on_error $LINENO' ERR

# Ensure `brew` is installed
if ! command -v brew &>/dev/null; then
  echo "Brew is not installed. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Symlink Brewfile to home directory
# NOTE: We do not have `stow` available yet, so we need to do this manually
ln -sf "$(pwd)/brew/Brewfile" "$HOME/.Brewfile"

# Install brew packages
echo 'Installing Homebrew packages...'
brew bundle install --global

install_bun() {
  if command -v bun &>/dev/null; then
    return
  fi

  curl -fsSL https://bun.sh/install | bash

  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
}

install_opencode() {
  if command -v opencode &>/dev/null; then
    return
  fi

  curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
  export PATH="$HOME/.opencode/bin:$PATH"
}

install_gh_dash() {
  if ! command -v gh &>/dev/null; then
    echo "Skipping gh-dash install: gh is unavailable" >&2
    return
  fi

  if gh extension list 2>/dev/null | grep -q 'dlvhdr/gh-dash'; then
    return
  fi

  gh extension install dlvhdr/gh-dash
}

install_pi_agent() {
  if command -v pi &>/dev/null; then
    return
  fi

  if command -v bun &>/dev/null; then
    bun add -g @earendil-works/pi-coding-agent
  elif command -v npm &>/dev/null; then
    npm install -g @earendil-works/pi-coding-agent
  else
    echo "Skipping Pi install: bun and npm are unavailable" >&2
  fi
}

stow_package() {
  local package=$1

  echo "Stowing $package with --dotfiles..."
  case "$package" in
    agents)
      remove_materialized_codex_skills
      stow --target="$HOME" --dotfiles --no-folding "$package"
      ;;
    codex)
      stow --target="$HOME" --dotfiles --no-folding "$package"
      seed_codex_config
      ;;
    pi)
      stow --target="$HOME" --dotfiles --no-folding "$package"
      ;;
    *)
      stow --target="$HOME" --dotfiles "$package"
      ;;
  esac
}

install_bun
install_opencode
install_gh_dash
install_pi_agent

# First, stow stow, so that the ignore file is respected
stow --target="$HOME" --dotfiles stow

materialized_codex_skills=()

discover_materialized_codex_skills() {
  local skill_dir

  materialized_codex_skills=()
  for skill_dir in "$PWD"/agents/dot-agents/skills/*; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
      materialized_codex_skills+=("${skill_dir##*/}")
    fi
  done
}

remove_materialized_codex_skills() {
  discover_materialized_codex_skills

  # ~/.agents/skills is the managed shared runtime mirror for this package.
  # Remove materialized copies first, including stale skills that no longer
  # exist in agents/dot-agents/skills, so stow can recreate symlink entrypoints.
  for skill_dir in "$HOME"/.agents/skills/*; do
    if [[ -f "$skill_dir/SKILL.md" && ! -L "$skill_dir/SKILL.md" ]]; then
      rm -f "$skill_dir/SKILL.md"
      rmdir "$skill_dir" 2>/dev/null || true
    fi
  done

  for skill in "${materialized_codex_skills[@]}"; do
    dst="$HOME/.agents/skills/$skill/SKILL.md"
    rm -f "$dst"
  done
}

materialize_codex_skills() {
  # Codex currently skips symlinked SKILL.md files when loading user skills.
  # Keep shared skills sourced from dotfiles, but materialize the live
  # entrypoints so both the desktop app and CLI load them from ~/.agents.
  discover_materialized_codex_skills

  for skill in "${materialized_codex_skills[@]}"; do
    src="$(pwd)/agents/dot-agents/skills/$skill/SKILL.md"
    dst="$HOME/.agents/skills/$skill/SKILL.md"

    mkdir -p "$(dirname "$dst")"
    rm -f "$dst"
    cp "$src" "$dst"
  done
}

seed_codex_config() {
  local src="$PWD/codex/dot-codex/config.base.toml"
  local dst="$HOME/.codex/config.toml"

  if [[ ! -e "$dst" && -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
  fi
}

# Stow packages that use dotfiles pattern
for package in */; do
  package="${package%/}"
  stow_package "$package"
done

materialize_codex_skills
