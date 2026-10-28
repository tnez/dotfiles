# Codex

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow none
capability codex-seed
-->

Own only the KB instruction entrypoint and a small preference seed. No personal
commands, generated integration hooks, project trust lists, or runtime state.
`./agent-config` writes shared instructions as a regular `~/.codex/AGENTS.md`
from `agents/AGENTS.md`; see `docs/runbooks/agent-config.md`. The legacy
`dot-codex/AGENTS.md` source link remains only for migration provenance.
This component is not Stow-activated.

On macOS `dotfiles apply` seeds `~/.codex/config.toml` only when absent. On Omarchy
use Codex defaults or, after approval,
copy the base only if no live config or symlink exists. Never overwrite a live
config, credentials, sessions, or caches. Binaries are installed separately.

Verify with `bash tests/portable.sh` and `bash tests/lifecycle.sh`. See README.
