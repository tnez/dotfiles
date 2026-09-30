# DOTFILES PROJECT REFERENCE

This repository contains personal configuration for macOS and Omarchy.
GNU Stow is one delivery mechanism, not a requirement for every configuration.

## Configuration ownership and executable runbooks

- Use Stow when dotfiles should own a file verbatim. Do not force mixed-ownership
  or application-written configuration into whole-file symlinks.
- When that becomes awkward, prefer a small, focused executable runbook:
  inspect current state, report intended changes, reconcile only explicitly
  owned settings after approval, and verify the result. Avoid a new general
  configuration framework or background synchronization service.
- Record shared preferences in the repo; preserve machine-local paths, themes,
  packages, credentials, runtime state, and unrelated settings unless explicitly
  included in the agreed scope.
- Pair runbooks with agent guidance and read-only doctor/health checks. Report
  drift; if local changes may represent a new preference, ask whether to update
  the shared declaration or restore it rather than silently choosing a winner.
- Make mutations repeatable, test preservation and failure paths in disposable
  fixtures, and document recovery. Runbooks retain the same primary-checkout,
  platform, approval, and ACTION_REQUIRED safeguards as lifecycle commands.
- Git distributes reviewed preferences; this does not authorize automatic
  commits, pushes, activation, or overwriting local state.

## Lifecycle Commands

- `./dotfiles doctor` - Read-only prerequisite and conflict checks
- `./dotfiles plan` - Read-only provisioning and activation simulation
- `./dotfiles apply` - Fast Stow, copied-file, and integration convergence
- `./dotfiles provision` - Install missing dependencies without upgrading all
- `./dotfiles upgrade` - Explicit slow package update, upgrade, and cleanup
- `./dotfiles modules [--all]` - List selected declarative components
- `./dotfiles bootstrap` - Doctor, plan, provision, apply, and final doctor
- `stow --dotfiles <package>` - Symlink specific config package to ~
  - Uses `dot-` prefix convention (e.g., `dot-config` → `.config`)
- `stow --dotfiles -D <package>` - Remove package symlinks
- `brew bundle --file=brew/Brewfile` - Install dependencies from Brewfile

## Agent Driving Contract

1. Run `./dotfiles doctor` and `./dotfiles plan` before proposing or running a
   mutating lifecycle command. Both are safe in linked worktrees.
2. Never run `bootstrap`, `apply`, `provision`, or `upgrade` from a disposable
   checkout. A `.git` file means linked/disposable; activation is allowed only
   from the canonical primary checkout with a `.git` directory.
3. After a candidate change is merged, run the needed command from the updated
   primary checkout. Existing stowed-file edits are usually already live; on
   macOS use `apply` for path/copy/integration changes, `provision` for missing
   dependencies, and `upgrade` only when package upgrades are intended.
   Omarchy activation remains manual and requires explicit approval.
4. On a new macOS machine, inspect and run `install.sh`, or invoke it with
   `--path "$HOME/Code/tnez/dotfiles/main" --non-interactive --yes`. The
   installer clones or reuses the canonical checkout and calls local
   `dotfiles bootstrap`.
5. If any command emits `ACTION_REQUIRED`, stop. Report the exact action and
   obtain a human policy/destructive decision. Never infer consent from
   `--yes`. Formula trust requires the explicit reviewed
   `--trust-formula <name>` option after review.

## Definition of Ready

A change is ready for implementation when the following are recorded in the
task plan, issue, or conversation. Keep this proportional: a small change can
use a few bullets; a separate design document is not required.

- **Outcome and acceptance criteria:** State the user-visible problem and
  observable conditions that will demonstrate success. For documentation,
  state what readers must be able to understand or do.
- **Scope and non-goals:** Identify affected components and supported hosts,
  what will be added or changed, and related work explicitly excluded. Do not
  bundle unrelated cleanup, new dependencies, or speculative abstractions.
- **Context and invariants:** Read the affected components' `AGENT.md` files,
  relevant documentation and decisions, implementation, and tests. Identify
  existing behavior that must survive, including unmanaged files, runtime
  state, platform boundaries, and activation safety. Existing code is evidence
  of current behavior, not automatic proof of intent.
- **Verification plan and baseline:** Map acceptance criteria and invariants
  to automated checks or specific manual observations. Inspect Git status and
  the existing diff; run relevant baseline checks before editing behavior.
  Record existing failures and unavailable tools or platforms. For docs-only
  work, review the existing guidance for contradictions instead.
- **Delivery and recovery:** Identify whether the change affects live stowed
  files, needs later activation, or needs migration/rollback instructions.
  Run `doctor` and `plan` before proposing any mutating lifecycle command;
  readiness itself grants no permission to activate or overwrite user state.
- **Open decisions resolved:** Clarify uncertainty that affects scope,
  ownership, personal preferences, destructive actions, or acceptance. Do not
  invent requirements. Read-only discovery may proceed before readiness;
  implementation waits on decisions that would change the solution.

## Definition of Done

A change is done when the following checklist is satisfied. Report each item
as passed, failed, blocked, or not applicable, with evidence or a reason.
A skipped check is not a pass; unresolved required verification means the
change is not yet verified, unless the user explicitly accepts that gap.

- **Acceptance:** Each Ready acceptance criterion has matching evidence.
  Changes stay within the agreed scope; any changed requirements or non-goals
  have been resolved with the user.
- **Preservation:** Relevant invariants have been checked, including failure
  paths and absence of unintended effects. Add or update regression tests for
  changed behavior where practical; for a bug fix, demonstrate the test fails
  before the fix when feasible. Explain any reliance on manual checks.
