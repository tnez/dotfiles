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
- `~/.config/hypr/preferences.lua`: natural scrolling for mouse and touchpad.
  This new include is inactive until separately approved loading from the local
  `hyprland.lua`; Stow alone does not load it. Keep device settings local.
- `~/.config/omarchy/preferences.json`: declares only `bar.position = "left"`.
  This is an input to the focused `./omarchy-preferences` runbook, not an Omarchy
  shell config replacement. `shell.json` stays a regular, app-managed file.
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

Leave keyboard layout/repeat, shortcuts, shell/menu code, bar widget layout,
idle policy, and theme sizing to Omarchy unless a new preference is explicitly
approved. Only the two scrolling booleans and bar position are newly declared;
monitor scaling, workspace toggles and all unrelated shell settings stay local.
Do not vendor a stock plugin to change a few keybindings.

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
  directory as the project root and creates one owned tmux session. The `dev`
  window holds Neovim, initially focused. At creation, reserve 120 columns and
  50 rows for editing; choose the agent and shell placements independently:
  - At 201–220 columns, Pi takes the remaining 80–99 columns on the right.
    At 221+ columns, Pi takes 100; below 201 it gets an `agent` window.
  - At 66+ usable rows, create a full-width bottom shell 15 rows high;
    otherwise create a `shell` window. Status rows are not usable rows.
  - All panes/windows start in the chosen directory. Automatic rename is
    disabled locally on the created `dev`, `agent` and `shell` windows.
  Use the unique invoking client's full dimensions inside tmux, not the shell
  pane's dimensions. Outside tmux, read the terminal on stdin with `stty size`;
  missing/invalid size fails before new-session creation. Re-entry needs no new
  size measurement. Preserve the normal tmux window-sizing policy.
- Re-entry resumes a session only when its tmux ownership metadata matches the
  canonical directory. Existing panes/windows are left as-is. Unowned name
  collisions and incomplete sessions are reported, not adopted or repaired.
  Inside tmux, `dev` switches only the unique client displaying the invoking
  pane; it refuses ambiguous or detached-pane targets. No resize watcher,
  layout hook or automatic pane/window migration is installed. Normal tmux
  resizing still operates, but creation sizes are not continually enforced.
  If the layout no longer fits, ask an agent to inspect the terminal/config
  and propose revised defaults. Changing an existing layout requires approval.
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
  Export the exact committed `hud-revision` from a reviewed source checkout
  into an isolated build directory. With its locked dependencies cached, run
  `cargo build --frozen --offline --release --bin hud` there. Record the revision,
  toolchain and artifact checksum privately. Validate the built binary with `--config
  omarchy/dot-config/mux/hud.toml --check-config` from this repository root.
  Installation and live startup require separate approval after doctor/plan;
  verify the installed checksum matches. Do not use a stale debug build.
- Existing stowed-file edits are already live. Validate Hyprland changes with
  `hyprctl reload` and `hyprctl configerrors`; shell files hot-reload.
- Manage missing software through Omarchy, never Homebrew. Selecting `pi` in
  a file does not install it; use Omarchy's default-agent setup if Pi is absent.
- Test package link/unlink isolation with `bash tests/omarchy.sh`; test the
  project launcher with `bash tests/dev.sh` and `python3 tests/dev-layout.py`
  (real pseudo-terminals, private server, inert editor/agent), utility entry with
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
  `dev`. To undo only the adaptive layout policy, restore the reviewed launcher
  revision; an already stowed source is live for subsequent invocations. Do not
  rebuild existing sessions or remove user-created windows as rollback.
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

## Shared desktop preferences: ownership, setup and drift

`~/.config/hypr` and `~/.config/omarchy` are mixed-ownership directories, not
wholesale Stow targets. Stow owns only declared files (and may fold directories
when wholly owned). It does not merge Lua or JSON settings. Never adopt a whole
local file to capture one preference. The runbook lives at repository root so
Stow does not accidentally install it as an unrelated home-directory file.

Inspect from this checkout without mutation:

```sh
./omarchy-preferences plan
./omarchy-preferences check --live
```

