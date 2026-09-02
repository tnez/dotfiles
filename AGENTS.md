# DOTFILES PROJECT REFERENCE

This repository contains my personal dotfiles managed via GNU Stow.

## Lifecycle Commands

- `./dotfiles doctor` - Read-only prerequisite and conflict checks
- `./dotfiles plan` - Read-only provisioning and activation simulation
- `./dotfiles apply` - Fast Stow, copied-file, and integration convergence
- `./dotfiles provision` - Install missing dependencies without upgrading all
- `./dotfiles upgrade` - Explicit slow package update, upgrade, and cleanup
- `./dotfiles modules [--all]` - List selected declarative components
- `./dotfiles bootstrap` - Doctor, plan, provision, apply, and final doctor
- `stow --dotfiles <package>` - Symlink specific config package to ~
  - Uses `dot-` prefix convention (e.g., `dot-config` → `.config`)
- `stow --dotfiles -D <package>` - Remove package symlinks
- `brew bundle --file=brew/Brewfile` - Install dependencies from Brewfile

## Agent Driving Contract

1. Run `./dotfiles doctor` and `./dotfiles plan` before proposing or running a
   mutating lifecycle command. Both are safe in linked worktrees.
2. Never run `bootstrap`, `apply`, `provision`, or `upgrade` from a disposable
   checkout. A `.git` file means linked/disposable; activation is allowed only
   from the canonical primary checkout with a `.git` directory.
3. After a candidate change is merged, run the needed command from the updated
   primary checkout. Existing stowed-file edits are usually already live; on
   macOS use `apply` for path/copy/integration changes, `provision` for missing
   dependencies, and `upgrade` only when package upgrades are intended.
   Omarchy activation remains manual and requires explicit approval.
4. On a new macOS machine, inspect and run `install.sh`, or invoke it with
   `--path "$HOME/Code/tnez/dotfiles/main" --non-interactive --yes`. The
   installer clones or reuses the canonical checkout and calls local
   `dotfiles bootstrap`.
5. If any command emits `ACTION_REQUIRED`, stop. Report the exact action and
   obtain a human policy/destructive decision. Never infer consent from
   `--yes`. Formula trust requires the explicit reviewed
   `--trust-formula <name>` option after review.

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
- Components declare platform and Stow mode in their local `AGENT.md`
- XDG-compliant where possible (`dot-config/` maps to `~/.config/`)
- Special packages:
  - `brew/` - Homebrew dependencies
  - `omarchy/` - Hyprland and Omarchy user overrides
  - `scripts/` - Utility scripts

## Testing Changes

- Test stow packages in isolation before committing
- Verify symlinks point to correct locations
- Check that unstowing doesn't break existing configs

## Integration Policy

- After orchestrator review and verification, prepare cohesive commits
- Fast-forward integration into local `main` is permitted
- Never push unless explicitly requested

## Adding New Configurations

1. Create a directory named after the tool
2. Add an `AGENT.md` with one validated `dotfiles-module` declaration
3. Use `dot-` prefix for dotfiles (e.g., `dot-vimrc` → `~/.vimrc`)
4. Document install, update, health, and agent-specific context locally
5. Test with `./dotfiles modules --all` and `./dotfiles plan` first
6. Add any macOS dependencies to `brew/Brewfile` if needed
