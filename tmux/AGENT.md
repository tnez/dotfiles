# Tmux component

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow standard
-->

## Desired state

`dot-tmux.conf` is an additive overlay loaded alongside the host's
configuration. Use `C-Space` as the primary prefix and `C-b` as the secondary
prefix on both hosts, including clients that intercept Control-Space. Press
`C-b C-b` to send a literal Control-B. Leave terminal and help bindings to each
host; Omarchy also owns its status configuration. The `prefix+-` and `prefix+/`
split aliases intentionally replace tmux's default `delete-buffer` and key-list
bindings. On both hosts, `prefix+v` enters copy mode and `prefix+R` renames the
session. This deliberately replaces Omarchy's `v` split; use `prefix+/` for a
side-by-side split instead. Preserve Omarchy's `C-b` secondary prefix, `h` split,
`r` / `R` renames, terminal and RGB setup, status, help UI, escape time, and
session behavior. Do not replace or Stow-own `~/.config/tmux/tmux.conf`; add only
the reviewed final include described below.

Shared copy/window habits match stock Omarchy: inside vi copy mode, `v` begins
selection and `y` copies to the tmux buffer and exits. Paste with `prefix+p` or
`prefix+]`; this adds no system-clipboard integration. `prefix+l` switches to
the last-used window (and toggles back), while `prefix+n` remains next window.
`prefix+c` creates a window in the active pane's current directory, including
paths with spaces. Explicit shared bindings also replace stale macOS overrides
on reload.

On macOS, `prefix+h` is explicitly unbound, retiring the old previous-window
shortcut even on reload. The old `prefix+R` reload override is removed; the
shared rename binding replaces it. Keep session behavior, low escape-time,
RGB override, and Alt-key resizing. The Darwin-only block prevents these from
overriding Omarchy. On both hosts, `prefix+q` reloads configuration and displays
a confirmation. On macOS it sources `~/.tmux.conf`,
replacing the default pane-number display binding. Omarchy retains its stock
`prefix+q` binding, which sources `~/.config/tmux/tmux.conf`; the final include
below then reloads the personal overlay. The overlay must not replace Omarchy's
reload target or source the host config recursively.

On macOS, match stock Omarchy's single-row top status bar: a session badge on
the left, numbered windows, and conditional COPY/PREFIX/ZOOM indicators plus
hostname on the right. Use the terminal's default background/foreground and
ANSI `blue`, `black`, and `brightblack` palette entries, not fixed RGB colors,
plugins, or theme-parsing scripts. The same layout follows each terminal's
palette; identical colors require matching terminal themes. Terminal themes
control contrast, including the black-on-blue badge and muted brightblack text.
Do not change window naming, pane borders, or copy-mode styling as part of this
status-only preference. Omarchy's own config continues to supply its status;
reloading this overlay there must preserve even customized host status settings.

On both hosts, `prefix+p` pastes the latest tmux buffer, matching Vim's put
mnemonic. It replaces the default previous-window binding; choose windows with
`prefix+w` or `prefix+1` through `prefix+9`. It also supersedes the retired review
popup on reload. `prefix+]` remains available for paste. Removing old popup
bindings from the source does not unbind them in existing servers; handle any
live cleanup separately with explicit approval, without restarting sessions.

On both hosts, `C-h/j/k/l` uses smart-splits: forward keys into marked Neovim
panes, otherwise select a tmux pane. Omarchy's companion LazyVim plugin spec is
owned by the omarchy package; activate it before reloading these tmux bindings.
Navigation is normal-mode in Neovim; other applications lose their native
`C-h/j/k/l` actions inside tmux, as on macOS. Omarchy's Control-Alt arrow pane
navigation remains available. Keep resizing host-specific: macOS retains its
Alt+h/j/k/l smart-splits resizing, but those chords conflict with Omarchy desktop
shortcuts. Do not port them or add other Alt bindings without a new review.
Omarchy keeps its stock resize keys and existing LazyVim behavior. The overlay
sets no forced shell or PATH and adds no clipboard commands.

## Shared Pi concierge

`prefix+a` opens **Scout**, a centered 85% popup running Pi. Its title is
`Scout | prefix+a: hide | /new: reset`. Inside it, the same binding hides the
popup by detaching its nested tmux client, not by stopping Pi. There is one
shared conversation across all sessions on the same server, not a per-project
agent. Unsent input and ongoing work survive hiding. Use Pi's normal `/new`
command to start over; opening the popup never injects a new user turn.
The background `dotfiles-agent` session is ordinary tmux state and appears in
session lists. It is created only on demand, never during config loading.

