# Tmux component

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow standard
-->

## Desired state

`dot-config/tmux/tmux.conf` is the Stow-owned user entrypoint at
`${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf`. On Linux it first sources
Omarchy's shipped `config/tmux/tmux.conf` from an existing `$OMARCHY_PATH`,
falling back to the legacy `~/.local/share/omarchy` installation and then the
packaged `/usr/share/omarchy` installation. Personal settings apply last.
That shipped file is not modified or Stow-owned here. The exported installation
root must also be visible in the tmux server environment; the packaged fallback
supports fresh servers without it.
Use `C-Space` as the primary prefix and `C-b` as the secondary prefix on both hosts, including clients that intercept Control-Space. Press
`C-b C-b` to send a literal Control-B. Leave terminal and help bindings to each
host; Omarchy also owns its status configuration. The `prefix+-` and `prefix+/`
split aliases intentionally replace tmux's default `delete-buffer` and key-list
bindings. On both hosts, `prefix+v` enters copy mode and `prefix+R` renames the
session. This deliberately replaces Omarchy's `v` split; use `prefix+/` for a
side-by-side split instead. Preserve Omarchy's `C-b` secondary prefix, `h` split,
`r` / `R` renames, terminal and RGB setup, status, help UI, escape time, and
session behavior. The XDG path is user configuration space: Omarchy seeds it
with a copy of its defaults, not an immutable system file. Inspect and preserve
any existing regular user config before replacing it with a reviewed Stow link;
Stow conflicts are a safety boundary, not permission to adopt or overwrite.

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
a confirmation. Both source `${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf`,
replacing the default pane-number display binding on macOS and retaining
Omarchy's mnemonic. The binding handles a nondefault XDG root too. Reloading
on Omarchy loads shipped defaults first and personal bindings last; no reverse
include from the shipped defaults or legacy home config is needed.

On macOS, match stock Omarchy's single-row top status bar: a session badge on
the left, numbered windows, and conditional COPY/PREFIX/ZOOM indicators plus
hostname on the right. Use the terminal's default background/foreground and
ANSI `blue`, `black`, and `brightblack` palette entries, not fixed RGB colors,
plugins, or theme-parsing scripts. The same layout follows each terminal's
palette; identical colors require matching terminal themes. Terminal themes
control contrast, including the black-on-blue badge and muted brightblack text.
Do not change window naming, pane borders, or copy-mode styling as part of this
status-only preference. Omarchy's shipped defaults continue to supply its
status; the personal settings do not override its status configuration. A full
reload reapplies the defaults, so ad-hoc runtime changes are not persisted.

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
prefix+a -> <XDG config>/tmux/agent-popup -> owned dotfiles-agent session -> Pi
                     |                         |
                     +-- popup attach client --+ (detach to hide)
                     +-- refresh origin metadata in session options
