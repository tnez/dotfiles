# Materialize agent configuration

## Outcome and ownership

A configured machine has regular shared instruction files, the declared Pi
three-model cycle at high reasoning, personal keybindings, and a usable KB root.
A repo checkout or correct symlink is not proof of that end state.

`./agent-config` is a focused executable runbook for macOS and Omarchy. It is
not a lifecycle capability, package installer or background synchronization
service. Stow does not activate the `agents`, `pi`, or `codex` components.
The existing macOS Codex absent-only config seed remains unchanged.

The runbook writes only:

- `~/AGENTS.md`, `~/.codex/AGENTS.md`, `~/.pi/agent/AGENTS.md`: regular copies
  of `agents/AGENTS.md`. These are whole-file instruction declarations; a
  differing existing file requires an explicit choice to restore the declaration.
- `~/.pi/agent/settings.json`: merge keys declared in `pi/preferences.json`.
  Merge the three per-model thinking entries without removing other models.
  Enable codemode without discarding unrelated tool choices.
- `~/.pi/agent/keybindings.json`: merge declared action mappings from
  `pi/dot-pi/agent/keybindings.json`, preserving unrelated actions.

Preserve theme, packages, auth, sessions, trust, runtime state, skills and every
other setting. The repo's internal legacy instruction source links are retained
for provenance, not installed. Codex config/preferences are outside this runbook.
A custom `PI_CODING_AGENT_DIR` needs separate review and is refused.

## Inspect and approve

From the supplied canonical checkout:

```sh
./dotfiles doctor
./dotfiles plan
./agent-config plan
pi --offline --list-models
```

`plan` and `check` never write; 0 means matching state, 1 means a proposed delta,
and 3 with `ACTION_REQUIRED` means stop for review. Root doctor/plan do not run
this focused check and cannot certify its end state. Model catalog presence
must be checked separately; the runbook does not make network/model requests.

Configure the absolute `TNEZDEV_KNOWLEDGE_BASE_ROOT` in the launching environment;
do not guess another checkout. The runbook checks the three required entrypoints.
The agent must actually read the KB agent guide, bundle index and consumption
contract, then load task-relevant guidance with maturity metadata preserved.
This is context priming, not a skill install or copying the bundle into config.

Review the proposed paths and changed key names. Do not publish config dumps or
private backups. Stop for unsafe paths, unknown links, malformed/duplicate-key
JSON, missing agent directories or unreadable KB entrypoints. Missing agent
folders can indicate lost runtime state; they are not silently recreated.
A first installation needs a separate approved directory setup if they are absent.

Apply only after approval, keeping Pi/settings/config writers idle:

```sh
./agent-config apply --yes
```

For reviewed existing-file drift, explicitly choose the declaration with
`--restore-declared`. This authorizes only the owned files/keys above, not a
whole settings reset. If local drift should instead become the shared preference,
update and review the declaration first. `--yes` alone does not select a winner.

## Controlled migration from Stow links

Before migration, inspect all affected paths and the optional old hook copies:
`~/.config/omarchy/hooks/{post-update,post-boot}.d/90-dotfiles-agent-links`.
After separate approval, disable only verified generated hooks, preserving other
hooks. The deprecated `omarchy-agent-links` entrypoint now refuses `repair` and
`install-hooks`, so old hooks cannot reintroduce links. Its `check` command
redirects to this runbook. No new hooks are installed.

Review exact targets. Only links resolving to this checkout's instruction source
or keybinding declaration can be migrated. Unknown/dangling links, redirected
parents and any settings symlink are conflicts. Sources remain in the repo so
pre-migration links are not broken by candidate preparation.

Approved migration plus preference restoration uses:

```sh
./agent-config apply --yes --migrate-links --restore-declared
```

This replaces the verified link itself with a regular file; it never writes
through the link. Existing regular configs are merged, not adopted into Git.
Apply requires the primary checkout's real `.git` directory and successful root
doctor/plan. Approval for candidate work is not approval for this live migration.

## Failure, verification and recovery

Before writes, apply reinspects all inputs and creates a private recovery
folder under `~/.local/state/dotfiles/agent-config/before-*`. It records former
link targets, existing regular-file bytes/modes, and absent-file markers.
Generated metadata can contain private paths; never commit it. Backups remain
after success or partial failure and are not automatically deleted.

Each write uses a same-directory temporary file. New targets are created
no-clobber; existing targets are compared again then atomically replaced and
read back. Existing permission bits are preserved; new files are private.
No writer can guarantee isolation against an uncooperative process between the
last comparison and replacement. Keep writers idle. A failure can leave some
files updated; the runbook stops and reports partial work instead of attempting
a destructive automatic rollback. Inspect the backup before retrying.

Run `./agent-config check` afterward. In Pi run `/reload`, then use a fresh
session to verify Sol 6.1/high startup and Ctrl+P cycling Astra → Luna → Sol at
high reasoning. Resumed sessions and CLI/project overrides can retain different
selections. Confirm instruction discovery and actual KB reads, not just readable
files. Never grant project trust or make paid model calls merely to pass setup.
Native macOS environment inheritance and interactive key behavior require native
smoke checks; fixture tests do not prove them.

For rollback, inspect the changed keys and current files against the private
before images. Restore only approved deltas, preserving edits made afterward.
Recreating an old symlink requires checking the source still exists and explicit
approval; do not restore links merely because they were present before. Never
replace a whole settings file over newer application changes or delete an agent
directory. Stow does not remove these regular materialized files.

Tests: `python3 tests/agent-config.py`,
`python3 tests/omarchy-agent-links.py`, `bash tests/portable.sh`,
`bash tests/lifecycle.sh`, and `bash tests/modules.sh`. Tests use disposable homes
and synthetic state, without live config, hooks, credentials or model requests.
