# Pi

These are agent-guided settings preferences, not a canonical `settings.json`
or a request to synchronize a machine. Apply only explicitly requested changes,
key by key, preserving all other application-managed values:

- `defaultProvider`: `openai-codex`; `defaultModel`: `gpt-6.1-sol`.
- `defaultThinkingLevel`: `high`.
- `enabledModels` (cycle order): `openai-codex/gpt-6-astra:high`,
  `openai-codex/gpt-6-luna:high`, `openai-codex/gpt-6.1-sol:high`.
- `modelThinkingLevels`: `high` for each exact provider/model ID above
  (without the `:high` suffix).
- `theme`: `system`.
- `enableInstallTelemetry`: `false`; `quietStartup`: `true`.
- `treeFilterMode`: `no-tools`.

Separately, Stow owns `keybindings.json`: Alt-h/j/k/l cursor navigation and
`ctrl+shift+t` for the session tree.

The lineup uses Sol 6.1 for everyday work, Luna for focused tasks, and Astra
for demanding work. High reasoning is an explicit preference, not Pi's upstream
medium default. Keep the per-model levels and cycle suffixes consistent.
After an approved settings edit, run `/reload`; start a fresh session to check
startup selection, since resumed sessions restore their saved model and effort.
To undo a model preference change, restore only the changed model keys from
its before/after delta, preserving any unrelated settings changed since.

The installed Pi 0.87.1 settings/keybindings reference confirms the removed
retry, compaction, external-editor, follow-up, dequeue and newline settings
duplicate defaults. The old changelog version was runtime bookkeeping.
The personal prompt/skill references and pi-docparser declaration are retired;
no installed extension or skill is deleted by this change.

`AGENTS.md` links to `agents/AGENTS.md`. KB content stays in its own checkout.
Configure `TNEZDEV_KNOWLEDGE_BASE_ROOT` in the launching environment as described
in the root README; no Dottie or Herdr bridge is needed for direct KB access.

Pi itself is installed separately using the supported platform or mise provider.
Credentials, sessions, caches, and package installations remain machine-owned.
The no-folding Stow package owns only personal keybindings and the shared
`AGENTS.md` link; it does not include `~/.pi/agent/settings.json`. Existing
settings and the rest of the agent directory remain unmanaged. Never adopt or
replace a local settings file. For an approved preference change, review the
exact before/after delta and preserve unrelated keys, auth, sessions, packages,
caches, and runtime state.
