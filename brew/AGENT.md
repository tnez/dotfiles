# Homebrew component

<!-- dotfiles-module
version 1
platform darwin
stow none
capability homebrew
-->

## Desired state

`Brewfile` is the declarative inventory of macOS formulae, casks, and taps.
`trusted-formulae` is the narrower reviewed allowlist for formulae
that Homebrew requires the user to trust explicitly.

## Operations

- Install missing dependencies with `dotfiles provision`; this suppresses
  automatic metadata updates and does not upgrade installed dependencies.
- Update Homebrew metadata and declared dependencies only with the explicit,
  slow `dotfiles upgrade` operation.
- Check inventory convergence with `dotfiles doctor` or
  `brew bundle check --file=brew/Brewfile`.
- Add dependencies deliberately to `Brewfile`; do not derive or snapshot all
  software installed on one machine.

Mise replaces fnm/pyenv shell integration. Project versions belong in project
`mise.toml` files, not this Brewfile. Other unreviewed language/package entries
remain pending dependency review (especially Neovim); their presence is not a
recommendation to bypass mise for new projects. Provision no longer downloads
agents or installs GitHub extensions. It never uninstalls retired applications.

## Agent guidance

Never treat generic `--yes` as third-party formula trust. If the lifecycle
emits `ACTION_REQUIRED`, review the exact formula and obtain a human policy
decision before using `--trust-formula`. Homebrew is a Darwin provider, not the
package manager for Omarchy.
