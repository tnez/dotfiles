# Launchagents component

<!-- dotfiles-module
version 1
platform darwin
stow standard
capability launchd-environment
-->

## Desired state

The files in this directory are the source of truth for the `launchagents`
configuration activated with GNU Stow on `darwin` hosts.

## Operations

- Review `dotfiles plan`, then use `dotfiles apply` from the canonical primary
  checkout to restow and reload managed LaunchAgents.
- `launchd-environment` loads `com.tnez.launchd-environment` and publishes the
  selected profile variables to GUI applications.
- Check loaded state with `dotfiles doctor`. Existing GUI applications must be
  restarted after environment changes so they inherit the new values.

## Agent guidance

This component is Darwin-only. Preserve unrelated user LaunchAgents. Treat
service loading as mutation, and inspect absolute paths in plist files before
assuming they are portable to a new macOS account or architecture.
