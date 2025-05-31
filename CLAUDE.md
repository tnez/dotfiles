# DOTFILES PROJECT REFERENCE

This repository contains my personal dotfiles managed via GNU Stow. Each directory represents a stow package for a specific tool or application.

## Quick Start Commands

- `./bootstrap.sh` - Initial setup of dotfiles on new machine
- `stow --dotfiles <package>` - Symlink specific config package to ~
  - Uses `dot-` prefix convention (e.g., `dot-config` → `.config`)
- `stow --dotfiles -D <package>` - Remove package symlinks
- `brew bundle --file=brew/Brewfile` - Install dependencies from Brewfile

## Project-Specific Style

- UTF-8 encoding, Unix line endings (LF)
- 2-space indent (4 for Python)
- 80 char line limit (except Markdown)
- Trim trailing whitespace
- End files with newline

## Language Standards

- **Lua**: StyLua (2 space, single quotes, 160 cols)
- **Python**: 4 spaces
- **JS/TS**: Prettier
- **Shell**: ShellCheck compliance

## Repository Structure

- Organized by tool/application name
- Each directory = stow package
- XDG-compliant where possible (`dot-config/` maps to `~/.config/`)
- Special packages:
  - `claude/` - Global Claude Code preferences (symlinked to `~/.claude/`)
  - `brew/` - Homebrew dependencies
  - `scripts/` - Utility scripts

## Testing Changes

- Test stow packages in isolation before committing
- Verify symlinks point to correct locations
- Check that unstowing doesn't break existing configs

## Adding New Configurations

1. Create new directory named after the tool
2. Use `dot-` prefix for dotfiles (e.g., `dot-vimrc` → `~/.vimrc`)
3. Test with `stow --dotfiles --no-folding <package>` first
4. Add any dependencies to `brew/Brewfile` if needed
