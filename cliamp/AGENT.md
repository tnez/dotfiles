# cliamp component

<!-- dotfiles-module
version 1
platform omarchy
stow none
-->

## Scope and ownership

Own only the declared `mux` music profile, not the user's general cliamp setup.
`omarchy/dot-local/bin/mux` owns tmux entry; music inputs and the focused profile
runbook belong here. macOS, account integration and general cliamp preferences
are out of scope. No lifecycle capability automatically runs this runbook.

cliamp 2.0.1 selects a separate config directory with `CLIAMP_CONFIG_DIR`; profiles
do not inherit settings. The utility uses
`$XDG_CONFIG_HOME/cliamp/profiles/mux` (fallback `~/.config/cliamp/profiles/mux`).
That directory holds writable config, playlists, history, resume state and IPC.
It does not share the general profile's socket, credentials, theme or EQ.

- `mux/config.toml` is a seed, **not a whole-file Stow source**. Own only its
  declared settings: `auto_play = false`, `provider = "radio"`, and
  `ytmusic.enabled = false`. The last disables built-in OAuth fallbacks too.
- `mux/work.toml` declares three fixed presets in order: Ambient/Drone Zone,
  Electronic/Groove Salad, Atmospheric/Synphaera. Native named TOML playlists
  explicitly mark live streams `realtime = true`; they avoid positional-file
  resume behavior. Jazz, Minimal and Lo-fi remain deferred, not empty entries.
- `mux-profile` seeds a missing profile with regular writable files and a small
  ownership marker. It never adopts an existing directory or resets a modified
  config. Repeat setup verifies and leaves it untouched. Playlist or owned-setting
  drift emits `ACTION_REQUIRED`: ask whether to update the shared declaration or
  restore the preference. `--yes` never resolves that decision automatically.
- cliamp may add local theme/EQ/volume settings. Preserve these and all history,
  resume, caches, credentials and unrelated files. Additional providers/plugins
  in this radio-only profile require explicit review; do not initialize accounts
  as a side effect of entering tmux.

## Setup and health

Inspect without writing or launching a player:

```sh
./cliamp/mux-profile plan
./cliamp/mux-profile check
```

`check` returns 1 for a missing profile, 3 for drift/conflict, and 0 for a verified
profile. It does not establish stream availability, app liveness or audio quality.

After review and **explicit activation approval**, from the canonical primary
Omarchy checkout, run doctor and plan, then:

```sh
./cliamp/mux-profile apply --yes
```

The runbook enforces the primary-checkout/platform/approval gates and repeats root
health checks before mutation. It creates no player, tmux session, service or
symlink, and installs nothing. A partially created profile is reported, not
silently finished or removed. Recover only reviewed owned files after inspecting
what failed; never remove the entire general cliamp directory.

The launcher sets the dedicated `CLIAMP_CONFIG_DIR` only for its new player and
passes `--no-auto-play --no-shuffle --repeat off --provider radio --playlist work`.
It strips inherited `NAVIDROME_URL` and `LYRION_URL`, which otherwise enable
additional providers independently of config. Already running sessions keep
playing as-is. No browser-cookie access or provider setup is authorized.

The presets use the first HTTPS MP3 entries from SomaFM's official
`dronezone.pls`, `groovesalad.pls` and `synphaera.pls`, inspected September 30.
No streams were played during source selection. Live programming is not guaranteed
speech-free: report interruptions and replace unsuitable sources after review.
Source failure is an error, not permission to discover or substitute stations.

## Verification and recovery

- `python3 tests/cliamp-profile.py`: repeatable setup, approval/platform/checkout
  gates, parent symlinks, conflicts, drift and preservation, using disposable homes.
- `bash tests/mux.sh`: inert fake players and an isolated tmux server, never the
  live profile or audio system.
- Module/lifecycle/Omarchy/portable suites and root doctor/plan as required by
  `AGENTS.md`. Python 3.11+ is required for TOML validation; do not install tools
  merely to hide a blocked check.
- Native data-only CLI/parser checks use disposable homes/profiles. Actual
  player/audio startup requires separate approval. Stubbed startup tests do not
  establish audible behavior or future radio programming.

Rollback disables only the new verified `mux` entry/config links. Retain this
profile's local runtime state until explicitly approved for removal; do not kill
running players or delete credentials as automatic rollback. To inspect/control
this specific player later, an operator must set its `CLIAMP_CONFIG_DIR` explicitly;
plain cliamp IPC commands target the general profile and are not interchangeable.
