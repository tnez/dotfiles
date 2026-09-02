# Codex component

<!-- dotfiles-module
version 1
platform darwin
stow no-folding
capability codex-seed
-->

## Desired state

The files in this directory are the source of truth for the `codex`
configuration activated with GNU Stow on `darwin` hosts.

## Operations

- Review `dotfiles plan`, then use `dotfiles apply` from the canonical primary
  checkout to restow shared Codex files.
- `codex-seed` copies `config.base.toml` to `~/.codex/config.toml` only when no
  live config exists. `dotfiles doctor` reports whether seeding is needed.
- Install or update Codex through the Darwin provider inventory in
  `brew/Brewfile`.

## Agent guidance

A live `~/.codex/config.toml` is machine state and must be preserved. Change
the base only for future seeds; do not pretend an existing live config is
converged from it or replace it without an explicit migration decision.