`check`/`plan` inspect exact preference link targets, the documented final Lua
include, and the existing shell JSON's `bar.position`. `--live` additionally
queries both effective input options through `hyprctl`; without it, no native
input check is claimed. These checks do not execute local Lua. Static include
recognition is not proof arbitrary local Lua executed it correctly; live option
checks and native smoke are separate evidence. The Lua declaration test ties the
fixed two `true` input checks to the owned source; update both if that policy
changes. Missing activation returns 1 with `PENDING`; verified checks return 0.
Drift, unsafe paths, malformed/duplicate-key JSON and unsupported shell schemas
return 3 with `ACTION_REQUIRED`. Do not infer policy consent from `--yes`.

Run these focused checks during desktop maintenance, after Omarchy updates and
after changing scrolling or bar placement through local tools. Root
`dotfiles doctor`/`plan` still check prerequisites and Stow conflicts; they do
**not** automatically run this preference check or its mutator. No background
watcher, startup reconciliation, new module capability or general config
framework is introduced. On drift, ask whether to update the shared preference
or restore it; do not silently select a winner.

### Activation (separate explicit approval required)

1. Run root doctor/plan and the focused plan. Review current files and exact
   source/target paths. Do not edit the already-live bindings to bypass setup.
2. Stow the two new preference files using the existing approved Omarchy
   procedure. Preserve local `input.lua`, monitor settings, Dottie and shell
   files; unmanaged target conflicts require a decision, not `--adopt`.
3. Back up the unmanaged `hyprland.lua`. After approval, append only this block
   at its end, after local files, toggles and Dottie. If it already has another
   loading arrangement, inspect it rather than appending duplicate loads:

   ```lua
   -- dotfiles desktop preferences (keep last)
   require("hypr.preferences")
   ```

   Keep existing local input declarations intact; these two shared options are
   intentionally the final override. Removing the include exposes the original
   local behavior again. Saving Hyprland config may auto-reload; this edit itself
   requires activation approval, followed by an approved reload/configerrors
   check and native mouse/touchpad smoke. The runbook never edits Lua or reloads.
4. The shell runbook only reconciles an existing version-1 JSON file with a
   recognized `bar.position`. Close settings editors before mutation. If the
   setting matches, approved `./omarchy-preferences apply --yes` is a no-op.
   For reviewed drift, use the additional explicit choice:

   ```sh
   ./omarchy-preferences apply --yes --restore-bar-position
   ```

   Primary-checkout, Omarchy and root doctor/plan gates are enforced. Only the
   position value token changes; other bytes, settings and permission bits are
   preserved. A private `.shell.json.dotfiles-backup-*` is created alongside
   `shell.json` before an atomic replacement. Changed preimages are refused and
   the result is read back. Missing files/keys are not seeded or adopted; unknown
   schemas require review. This does not modify plugins, idle, themes or runtime
   toggles. The shell can hot-reload the JSON write: approval covers that visible
   change even though the runbook issues no explicit reload.
5. Run `check --live`, `hyprctl configerrors`, and the native scrolling/bar
   walkthrough. File checks do not prove shell rendering, device feel or startup
   behavior. Verify the left bar remains usable with normal tiling.

The runbook honors absolute `XDG_CONFIG_HOME`, defaulting to `~/.config`.
Stow's documented home target uses `~/.config`; non-default XDG placement and
Hyprland's corresponding load path require separate review, not guessed links.
No writer can guarantee isolation from an uncooperative application between the
last comparison and replacement. Keep settings writers idle; concurrent changes
are not automatically rolled back. New input/config candidates are not activated
just because their isolated fixtures pass.

### Recovery and verification

- Run `python3 tests/omarchy-preferences.py` for fixture-only preservation,
  explicit restoration, validation/ownership gates, concurrency refusal and
  failure handling. Lua validation uses a stub `hl.config`, not a live reload.
- Run `bash tests/omarchy.sh` and `bash tests/portable.sh` for initial/restow,
  exact-link, unmanaged-conflict and unstow preservation checks, plus root
  lifecycle/module checks as required by `AGENTS.md`.
- To retire scrolling ownership after approval, remove only the documented
  include from the local entrypoint **before** removing the verified preference
  link. Preserve later local edits and all other configuration. Reload and
  verify separately; never leave a required module dangling.
- For bar rollback, inspect the private backup and current JSON, then restore
  only the reviewed prior position. Never copy an old whole-file backup over
  newer shell settings. Backups are recovery artifacts, not Stow sources; do not
  commit them or remove them automatically after a failure.
- Removing the bar declaration link alone does not undo the reconciled local
  value. Do not un-stow the whole Omarchy package, reset runtime state or kill
  applications to roll back these preferences.

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
