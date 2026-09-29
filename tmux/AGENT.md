# Tmux component

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow standard
-->

## Desired state

The files in this directory are the source of truth for the `tmux`
configuration for macOS and Omarchy. Keep navigation keys and Neovim
smart-splits support; use native session management and status. No forced shell,
PATH, clipboard executable, workflow popup, or background session creation.
Omarchy activation is manual. Test with `bash tests/portable.sh` and an isolated
`tmux -L` server; never reload the user's server during verification.

## Operations

- Install or update configuration with `dotfiles apply` from the canonical
  primary checkout after reviewing `dotfiles plan`.
- Check declaration, target, and link health with `dotfiles doctor` and
  `dotfiles plan`.
- Install or update application binaries through the platform provider; on
  macOS, the declared provider inventory is `brew/Brewfile`.

## Agent guidance

Preserve unmanaged files and machine-local state. Read any colocated README
and inspect the target application’s current configuration before changing
this component. Do not infer consent for destructive migration or package
trust decisions.