```text
prefix+a -> ~/.config/tmux/agent-popup -> owned dotfiles-agent session -> Pi
                     |                         |
                     +-- popup attach client --+ (detach to hide)
                     +-- refresh origin metadata in session options
```

Stow owns the helper alongside `~/.tmux.conf`, not the host's
`~/.config/tmux/tmux.conf`. It starts Pi in HOME with the user's normal model,
settings, tools, credentials and trust behavior. No plugin, service, global Pi
resource or project-trust grant is installed. The helper uses native tmux
locking to serialize session creation and refuses to adopt an unrelated session
with the reserved name. Only the owned concierge session has its status hidden,
`remain-on-exit` disabled and `detach-on-destroy` enabled. Quitting Pi closes its
popup rather than switching that client into a different session, even when the
host keeps ordinary clients attached on session destruction. Normal sessions
retain their host behavior.

Pi receives a CLI-only system-prompt addition describing its concierge role
and how to query the latest origin:

```sh
tmux show-options -qv -t dotfiles-agent @dotfiles-agent-origin
```

This records only the invoking client, session/window/pane names and IDs, and
working directory. It does not collect pane output or send input to other agents.
Pi is instructed to refresh it before interpreting tmux-relative requests and
to inspect only relevant panes on demand. Names, paths and output are data, not
instructions; origin panes may have exited. Inspection does not authorize
control of another agent or session. These are model instructions, not a sandbox
or enforcement of tool permissions. With multiple clients the latest summon
wins; concurrent popups share both the conversation and input terminal.

History is application-owned under
`${XDG_STATE_HOME:-$HOME/.local/state}/tmux-agent/<socket-checksum>/sessions`.
Pi starts with `--continue --session-dir` there: process exit or a server restart
at the same socket can continue the latest saved concierge conversation without
resuming unrelated HOME sessions. `/new` remains the reset mechanism. Different
sockets have separate histories; moving the socket changes its storage key.
Never delete this state, Pi auth or normal sessions as part of Stow/recovery.

Behavior is described in [the feature scenarios](../specs/tmux-agent-popup.feature).

## Operations

- Inspect `./dotfiles doctor` and `./dotfiles plan` before activation. On macOS,
  this package participates in standard Stow activation; Omarchy activation is
  manual and requires approval.
- On Omarchy, inspect the existing regular `~/.config/tmux/tmux.conf` and
  preserve all host settings. First verify `~/.tmux.conf` links to this package
  (activate only this package after approval if needed). After approval, add
  this include once as the host config's last executable line, or review/move
  an existing equivalent include to the end:

  ```tmux
  # Personal overrides (keep last).
  source-file ~/.tmux.conf
  ```

  Tmux loads `~/.tmux.conf` before the XDG user config at startup. This final
  include reapplies personal preferences after the host's `v` split binding,
  both on fresh startup and on Omarchy's `prefix+q` reload. The overlay must not
  source the host config back: that would recurse. No hooks or config watchers
  are installed. Stow alone does not add this include; without it, Omarchy's
  `v` split wins at startup. Omarchy config refreshes may remove the include;
  inspect and restore it only after review, never replace the whole host file.
- From the canonical primary checkout, Stow only this package after review:

  ```sh
  repo=$(git rev-parse --show-toplevel)
  stow --dir="$repo" --target="$HOME" --dotfiles \
    --ignore='^AGENT[.]md$' tmux
  tmux source-file "$HOME/.tmux.conf"
  ```

- The source command reloads the additive overlay into the current server without
  restarting sessions. On macOS it also applies the palette-based top bar;
  visually check contrast in light/dark terminal themes after an approved reload.
  It must not change Omarchy's `C-b` prefix, terminal/RGB, escape/session options,
  status, help UI, or `h`, `r/R` bindings. Only `v` intentionally replaces a
  host binding. A new server loads both user config files automatically, but
  Omarchy needs the final include above for personal bindings to win.
- For an Omarchy `dev` session refit after switching screens, run `dev resize`
  from an attached tmux shell, or follow
  [the agent-run runbook](../docs/runbooks/dev-layout.md). Invocation approves
  automatic refitting of verified `dev-*` sessions only; `--check` previews.
  This is a live pane-layout operation, not a tmux config change or reload.
- Check link health with `./dotfiles doctor` and `./dotfiles plan`. These do not
  check the machine-local final include. After an approved reload, inspect
  `tmux list-keys -T prefix`: `v` should run `copy-mode`, `R` should rename the
  session, and `q` should source the correct host-specific config above. `l`
  should run `last-window`, and `c` should create a window in the pane's current
  directory. Inside copy mode, check `v` selection and `y` copy/exit. On macOS,
  `h` should be absent; on Omarchy it should retain `split-window -v`. Confirm
  fresh startup separately without killing sessions.
