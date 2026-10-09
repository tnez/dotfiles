# Yazi component

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow no-folding
-->

## Desired state

The files in this directory are the source of truth for the `yazi`
configuration for macOS and Omarchy. Stow owns only `yazi.toml` and
`keymap.toml`; package inventory, plugins, and other machine-local files remain
unmanaged. No-folding keeps the live directory real so plugin installation
cannot write machine-local state into the repository.

## Operations

- On macOS, install or update configuration with `dotfiles apply` from the
  canonical primary checkout after reviewing `dotfiles plan`.
- On Omarchy, activation is manual and requires explicit approval. Review
  `dotfiles doctor`, `dotfiles plan`, and the package dry run before Stowing;
  see `README.md` for activation and recovery.
- Check platform selection and isolated Stow preservation with
  `bash tests/modules.sh` and `bash tests/portable.sh`.
- Check TOML syntax with Python 3.11+ `tomllib`. After approved activation,
  restart Yazi and manually verify Shift+T maximizes/restores the preview.
  Do not launch a TUI or inject input into an existing owner session.
- Check declaration, target, and link health with `dotfiles doctor` and
  `dotfiles plan`.
- Install or update application binaries through the platform provider; on
  macOS, the declared provider inventory is `brew/Brewfile`.

## Agent guidance

Preserve unmanaged files and machine-local state. Read any colocated README
and inspect the target application’s current configuration before changing
this component. Do not infer consent for destructive migration or package
trust decisions.
