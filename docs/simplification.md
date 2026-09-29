# Simplification candidate

Base: `97158b7`. Candidate only; no live activation, uninstall, or KB edits.

## Outcome and acceptance

Keep personal preferences, not a workstation workflow platform. Support macOS
and Omarchy without replacing Omarchy's shell or LazyVim. Codex and Pi are the
only managed agents. Prefer mise for project tools; versions belong to projects,
not a new global dotfiles runtime manifest.

- Retired standalone tools have no active configuration, hooks, shortcuts, or
  provisioning outside the explicitly preserved Neovim package.
- Codex/Pi share KB routing instructions without copied policy or personal prompts.
- Interactive managed shells activate mise; login/noninteractive environments use
  its shims. No automatic tool installation or project trust during shell startup.
- Existing live Codex config, credentials, sessions, unmanaged skills, machine
  configuration, and KB source content survive unchanged.
- Neovim and the two Omarchy preferences remain byte-for-byte unchanged.
- Isolation tests cover Stow/restow/unstow and unmanaged conflicts. Lifecycle
  policy/ownership tests remain; removed integration tests retire with their code.

## Scope

Remove gh-dash, Ghostty, Glow, Raycast, Sesh, Television, Claude, OpenCode, Herdr,
Hunk, HUD configuration and dependent scripts, personal workflow prompts/skills,
and tmux session LaunchAgents. Retain Lazygit the application without custom UI
configuration. Trim Codex/Pi to explicit preferences and retain conservative Codex
permissions. Keep ordinary tmux navigation without workflow popups.

Keep the lifecycle's trust, primary-checkout, copied-skill and KB-adapter ownership
checks for retirement. Do not replace them with another framework. Retire the KB
skill adapter declaration; direct KB reading does not require skill installation.
Keep the macOS GUI environment bridge for KB discovery. Omarchy activation stays
manual. Port only reviewed configs; do not blanket-enable Darwin modules on Linux.

Neovim's guarded Herdr navigation and CodeCompanion/Anthropic setup remain
explicit exceptions to the standalone-agent cleanup. They need a later editor
review, not silent deletion under this change.

Other applications, unreviewed Brewfile entries, Neovim/plugin dependencies, the
KB worktree policy, and replacement terminal/workflow choices are out of scope.
The user authorized native Git worktree isolation for this task; the broader
`.worktrees` layout discussion is deferred.

## Evidence and baseline

KB read at `/home/tnez/Work/tnezdev/knowledge-base`, clean main `78e509d`:
`root/software/development-opinions.md`, `root/processes/initiative-wayfinding.md`,
`root/processes/project-initialization-and-worktrees.md`. Herdr is replaceable;
wtp policy remains pending the user's separate reconsideration.

At the base: modules, Omarchy, Herdr start/cleanup, and OpenCode suites pass.
Lifecycle has 14 failures: PATH-dependent missing-Stow expectations and real
`/usr/bin/herdr` leaking into fake-Darwin tests. Herdr ran against a disposable
HOME (including plugin installation); no real-home activation was requested.
Fix test isolation before repeating. The fnm suite cannot finish without zsh;
ShellCheck is also unavailable. Do not install tools to mask those gaps.

Primary doctor/plan pass. Candidate doctor passes; candidate Omarchy plan reports
links belonging to the primary checkout as conflicts. That is expected worktree
isolation, not permission to relink the running desktop.

## Delivery gate

Review the complete candidate and test results before integration. Follow
[retirement](retirement.md) before merging source deletions into a live Stow
checkout. Do not merge first and discover dangling links later. Activation is a
separate human-approved step. Native macOS and interactive shell checks remain
required follow-up when unavailable here.

## Candidate results

Worktree: `/tmp/dotfiles-simplify-97158b7`, branch `chore/simplify-dotfiles`.
The primary remains at `97158b7`; this candidate is not merged or activated,
and nothing was pushed.
Tracked source/config retirement reduces 240 baseline files to 105 candidate
files and 35 modules to 23. Other unreviewed configs remain explicitly deferred.

| Done item | Status and evidence |
| --- | --- |
| Acceptance | Candidate cleanup implemented; final acceptance blocked on native verification and human review. No claim of completed live migration. |
| Preservation | Passed isolated Stow/restow/unstow, exact targets, unmanaged-file conflict, agent state/Dottie preservation, and copied-skill/adapter ownership regressions. `git diff 97158b7 -- nvim omarchy` is empty. |
| Validation | Modules, lifecycle, Omarchy, and portable-layout suites pass. Bash/POSIX syntax checks pass. `tests/fnm.sh` passes POSIX/Bash checks but exits 2 because zsh is unavailable. ShellCheck and native macOS checks are blocked. |
| Documentation | Passed review of root/component guidance, scope, KB/mise setup, deferred work, and retirement/recovery instructions. |
| Safe delivery | Candidate isolated; no application uninstall or KB changes. Pre-merge link retirement and post-review activation remain pending separate approval. An untracked `typescript` appeared in the primary during work; it was left untouched and is not part of this candidate. |
| Handoff | Candidate evidence and remaining gates recorded here; not fully verified or ready for live integration. |

Additional local evidence:

- `dotfiles modules --all`: valid inventory. Omarchy selects agents, Codex, Git,
  Omarchy, Pi, tmux; not Neovim or managed macOS shell files.
- Candidate doctor passes when the verified KB root is explicitly provided. It
  correctly fails without that variable. Persistent KB discovery is not activated.
- Read-only `stow --simulate --delete` for all retired/changed Stow packages
  from the primary checkout reported no links to remove on this Omarchy host.
  The primary `doctor`/`plan` still show the two unchanged Omarchy links. This is
  host-specific evidence, not proof about a separate macOS home.
- Candidate plan is blocked by the unmanaged regular Pi settings file. This is
  expected host state, not permission to adopt or replace it. Candidate location
  also makes the two primary-owned Omarchy links appear as conflicts. Stow tests
  use disposable homes instead.
- Native tmux 3.7c loads the config in an isolated socket/server; Git parses its
  config. Codex 0.156.0 loads the seed with `features list`, and local
  `debug prompt-input` proves it discovers the symlinked KB instructions without
  a model request. `--strict-config` is not supported by `features`; this is a
  native config-load check, not strict-schema validation.
- Pi 0.87.1 settings/keybindings were compared to its installed references. JSON
  validation and an offline, isolated no-auth model-list startup pass. Pi's
  symlinked instructions resolve in the Stow test; native prompt discovery and
  interactive key behavior still need a smoke check. No model calls were made.
- Complete retained diff, deleted-path inventory, new files, and source-link
  targets reviewed; `git diff --check` and `git diff --cached --check` pass.
- Test logs for this session are `/tmp/dotfiles-final-*.log`; these are disposable
  evidence, not durable repo inputs. The baseline lifecycle's 14 failures are
  resolved without dropping its ownership/failure-path tests. Retired Herdr and
  OpenCode suites were removed with their implementations.

No KB policy was edited. A later discussion should reconcile the proposed
`.worktrees` layout and retiring wtp with the active KB worktree process.
