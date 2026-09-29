# Codex

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow no-folding
capability codex-seed
-->

Own only the KB instruction entrypoint and a small preference seed. No personal
commands, generated integration hooks, project trust lists, or runtime state.
`dot-codex/AGENTS.md` links to the shared source in `agents/AGENTS.md`.

On macOS `dotfiles apply` seeds `~/.codex/config.toml` only when absent. On Omarchy
Stow is manual and does not seed config: use Codex defaults or, after approval,
copy the base only if no live config or symlink exists. Never overwrite a live
config, credentials, sessions, or caches. Binaries are installed separately.

Verify with `bash tests/portable.sh` and `bash tests/lifecycle.sh`. See README.
