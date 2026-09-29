# Scripts

<!-- dotfiles-module
version 1
platform darwin
stow standard
-->

Only the macOS GUI environment synchronizer and existing wtp initialization
helper/template remain under `dot-scripts`. The worktree-layout policy is deferred,
not replaced as part of retiring Herdr. `brew-add.sh` and `brew-upgrade.sh` are
repository utilities, not shell workflow commands.

`sync-launchd-environment.sh` reads the shared POSIX profile and publishes only
PATH and configured KB/local-context roots. Verify with `bash tests/lifecycle.sh`.
Never run it as a real-home regression test. Preserve unrelated scripts during
retirement; see `docs/retirement.md` before deleting old managed source paths.
