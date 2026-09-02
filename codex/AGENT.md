# Codex component

<!-- dotfiles-module
version 1
platform darwin
stow no-folding
-->

## Desired state

The files in this directory are the source of truth for the `codex`
configuration activated with GNU Stow on `darwin` hosts.

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