- **Validation:** Run the applicable checks in Testing Changes below, including
  relevant baseline checks again. Review the complete candidate diff,
  including staged, unstaged, and newly added files, and run `git diff --check`
  and `git diff --cached --check`. Separate pre-existing failures from new ones;
  do not weaken tests merely to obtain a pass.
- **Documentation:** Update affected component guidance, usage, and architecture
  documentation when behavior, ownership, dependencies, or operations change.
  Record important rationale and non-goals where future agents will find them.
- **Safe delivery:** No unrelated user work is changed. Stow, ownership, and
  platform safety rules remain intact. Any required activation and recovery
  steps are identified; review and integration follow Integration Policy.
- **Handoff:** Summarize what changed, checks and their outcomes, skipped or
  blocked checks, and remaining risks. Distinguish candidate verification from
  live activation. Report activation as completed, not needed, or pending;
  never claim a mocked platform check proves native runtime behavior.

Candidate verification does not authorize activation. Pending post-merge
activation must remain an explicit follow-up, not an implied completed step.

## Project-Specific Style

- UTF-8 encoding, Unix line endings (LF)
- 2-space indent (4 for Python)
- 80 char line limit (except Markdown)
- Trim trailing whitespace
- End files with newline

## Language Standards

- **Lua**: StyLua (2 space, single quotes, 160 cols)
- **Python**: 4 spaces
- **JS/TS**: Prettier
- **Shell**: ShellCheck compliance

## Repository Structure

- Organized by tool/application name
- Components declare platform and Stow mode in their local `AGENT.md`
- XDG-compliant where possible (`dot-config/` maps to `~/.config/`)
- Special packages:
  - `brew/` - Homebrew dependencies
  - `omarchy/` - Hyprland and Omarchy user overrides
  - `scripts/` - Utility scripts

## Testing Changes

Select checks by the behavior affected, not only by changed filenames. Shared
lifecycle, profile, or integration changes require checking their consumers.
Run independent checks even if another fails, unless a safety boundary such as
`ACTION_REQUIRED` requires stopping. Do not install tools just to hide a gap.

| Change area | Required checks |
| --- | --- |
| Module declarations or discovery | `bash tests/modules.sh`; `./dotfiles modules --all`; `./dotfiles doctor`; `./dotfiles plan` |
| Lifecycle, installer, ownership, provisioning, or shared integrations | `bash tests/modules.sh`; `bash tests/lifecycle.sh`; `./dotfiles doctor`; `./dotfiles plan` |
| Stowed paths or package layout | Isolated Stow checks below; `./dotfiles doctor`; `./dotfiles plan` |
| Omarchy package | `bash tests/omarchy.sh`; `./dotfiles doctor`; `./dotfiles plan` |
| Shell initialization, profile, or Node environment | `bash tests/fnm.sh`; `bash tests/lifecycle.sh`; affected-shell startup smoke checks |
| Retained Stow layout, Codex/Pi, or portable preferences | `bash tests/portable.sh`; `bash tests/lifecycle.sh`; native config checks |
| Tmux overlay and host-binding compatibility | `bash tests/tmux.sh`; `bash tests/portable.sh`; `python3 tests/tmux-navigation.py` (requires installed smart-splits) |
| Other application configuration | Component health checks from its `AGENT.md`; native config validation and focused smoke checks where available |
| Shell code | Syntax checks with the appropriate interpreter; ShellCheck on affected supported shell files |
| Documentation only | Review accuracy, referenced paths/commands, links, and consistency with existing guidance; runtime suites are not required unless executable behavior also changes |

These are minimum checks, not exhaustive coverage. Add targeted tests for new
behavior. Test scripts named `fake-*` and `fail-command.sh` are fixtures, not
standalone suites; do not execute every `tests/*.sh` indiscriminately.

- Test Stow packages in a disposable home before committing: initial stow,
  repeated restow, exact symlink targets, conflicts with unmanaged files, and
  unstow preserving unrelated configuration. Never use the real home as a
  regression-test fixture.
- Inspect suite output as well as exit status. `tests/lifecycle.sh` can skip
  coverage when Stow is missing. Focused suites also need their tools
  (for example zsh or Python 3.11+); record missing prerequisites as blocked.
- `doctor` and `plan` are read-only host checks, not regression-test substitutes.
  Record host drift separately from candidate defects. Platform fakes do not
  replace native macOS or Omarchy verification; identify any remaining native
  smoke checks and obtain approval before live activation.

## Integration Policy

- After orchestrator review and verification, prepare cohesive commits
- Fast-forward integration into local `main` is permitted
- Never push unless explicitly requested

## Simplification delivery boundary

Read `docs/simplification.md` and `docs/retirement.md` before integrating this
candidate. Never merge deleted Stow sources into the live primary checkout
before reviewing and retiring their owned links. Preserve ownership records,
unmanaged agent state, the KB checkout, and Omarchy's shell/LazyVim.

Project tools use mise. No global runtime version manifest, automatic project
trust, or shell-startup installation is introduced here. Native Git worktree
isolation was approved for this cleanup only; broader layout policy is deferred.
`tests/fnm.sh` retains its historical name but now tests mise/profile behavior.

## Adding New Configurations

1. Create a directory named after the tool
2. Add an `AGENT.md` with one validated `dotfiles-module` declaration
3. For Stow-owned files, use the `dot-` prefix (e.g., `dot-vimrc` → `~/.vimrc`);
   for mixed ownership, document the focused runbook and settings it may change.
4. Document install, update, health, and agent-specific context locally
5. Test with `./dotfiles modules --all` and `./dotfiles plan` first
6. Add any macOS dependencies to `brew/Brewfile` if needed
