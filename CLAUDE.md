# DOTFILES REFERENCE

## Setup Commands
- `./bootstrap.sh` - Initial setup of dotfiles
- `stow --dotfiles <package>` - Symlink specific config package to ~
  - Uses `dot-` prefix convention (e.g., `dot-config` → `.config`)
- `brew bundle --file=brew/Brewfile` - Install dependencies from Brewfile

## Code Style Guidelines
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

## Git Practices
- Default branch: `main`
- Pull with rebase (`git pull --rebase`)
- Use `--force-with-lease` for safety
- Conflict style: `diff3`

## Repository Structure
- Organized by tool/application
- Each directory = stow package
- XDG-compliant where possible