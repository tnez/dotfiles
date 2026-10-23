# Nvim component

<!-- dotfiles-module
version 1
platform darwin
stow standard
-->

## Desired state

The files in this directory are the source of truth for the `nvim`
configuration activated with GNU Stow on `darwin` hosts.

## Operations

- Install or update configuration with `dotfiles apply` from the canonical
  primary checkout after reviewing `dotfiles plan`.
- Check declaration, target, and link health with `dotfiles doctor` and
  `dotfiles plan`.
- Install or update application binaries through the platform provider; on
  macOS, the declared provider inventory is `brew/Brewfile`.

## Review workflow and verification

See `README.md` for Diffview keys, the explicit three-dot PR range, portable
terminal launch, and the boundary between local Git and GitHub reviews.
Run `python3 tests/nvim-diffview.py` for changes to that workflow; it requires
installed Diffview and Lazy checkouts (or the documented path overrides) and
uses only disposable repositories/config state. Also run the read-only doctor
and plan checks above. Keep the existing Gitsigns mappings and avoid adding
GitHub authentication, automatic fetches, or tmux session policy to local review.

## Agent guidance

Preserve unmanaged files and machine-local state. Read any colocated README
and inspect the target application’s current configuration before changing
this component. Do not infer consent for destructive migration or package
trust decisions.
