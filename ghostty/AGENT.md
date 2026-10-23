# Ghostty component

<!-- dotfiles-module
version 1
platform darwin
stow standard
-->

## Desired state

Stow owns `~/.config/ghostty/config` on macOS. Keep JetBrains Mono at 14pt,
zero window padding, and no window decorations. Use TokyoNight Storm when
macOS is dark and Rose Pine Dawn when it is light; Ghostty follows the desktop
appearance automatically through the paired `theme` setting.

This small appearance configuration is intentionally restored after the broad
simplification retirement. It preserves personal preferences without restoring
the retired terminal/workflow integrations. Omarchy is not managed here.

## Operations and health

- Install Ghostty separately; this component does not provision the application.
- Review `./dotfiles doctor` and `./dotfiles plan` before approved activation
  from the canonical primary checkout. An existing link to this package becomes
  valid as soon as its source is restored; no restow is needed in that case.
- Run `bash tests/ghostty.sh` for isolated ownership and Stow checks.
- With Ghostty installed, run `ghostty +validate-config` and
  `ghostty +show-config` to validate the effective configuration, including any
  machine-local overrides. Both named themes must be installed.
- Reload Ghostty's configuration with Cmd+Shift+, after editing. Open a new
  window if decorations do not update; verify light/dark switching manually.
  Disabling decorations also disables native macOS tabs.

## Ownership and recovery

Preserve the regular config at
`~/Library/Application Support/com.mitchellh.ghostty/config`; it is machine-owned
and can override these preferences. Do not adopt, replace, or delete it. Inspect
its relevant settings if effective preferences differ from this package.

To retire this package, inspect exact link ownership and simulate unstow from
its original primary checkout before any approved removal. Retire owned links
before deleting sources; preserve unrelated regular files. See
`docs/retirement.md` for recovery safeguards.
