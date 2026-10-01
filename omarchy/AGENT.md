# Omarchy component

<!-- dotfiles-module
version 1
platform omarchy
stow standard
-->

## Desired state

Own only these preference files and focused entry commands:

- `~/.config/hypr/bindings.lua`: Caps Lock/Ctrl swap. Use this existing
  entrypoint so we do not take ownership of machine-local `input.lua`.
- `~/.config/omarchy/defaults/agent`: `pi`.
- `~/.config/nvim/lua/plugins/smart-splits.lua`: normal-mode `Ctrl+h/j/k/l`
  navigation across LazyVim splits and tmux panes, paired with the tmux package.
  Load smart-splits eagerly so it marks Neovim panes before navigation. Keep
  wrapping at outer edges, matching macOS. No resizing overrides on Omarchy.
- `~/.local/bin/dev`: start or resume the project layout from the current
  directory. The command does not inspect Git or create branches/worktrees.
- `~/.local/bin/mux`: explicitly ensure independent HUD/cliamp sessions and
  enter the most recently attached non-utility session. Plain tmux stays vanilla.
- `~/.config/mux/hud.toml` and `hud-revision`: reviewed placeholder dashboard and
  pinned local HUD revision. The binary is installed only through a separately
  approved step; entry never installs, builds or updates software.

Preserve LazyVim's other plugins, theme, clipboard, and machine-local lockfile.
This one plugin spec does not activate the macOS-only standalone nvim package.

Leave keyboard layout/repeat, shortcuts, shell/menu code, bar layout, idle
policy, and theme sizing to Omarchy unless a new preference is explicitly
approved. Do not vendor a stock plugin to change a few keybindings.

Dottie Terminal, its transport, and `~/.agents/skills/dottie` belong to the
separate Dottie project. This package must neither install nor remove them.
Machine-local integration can load `require("hypr.dottie")` from the user's
`hyprland.lua`; it must not depend on our managed `bindings.lua`.

## Operations

- Check declaration, prerequisite, and target health with `dotfiles doctor`
  and `dotfiles plan`; both are read-only on Omarchy.
- Activation is deliberately manual. After explicit approval, use GNU Stow
  with `--dotfiles --restow omarchy` from the canonical checkout.
- Run `dev` from the chosen project directory. It treats the physical current
  directory as the project root and creates one owned tmux session with a
  `dev` window: Neovim left, Pi right, and a shell across the bottom. The
  editor is initially focused; its window-local automatic rename is disabled.
- Re-entry resumes a session only when its tmux ownership metadata matches the
  canonical directory. Existing panes/windows are left as-is. Unowned name
  collisions and incomplete sessions are reported, not adopted or repaired.
  Inside tmux, `dev` switches only the unique client displaying the invoking
  pane; it refuses ambiguous or detached-pane targets.
- Pi receives a one-shot context note. The launcher does not search for or
  configure the tnezdev knowledge base; its normal root environment variable
  must be configured separately for Pi to read that guidance.
- `dev` does not run repository startup scripts or Git/worktree operations.
  Project instructions and user guidance remain conditional on the project and
  task; no project-specific settings table is created.
- `mux` is Omarchy-only and manages only the normal `/tmp/tmux-$UID/default`
  server. Custom sockets/TMUX_TMPDIR are refused; use plain tmux for tests.
  It does not change `t`, `dev`, tmux config, shell startup or client hooks.
- `mux --check` is read-only: inspect owned sessions and missing-session
  prerequisites. It returns nonzero for missing/incomplete sessions, conflicts
  or missing inputs. Presence is not proof of application health. For approved
  restoration of missing sessions, run `mux`; no reset/respawn mode exists.
- Utilities run in `$HOME`. Entry serializes creation, respects ownership even
  after session renames and refuses collisions/incomplete/dead-pane states.
  Existing processes, playback, panes and windows are not reset. If an app exits
  and its session disappears, only a later entry recreates it. No supervisor.
- Entry chooses greatest `session_last_attached` among non-utilities; ties use
  the lowest numeric session ID. With none, it creates `Work` (or a free numbered
  suffix) as a shell in the invoking directory. Inside tmux only the unique
  client displaying the invoking pane is switched; ambiguity fails before entry.
- Music input/profile ownership is in `cliamp/AGENT.md`, not this package.
  The dedicated writable profile must be explicitly set up before first entry.
  HUD's pinned executable is expected at
  `$XDG_DATA_HOME/dotfiles/hud/<hud-revision>/hud` (fallback `~/.local/share`).
  See `docs/plans/2026-09-30-minipc-workflow.md` for build/verification evidence
  and the separate installation/activation gates. Do not use a stale debug build.
- Existing stowed-file edits are already live. Validate Hyprland changes with
  `hyprctl reload` and `hyprctl configerrors`; shell files hot-reload.
- Manage missing software through Omarchy, never Homebrew. Selecting `pi` in
  a file does not install it; use Omarchy's default-agent setup if Pi is absent.
