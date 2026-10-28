# Codex

`config.base.toml` keeps the existing model/reasoning preference and explicit
on-request approval/workspace-write sandbox. Historical trusted directories,
Claude environment variables, optional plugins/features, and Herdr hooks are
retired. Removing those from the seed does not rewrite live Codex configuration.

macOS apply copies the seed only when `~/.codex/config.toml` is absent. On
Omarchy this component is not Stow-activated: Codex defaults work without a seed.
Adopting it is a separate explicit copy into an absent target, never a config
reset.

`./agent-config` materializes `~/.codex/AGENTS.md` as a regular file from
`agents/AGENTS.md`. The internal legacy source link is retained only for migration
provenance. Follow [the runbook](../docs/runbooks/agent-config.md); do not Stow
this component. Keep KB root configuration in the launching environment and load
its required entrypoints; see the root README. Auth, trusted projects, caches,
hook hashes, sessions and live Codex settings remain machine state.