```

Stow owns `agent-popup` alongside the XDG `tmux.conf`. Both use
`${XDG_CONFIG_HOME:-$HOME/.config}`. It starts Pi in HOME with the user's normal
model, settings, tools, credentials and trust behavior. No plugin, service, global Pi
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

### Inspect and migrate existing installations

- Run `./dotfiles doctor` and `./dotfiles plan` before proposing activation.
  All link changes and live reloads require approval. Worktree tests do not
  authorize activation; use the canonical primary checkout for installation.
- The old filename was **`~/.tmux.conf`**, installed from `tmux/dot-tmux.conf`.
  Before integrating the source move into a live primary checkout, inspect its
  exact link ownership with `ls -ld` and `readlink`. With approval, retire only
  that verified repo-owned link while the old source still exists. Simulate
  unstowing the old tmux package first; inspect the operations before executing.
  Preserve the old revision for recovery. Never merge the source deletion first
  and leave the live link dangling.
- Inspect both the old path and
  `${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf`, including directory links.
  A regular file, a foreign link or local modifications require a preservation
  decision. Do not use Stow `--adopt` or force replacement. On Omarchy, review
  the existing user file against the shipped defaults, preserve custom settings,
  and remove the obsolete final `source-file ~/.tmux.conf` from the migration
  copy only. Do not add that include to the new entrypoint: it would recurse.
  If custom settings cannot be safely reconciled, stop before activation.
- Omarchy's explicit `omarchy-refresh-config tmux/tmux.conf` replaces the user
  config with a fresh default copy. Do not run it against a Stow-owned link:
  its copy operation can follow the link and overwrite the repository source.
  Review link ownership and backups before any such refresh.

### Install the reviewed package

With the default XDG root, standard repo Stow conventions install both files:

```sh
repo=$(git rev-parse --show-toplevel)
stow --dir="$repo" --target="$HOME" --dotfiles \
  --ignore='^AGENT[.]md$' --simulate tmux
# After reviewing the simulation and obtaining approval:
stow --dir="$repo" --target="$HOME" --dotfiles \
  --ignore='^AGENT[.]md$' tmux
```

The shared lifecycle also targets `$HOME/.config`; it does not relocate packages
for a custom XDG root. For an explicitly configured, absolute
`XDG_CONFIG_HOME` other than `$HOME/.config`, use this package-scoped Stow
invocation instead, after reviewing directory ownership and obtaining approval
to create the target directory:

```sh
repo=$(git rev-parse --show-toplevel)
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p -- "$config_home/tmux"
stow --dir="$repo/tmux/dot-config" --target="$config_home/tmux" \
  --simulate tmux
# After reviewing the simulation and obtaining approval:
stow --dir="$repo/tmux/dot-config" --target="$config_home/tmux" tmux
```

This uses `tmux/dot-config/tmux` as the Stow package and installs its contents
directly into the target tmux directory. Do not also activate the top-level
tmux package into HOME for a custom root. Set the same exported XDG root before
starting new tmux servers; Stow itself does not interpret XDG variables.

### Existing and new servers

Installing links does not reread configuration in an existing server.
Its old `prefix+q` binding may still point at `~/.tmux.conf`. After approved
link migration, explicitly load the new path once from the intended server:

```sh
tmux source-file "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
```

Use an explicit `-S <socket>` when outside that server or when multiple servers
exist. This preserves the server, sessions, windows, panes and the running
concierge, while replacing `prefix+q` with the XDG reload binding. Do not press
the stale reload key between retiring the old link and this one-time reload.
If the existing server has a different XDG environment from the invoking shell,
inspect it with `tmux show-environment -g XDG_CONFIG_HOME` and obtain approval
to reconcile it before reloading: the binding and popup use the server's root.

Fresh tmux servers discover the XDG entrypoint automatically; no `-f`, shell
alias, launcher change, watcher or restart of an existing server is required.
Remove the verified old link during migration rather than depending on the
precedence of multiple user config paths. `#{config_files}` is diagnostic
context, not by itself proof of execution; check loaded options and bindings.
The tests start separate servers with no `-f` and verify actual behavior.

After an approved reload, inspect `tmux list-keys -T prefix`: `q` must source
the XDG entrypoint, `a` must launch the XDG helper, `v` must enter copy mode,
`R` must rename the session, `l` must run `last-window`, and `c` must create
a window in the current pane's directory. Inside copy mode check `v` selection
and `y` copy/exit. On macOS, `h` should be absent; on Omarchy, it should retain
`split-window -v`. On macOS also check top-bar contrast in light/dark themes.
Native Omarchy terminal integration remains a separate host smoke check.

### Other health checks

- Install or update tmux through the platform provider; macOS declares it in
  `brew/Brewfile`.
- For the concierge, check
  `test -x "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/agent-popup"` and
  `command -v pi` in the server environment. Stow must install the helper link
  before reloading the binding. Preserve all Pi settings, credentials and state.
  After approval, summon from two sessions, hide during a response, and confirm
  the same conversation returns. Check `/new`, Escape, modified Enter, resizing
  and contrast with real Pi. Inspect origin metadata without automatically
  capturing pane output.
- For an approved pre-merge preview, use a separate socket/server, temporary
  config and separate history. In only that temporary config, point the popup
  launcher and reload binding at the candidate and preview config respectively.
  The helper launches itself from its invoked path; no home link is needed.
  A separate server is not a filesystem or tool sandbox. Never stop a busy
  preview agent or remove its history without review.
- For an Omarchy `dev` session refit, use `dev resize` or
  [the agent-run runbook](../docs/runbooks/dev-layout.md). This changes verified
  `dev-*` pane layouts, not tmux configuration; `--check` previews.
- Run `bash tests/tmux.sh`, `bash tests/portable.sh`,
  `bash tests/lifecycle.sh`, and `python3 tests/tmux-navigation.py`
  (installed smart-splits required). Run the popup suite in all XDG modes:

  ```sh
  python3 tests/tmux-agent-popup.py
  TMUX_TEST_XDG=empty python3 tests/tmux-agent-popup.py
  TMUX_TEST_XDG=1 python3 tests/tmux-agent-popup.py
  ```

  These use disposable homes, real tmux/PTY keypresses and fake Pi, including
  no-`-f` discovery, real reload keys, Stow/restow/unstow, unmanaged conflicts,
  explicit Omarchy installation roots (including spaces), legacy fallback,
  persistence, metadata and failures. They do not prove real model behavior
  or native Omarchy behavior. Never use the user's server as a test fixture.

## Recovery

To roll back this path migration, obtain approval, simulate and remove only the
new owned links using the same Stow root/target used to install them, restore the
old source revision, and restow its verified legacy links from the primary
checkout. Restore any preserved regular user config from its reviewed backup;
never replace unrelated settings or runtime state. Explicitly source the restored
entrypoint once in the existing server to restore its reload binding. Do not
restart the server or stop the concierge. Keep both source revisions available
until native activation checks pass.

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
On Omarchy, restore reviewed user settings or the shipped defaults instead;
the personal status block applies only to macOS.

When retiring this package on Omarchy, preserve a reviewed regular user config
to restore after unstowing; there is no final legacy include to remove from the
new entrypoint. Restore its `v` split in the running server with approval,
without restarting sessions:

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

Then remove only verified package links from the primary checkout using the
same Stow options and `--delete`, and restore the reviewed user config. Do not
kill sessions, delete unrelated configuration, or leave a missing entrypoint.

To roll back the earlier `h/R/v` changes on macOS, restore the previous source
bindings and reload after approval. Restoring `h` explicitly rebinds it; `R`
becomes reload again. To roll back only the macOS `q` reload binding, remove it
from the source and, with approval, run `tmux bind-key q display-panes` to
restore the default in an existing server. On Omarchy, restore the reviewed
user entrypoint and its reload binding; the shipped default assumes
`~/.config`, so retain the custom XDG target if applicable. Preserve all
unrelated settings.

To roll back only the later copy/window consistency changes on macOS, restore
its prior `prefix+l` next-window and `prefix+c` default new-window bindings,
copy-mode `v` rectangle-toggle, and unbound copy-mode `y`. Revert the declarations
and restore those live bindings only after approval; removing source lines alone
does not clear them. Omarchy's stock copy/window bindings already match these
shared preferences and need no rollback for this slice.

## Agent guidance

Preserve unmanaged files and machine-local state. Read the live user tmux
config before migration. The XDG user path may be Stow-owned after review;
Omarchy's shipped defaults remain externally owned. Never silently replace a
regular file or foreign link, rebind an unreviewed local key, alter host
terminal/status preferences, or reload a live server without explicit approval.
