# Git component

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow standard
-->

## Desired state

The files in this directory are the source of truth for the `git`
configuration for macOS and Omarchy. Git identity, aliases, and workflow
preferences remain; `less` replaces Hunk. GitHub credentials use `gh` from PATH.
Omarchy Stow is manual after approval. Existing machine Git configuration is a
conflict, not something to overwrite. Test with `bash tests/portable.sh`.

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
