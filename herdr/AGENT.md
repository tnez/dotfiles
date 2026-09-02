# Herdr component

<!-- dotfiles-module
version 1
platform darwin
stow standard
capability herdr
-->

## Desired state

The files in this directory are the source of truth for the `herdr`
configuration activated with GNU Stow on `darwin` hosts.

## Operations

- Review `dotfiles plan`, then use `dotfiles apply` from the canonical primary
  checkout to restow configuration and converge the Herdr integration.
- `herdr` starts or restarts the Homebrew service as needed, installs the
  pinned navigation plugin, installs integrations for available agents, and
  reloads server configuration.
- Check service and integration state with `herdr status server` and
  `herdr integration status`; install the binary through `brew/Brewfile`.

## Agent guidance

Treat service restart and plugin installation as mutation even when config
links are already current. Preserve Herdr runtime state and inspect the pinned
plugin change before updating its commit.
