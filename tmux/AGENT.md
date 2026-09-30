# Tmux component

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow standard
-->

## Desired state

`dot-tmux.conf` is an additive overlay loaded alongside the host's
configuration. Use `C-Space` as the primary prefix, but leave `prefix2`, terminal,
status, and help bindings to each host. The `prefix+-` and `prefix+/` split
aliases intentionally replace tmux's default `delete-buffer` and key-list
bindings. On Omarchy preserve its `C-b` secondary prefix, `h` / `v` splits,
`r` / `R` renames, terminal and RGB setup, status, help UI, escape time, and
session behavior. Do not remove or rewrite `~/.config/tmux/tmux.conf`.

On macOS, retain the existing `h` / `l` window navigation, `v` copy-mode, `R`
reload, session behavior, low escape-time, RGB override, and Neovim smart-splits
bindings. The Darwin-only block prevents these from overriding Omarchy. Its
LazyVim owns `C-h/j/k/l`; do not intercept those keys there. Omarchy keeps its
native Control-Alt arrow pane navigation. This overlay has no custom popups,
helper scripts, forced shell or PATH, clipboard commands, or session creation.

## Operations

- Inspect `./dotfiles doctor` and `./dotfiles plan` before activation. On macOS,
  this package participates in standard Stow activation; Omarchy activation is
  manual and requires approval.
- From the canonical primary checkout, Stow only this package after review:

  ```sh
  repo=$(git rev-parse --show-toplevel)
  stow --dir="$repo" --target="$HOME" --dotfiles \
    --ignore='^AGENT[.]md$' tmux
  tmux source-file "$HOME/.tmux.conf"
  ```

- The source command reloads the additive overlay into the current server without
  restarting sessions. It must not change Omarchy's `C-b` prefix, terminal/RGB,
  escape/session options, status, help UI, or `h/v`, `r/R` bindings. A new server
  loads both user config files automatically.
- Check link health with `./dotfiles doctor` and `./dotfiles plan`.
- Install or update tmux through the platform provider; on macOS, it is declared
  in `brew/Brewfile`.
- Test with `bash tests/tmux.sh` and `bash tests/portable.sh`; use an isolated
  `tmux -L` server for config checks, never the user's server during tests.

## Recovery

For the Omarchy overlay, restore the two tmux defaults in a running server
before unstowing it:

```sh
tmux bind-key -T prefix - delete-buffer
tmux bind-key -T prefix / command-prompt -k -p key 'list-keys -1N "%%"'
```

Then delete only the package link from the primary checkout using the same
Stow options and `--delete`. Do not kill sessions or remove Omarchy's XDG config.

## Agent guidance

Preserve unmanaged files and machine-local state. Read the live host tmux config
before changing the overlay. Never silently rebind a host-owned key, alter
terminal/status settings, or reload a live server without explicit approval.