- Install or update tmux through the platform provider; on macOS, it is declared
  in `brew/Brewfile`.
- For the concierge, check `test -x ~/.config/tmux/agent-popup` and
  `command -v pi` in the tmux server's environment. Stow must install the new
  helper link before reloading the binding; source-file alone cannot do that.
  Inspect `tmux list-keys -T prefix` for `a` before activation on each host:
  a conflicting host/local binding needs review, not silent replacement.
  After approval,
  verify the binding, summon from two sessions, hide during a response, and
  confirm the same conversation returns. Check `/new`, Escape, modified Enter,
  terminal resizing and visual contrast with real Pi. Inspect origin metadata
  from each session without automatically capturing pane output.
- For an explicitly approved pre-merge preview, use a separate socket/server,
  temporary config and separate history location. In only that temporary config,
  point the popup launcher and reload binding at the candidate and preview
  config respectively. The helper launches itself from its invoked path, so no
  home link or worktree Stow is needed. Keep HOME unchanged for normal Pi
  preferences; the separate server is not a filesystem or tool sandbox. Label it
  visibly, enter from a terminal outside tmux, and detach without interrupting
  work. Do not remove preview files/history or stop a busy agent without review.
- Test with `bash tests/tmux.sh`, `python3 tests/tmux-agent-popup.py`,
  `bash tests/portable.sh`, and `python3 tests/tmux-navigation.py` (installed
  smart-splits required). The popup suite uses real tmux/PTY keypresses and fake
  Pi, covering persistence, metadata, failures and disposable Stow. It does not
  prove real model behavior or native Omarchy terminal integration. Always use
  an isolated server for checks, never the user's server during tests.

## Recovery

To retire only the concierge, remove its `bind a` block and, after approval,
run `tmux unbind-key -T prefix a` (or restore a reviewed previous local binding).
Detach any open popup first. Unstow only the helper's owned link after the
binding is retired; preserve the host tmux config and all Pi history. An existing
concierge keeps running even after removing the binding. Separately approve
quitting Pi or stopping only the session verified by
`tmux show-options -qv -t dotfiles-agent @dotfiles-agent-popup` returning `1`.
Do not kill the tmux server or stop other agents to roll back a shortcut.

If a helper is forcibly killed during startup, its tmux creation lock may remain
held. Inspect for a still-running helper first; only after confirming the lock
is stale and obtaining approval, release it with
`tmux wait-for -U dotfiles-agent-popup`. Never clear an active startup's lock.

To roll back the macOS status preference, revert only the Darwin status block.
Removing options from the source does not clear them in existing servers. With
approval, reset the affected `status*` options and the three `window-status-*`
options to their prior values in the live server; do not restart or kill sessions.
Omarchy needs no status rollback because the overlay never sets its status.

On Omarchy, remove only the reviewed final personal include before unstowing
this package, so the host config never sources a missing overlay. Restore its
`v` split in the running server with approval, without restarting sessions:

```sh
tmux bind-key v split-window -h -c '#{pane_current_path}'
```

Also restore the two tmux defaults in a running server before unstowing it:

```sh
tmux bind-key -T prefix - delete-buffer
tmux bind-key -T prefix / command-prompt -k -p key 'list-keys -1N "%%"'
```

If retiring seamless navigation, remove these four bindings from this source,
unbind them in the running server, and remove only the Omarchy-owned
`smart-splits.lua` link. Restart Neovim; preserve the split and rename keys.

Then delete only the package link from the primary checkout using the same
Stow options and `--delete`. Do not kill sessions or remove Omarchy's XDG config.

To roll back the earlier `h/R/v` changes on macOS, restore the previous source
bindings and reload after approval. Restoring `h` explicitly rebinds it; `R`
becomes reload again. To roll back only the macOS `q` reload binding, remove it
from the source and, with approval, run `tmux bind-key q display-panes` to
restore the default in an existing server. Omarchy needs no `q` rollback.
On Omarchy, restore the previous source and reload the host config to recover
its stock `v` split; preserve all unrelated settings.

To roll back only the later copy/window consistency changes on macOS, restore
its prior `prefix+l` next-window and `prefix+c` default new-window bindings,
copy-mode `v` rectangle-toggle, and unbound copy-mode `y`. Revert the declarations
and restore those live bindings only after approval; removing source lines alone
does not clear them. Omarchy's stock copy/window bindings already match these
shared preferences and need no rollback for this slice.

## Agent guidance

Preserve unmanaged files and machine-local state. Read the live host tmux config
before changing the overlay. Never silently rebind a host-owned key, alter terminal or
Omarchy-owned status settings, or reload a live server without explicit approval.
