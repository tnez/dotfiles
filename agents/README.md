# Shared agent instructions and activity skills

`AGENTS.md` is materialized as regular files by
[`agent-config`](../docs/runbooks/agent-config.md). The two skills below are a
separate, deliberately small exception to the earlier personal-workflow cleanup.
They use ordinary Git/tmux commands, not a checkout manager, project bootstrap
framework, or background service.

## Use

- **start-work:** “Open acme/web for password-reset.” Resolve the repository,
  acquire/resume an independent activity clone, branch from `origin/main` for
  new work, and open a development session. The default layout is
  `~/Work/<owner>/<repo>/<activity>`. Use a suitable installed `dev` launcher,
  otherwise a plain tmux shell. No task brief, conversation handoff, automatic
  coding, project bootstrap, software installation, or new project trust.
- **clean-up-work:** “Clean up the password-reset workspace.” Inspect local
  work, ignored files, refs/stashes and processes; verify preservation; propose
  exact removals and obtain approval. Uncertain/unpreserved state means retain,
  not push or discard automatically. Closing a session does not delete its clone.

Sources are `skills/<name>/SKILL.md` with self-contained `references/` resources.
Pi discovers installed `~/.agents/skills/<name>/SKILL.md`; other compatible
agents can use the same location. Force explicit routing in Pi with
`/skill:start-work` or `/skill:clean-up-work`. Skills are model instructions,
not enforcement or a sandbox. Behavior is specified in
[`work-sessions.feature`](../specs/work-sessions.feature).

## Install or check on macOS and Omarchy

Requires Python 3.10+ and an existing home directory. Git/tmux are needed to
use the skills; a suitable `dev` and Pi are discovered, not installed.
From the reviewed canonical dotfiles checkout:

```sh
./dotfiles doctor
./dotfiles plan
./agent-skills plan
```

All three are read-only. `agent-skills plan`/`check` returns 0 for matching links,
1 for missing entries, or 3 with `ACTION_REQUIRED` for conflicts. Root doctor
and plan do not inspect these links; use the focused check too. Stop at any
`ACTION_REQUIRED`; do not hide a conflict with a force option or `--yes`.

After separate approval of the reported skill links and any missing parent
folders, use:

```sh
./agent-skills apply --yes
./agent-skills check
```

This links only `start-work` and `clean-up-work` directories into
`~/.agents/skills/`, creating missing `.agents`/`skills` parents as ordinary
private directories. Existing directories/files/foreign links at either skill
name and redirected parents are conflicts, not adopted or overwritten. Dottie,
Omarchy skills, Pi settings/auth/history and all other entries are untouched.
The generated links use absolute paths to this canonical checkout. No second
copy/link under `~/.pi/agent/skills` is needed.

Apply requires a supported host, the primary checkout's real `.git` directory,
explicit `--yes`, and successful root doctor/plan. Inspection is safe in a linked
checkout. A custom `PI_CODING_AGENT_DIR` needs separate discovery review and is
refused. No skill install is hooked into `dotfiles apply` or `agent-config`.
Legacy copied-skill retirement still scans only `agents/dot-agents/skills/`, not
these packages; never re-enable the retired materializer for them.

In Pi, `/reload` refreshes skills, or start a fresh session. Verify discovery and
one disposable activity through Scout on each host. No model request or live
session test is made by the installer. Missing prerequisites or authentication
are reported, not installed/repaired implicitly.

## Ownership, updates and recovery

The repo owns each skill package verbatim; the containing user skill directory
remains mixed-ownership. Once linked, source edits are live on the filesystem
and Pi loads instructions on demand. Review source changes before integration;
Git distribution does not authorize automatic activation on another machine.
Do not retire this checkout while the links depend on it. The same protection
applies to the KB and other live configuration anchors.

Apply is repeatable and creates links without clobbering existing entries. It
rechecks source/parent state and reads links back. Keep concurrent installers
idle. It is not a filesystem transaction or protection against a malicious
writer: on failure it retains created links/directories and reports partial
work. Re-plan, inspect exactly what exists, and resume only after resolving the
reported decision. There are no replaced-file backups because it never replaces
existing entries.

For approved uninstall/recovery, inspect both leaf links with `readlink`, require
each target to exactly equal this checkout's `agents/skills/<name>` path, and
unlink only those verified leaf links. Leave the shared parent folders and all
other skills untouched. Do not recursively delete `.agents`, follow skill links
while removing, or modify their source packages to uninstall them. Reload Pi
afterward; an already-loaded instruction remains in its current conversation.
A new session is the reliable way to stop relying on previously loaded guidance.

## Validation

- `python3 tests/agent-skills.py`: disposable-home installer safety/preservation.
- `python3 tests/work-session-skills.py`: synthetic local Git and private tmux
  walkthrough commands, including a fake editor/Pi; native Pi RPC discovery
  when installed, without model/network requests. Requires Git/tmux; a missing
  Pi is reported as skipped discovery coverage, not a pass.
- `bash tests/portable.sh`, `bash tests/lifecycle.sh`, `bash tests/modules.sh`:
  existing layout and lifecycle boundaries.
- `./agent-skills check`: read-only host link state, not behavioral proof.

The command walkthrough is a self-evaluation aid, not an independent agent eval.
Native macOS and real Scout/Pi discovery, popup behavior and skill judgment need
separate smoke checks after approved installation. Do not claim fixture success
proves unattended destructive cleanup is safe.
