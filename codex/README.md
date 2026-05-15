# Codex Dotfiles

`dot-codex/config.toml` is intentionally untracked because Codex rewrites it
with runtime state such as marketplace timestamps, cache paths, hook hashes, and
NUX counters.

Track durable preferences in `dot-codex/config.base.toml` instead. During
bootstrap, the base config is copied to `~/.codex/config.toml` only when the live
config does not already exist.

When a live Codex setting should become part of the dotfiles, copy only that
stable setting from `~/.codex/config.toml` into `dot-codex/config.base.toml`.
