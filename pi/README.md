# Pi

## Declared end state

Setup means reading this guidance and materializing regular files, not merely
linking the repo or leaving preferences unapplied. Use the focused
[`agent-config` runbook](../docs/runbooks/agent-config.md) for approved writes.
`preferences.json` is a partial declaration, not a complete `settings.json`.

- Startup: `openai/gpt-6.2-sol`, high reasoning.
- Ctrl+P cycle order: `openai/gpt-6.2-astra:high`,
  `openai/gpt-6-luna:high`, `openai/gpt-6.2-sol:high`.
- Per-model thinking levels: high for each exact provider/model ID above.
- Install telemetry off; quiet startup on; session tree filter `no-tools`.
- Add `+codemode` to the existing tool selection, preserving other tool choices.
- Preserve the machine theme, including Omarchy's `omarchy-system`. On a fresh
  settings file Pi's upstream `system` default applies. No theme reset.

Use upstream retry, compaction, codemode mode and resource-discovery defaults.
Do not normalize existing unrelated settings to those defaults.
The lineup uses Sol 6.2 for everyday work, Luna for focused tasks, and Astra 6.2
for demanding work. High reasoning is an explicit preference, not Pi's medium
default.
Verify exact IDs with `pi --offline --list-models` before approved activation;
missing models require review, not an invented replacement. Catalog presence
does not prove successful provider authentication or a live model request.

`dot-pi/agent/keybindings.json` declares owned actions: Alt-h/j/k/l navigation
and Ctrl+Shift+T for the session tree. Merge these into a regular local file,
preserving all other actions. The retained instruction source symlink is legacy
migration provenance, not an installation source for Stow.

## Changing declared preferences

Use the declaration-first workflow for model lineup and other owned settings:

1. Edit `preferences.json`, update this guidance and regression expectations,
   and verify exact model IDs in Pi's catalog. Do not copy live settings into Git.
2. Run the component tests. From the reviewed canonical checkout, run
   `./dotfiles doctor`, `./dotfiles plan` and `./agent-config plan`. Review the
   proposed owned-key changes. Record unrelated host drift separately; it does
   not gate agent-file reconciliation. Stop for agent-config preflight failures
   or any emitted `ACTION_REQUIRED` and obtain review.
3. After explicit approval to restore the declaration, keep Pi settings writers
   idle and run `./agent-config apply --yes --restore-declared`. This merges the
   declaration into the regular, machine-local `~/.pi/agent/settings.json`;
   unrelated settings and old per-model thinking entries are preserved.
4. Run `./agent-config check`, verify the live values and preservation of
   unrelated settings, then test startup and Ctrl+P in a fresh Pi session.
   A resumed session keeps its saved selection. Report any untested native
   behavior separately from successful configuration read-back.

Pi's settings UI can make local changes, but UI-only edits do not update the
shared declaration. Do not use them as a substitute for this workflow. A
repository edit alone is not live activation. See the
[runbook](../docs/runbooks/agent-config.md) for backups and recovery.

## Instructions and knowledge base

Materialize `agents/AGENTS.md` into the regular Pi instruction file. KB content
stays in its own checkout; configure `TNEZDEV_KNOWLEDGE_BASE_ROOT` in the launching
environment as described in the root README. At runtime read that checkout's
`AGENTS.md`, `root/index.md`, and `root/meta/agent-consumption.md`, then select
relevant guidance. A readable-path check is not evidence the content was loaded.
No bridge, copied KB, persistent personal prompts, or KB skill installation is
needed. The separate optional `start-work` and `clean-up-work` activity skills
are declared in [`agents/README.md`](../agents/README.md); install/check them
through `./agent-skills`, not `agent-config` or Pi settings reconciliation.

## Verification and recovery

Run `python3 tests/agent-config.py`, `bash tests/portable.sh`, and
`bash tests/lifecycle.sh`. Run `./agent-config check` for read-only host drift.
The deprecated `./omarchy-agent-links check` delegates to it; old recovery hooks
cannot recreate links. Disable those verified hooks before live migration.

After approved writes, `/reload` refreshes instructions, keybindings and tools.
Start a fresh session to verify startup model and effort: resumed sessions keep
their saved selection. Check Ctrl+P traverses exactly the three models at high
reasoning, and confirm instruction discovery and actual KB reads. CLI options,
custom agent directories and trusted project settings can override user config;
inspect those rather than granting trust or editing project files automatically.

Settings, auth, sessions, caches, installed packages and all unrelated skills
stay machine-owned. Only the two activity skill source packages and their
explicitly installed leaf links are dotfiles-owned.
Keep settings writers idle during reconciliation. Recovery restores only the
reviewed changed files/keys from private backups, preserving subsequent edits;
see the runbook. Pi itself is installed separately; setup never installs software,
requests a model response, or changes credentials.
