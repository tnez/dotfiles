# Codex

`config.base.toml` keeps the existing model/reasoning preference and explicit
on-request approval/workspace-write sandbox. Historical trusted directories,
Claude environment variables, optional plugins/features, and Herdr hooks are
retired. Removing those from the seed does not rewrite live Codex configuration.

macOS apply copies the seed only when `~/.codex/config.toml` is absent. Omarchy
manual Stow does not copy it: Codex defaults work without a seed. Adopting it is
a separate explicit copy into an absent target, never a config reset.

`AGENTS.md` links to the shared `agents/AGENTS.md`. Keep KB root configuration in
the launching environment; see the root README. Auth, trusted projects, caches,
hook hashes, and sessions remain machine state. No-folding preserves their paths.
