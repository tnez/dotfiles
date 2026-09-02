# Omarchy component

<!-- dotfiles-module
version 1
platform omarchy
stow standard
-->

## Desired state

The files in this directory are the source of truth for the `omarchy`
configuration activated with GNU Stow on `omarchy` hosts.

## Operations

- Check declaration, prerequisite, and target health with `dotfiles doctor`
  and `dotfiles plan`; both are read-only on Omarchy.
- Activation is deliberately manual. After explicit approval, use GNU Stow
  with `--dotfiles --restow omarchy` from the canonical checkout.
- Existing stowed-file edits are already live. Validate Hyprland changes with
  `hyprctl reload` and `hyprctl configerrors`; shell files hot-reload.
- Manage missing software through `omarchy pkg`, never Homebrew.

## Agent guidance

Treat `/usr/share/omarchy/` as read-only packaged state. Preserve unmanaged
files and machine-local state, inspect current user configuration before
changing this component, and use the Omarchy agent skill for end-user desktop
customization. Do not infer consent for activation or destructive migration.