- Test package link/unlink isolation with `bash tests/omarchy.sh`; test the
  project launcher with `bash tests/dev.sh`, utility entry with
  `bash tests/mux.sh`, and profile preservation with
  `python3 tests/cliamp-profile.py`. These use inert fake players, not live
  dashboards/audio. Test navigation bindings with
  `bash tests/tmux.sh`. Run `python3 tests/tmux-navigation.py`
  with an installed plugin (or `SMART_SPLITS_PATH` pointing to a reviewed
  checkout) for native editor split movement, tmux boundary crossing, and exit
  marker cleanup. This uses a disposable home/server, not the live desktop.
  Separately check that the mappings survive full LazyVim startup.
- For navigation activation, install only `smart-splits.nvim` through Lazy,
  restart Neovim, then source the tmux overlay. Do not update all plugins.
  Existing Neovim processes need restarting to acquire the pane marker.
- Launcher rollback: verify `~/.local/bin/dev` points to this package, then
  remove only that symlink; do not un-stow the whole Omarchy package just to
  remove the command. This does not kill or alter tmux sessions created by
  `dev`.
- Utility-entry rollback: remove only verified new `mux` and HUD-input links.
  Stow may fold `~/.config/mux` into one directory symlink: remove that verified
  link, never files through it. If it is a real directory, remove only verified
  leaf links and preserve unrelated contents. Do not un-stow all Omarchy
  preferences or kill sessions. Preserve the separate cliamp profile and its
  local state; removal needs an explicit later decision.
- Navigation rollback: remove the four `C-h/j/k/l` root bindings from the tmux
  source, unbind them in the running server, then remove only the owned
  `smart-splits.lua` link and restart Neovim. Keep the other Omarchy preferences
  and local LazyVim files; Lazy can clean up the unused plugin separately.

## First installation

Install Omarchy normally before activating this package. Fresh homes are
seeded with shipped configs through `/etc/skel`; dotfiles is a separate,
explicit personalization step, not part of the OS installer.

1. Ensure GNU Stow and Pi are available.
2. Run `dotfiles doctor` and `dotfiles plan` from the canonical checkout.
3. Inspect and back up existing files at the managed paths. Stock
   `bindings.lua` may be an unmanaged regular file. Move it aside only after
   approval; preserve any unrelated customizations in machine-local config.
   Never use `--adopt` or overwrite conflicts blindly.
4. With approval, run Stow from the canonical checkout:

   ```sh
   stow --dir="/absolute/path/to/your/dotfiles" --target="$HOME" \
     --dotfiles --ignore='^AGENT\.md$' --restow omarchy
   ```

5. Run `hyprctl reload`, `hyprctl configerrors`, and `dotfiles doctor`.
   Restart Neovim so Lazy loads smart-splits; verify pane navigation in all four
   directions, then check `hyprctl getoption input:kb_options` and
   `omarchy default agent`.

## Updates and hooks

No post-install, post-boot, or post-update hook is required. Hyprland loads
packaged defaults before these user overrides. The stock menu stays owned by
Omarchy and receives its fixes without maintaining a fork.

The installed `omarchy update` runs system-package updates, migrations, then
`post-update` hooks (before AUR/mise updates). Do not use that hook to force
restow, copy old configs back, or reset the shell: that can undo migrations.

After updates, inspect `git diff`, `dotfiles doctor`, and `dotfiles plan`.
Migrations can replace symlinks with regular files or change their contents;
review and reconcile rather than force activation. Explicit refresh/reset
commands may write through a symlink into this repository. Back up first and
never assume a refresh is read-only or safe for managed paths.

## Retiring the previous setup on another machine

This is a one-time, approved migration, not an update hook:

- Back up the working tree, live configs, and local Dottie integration before
  changing anything. Existing uncommitted experiments must be recoverable.
- Before replacing `bindings.lua`, move any Dottie load statement into the
  machine-local `hyprland.lua`. Preserve the Dottie module, CLI, and skill.
- Verify ownership of the old `shell.json`, `shell.toml`, and `tnez.menu`
  links. Remove only links pointing into this package. Do not follow them
  while resetting configs or leave dangling links after deleting sources.
- Restore `~/.config/omarchy/shell.json` as a regular copy of the currently
  shipped `/usr/share/omarchy/config/omarchy/shell.json`. Remove the owned
  font-size override and menu-clone link. Preserve other installed plugins.
- Reload/validate Hyprland and rescan shell plugins. Confirm the stock menu,
  the two retained preferences, and existing Dottie bindings still work.
- Unstowing later removes our preferences, not Omarchy's defaults. Hyprland
  still requires its user entrypoint; restore a stock regular `bindings.lua`
  before reloading after an intentional uninstall.

## Agent guidance

Treat `/usr/share/omarchy/` as read-only packaged state. Preserve unmanaged
files and machine-local state, inspect current user configuration before
changing this component, and use the Omarchy agent skill for end-user desktop
customization. Do not infer consent for activation or destructive migration.
