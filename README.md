# Personal dotfiles

Small preferences for macOS and Omarchy. Use GNU Stow for files owned verbatim;
use focused executable runbooks when settings share ownership with applications
or machine-local configuration. Agent guidance and read-only health checks guide
reconciliation; neither approach grants permission to overwrite local state.
Codex and Pi are the only managed agents. Project runtimes and tools belong in
project-local `mise.toml` files; dotfiles does not install or trust those projects
for you.

## Inspect first

```sh
./dotfiles modules --all
./dotfiles doctor
./dotfiles plan
```

These commands are read-only. An `ACTION_REQUIRED` means stop for a human policy
or destructive decision. A candidate worktree can report conflicts with links
owned by the primary checkout; that is not permission to relink the live home.

**Upgrading from the previous configuration:** read
[retirement](docs/retirement.md) **before merging source deletions**. Existing
Stow links make primary-checkout edits live, even without running apply.

## What we own

- Shared KB startup instructions and small Codex/Pi preferences.
- Git and tmux preferences reviewed for both platforms.
- Omarchy: Caps Lock/Ctrl swap and default coding agent `pi`, nothing else.
- macOS shell/editor/tool preferences, Homebrew inventory, and the GUI environment
  bridge. Neovim is deliberately preserved pending a separate review, including
  its guarded Herdr navigation and CodeCompanion/Anthropic configuration.

Lazygit remains installed via Homebrew but uses upstream defaults. Its old file
contained only UI toggles/bookkeeping, not an essential workflow. Several keys
were under `gui` although the installed default schema places them at the root.
There is no replacement configuration framework or custom workflow launcher.

Existing unreviewed modules (`bat`, `bun`, `env`, `ssh`, `starship`, `vim`, `yazi`,
editor defaults) are not proof of current usage; they remain for separate review.
Brewfile entries unrelated to retired tools are also preserved, not endorsed as a
minimal dependency list. Do not uninstall software because its config is retired.

## Knowledge-base access

The KB owns policy and durable knowledge. Dotfiles provides only discovery:

```text
Codex/Pi AGENTS.md → shared agents/AGENTS.md
                  → TNEZDEV_KNOWLEDGE_BASE_ROOT → KB AGENTS.md + root/index.md
```

Set that environment variable to the **actual absolute checkout path** on each
machine. No `main/` layout or fallback search is assumed. For the current Omarchy
machine the verified path is `/home/tnez/Work/tnezdev/knowledge-base`.

On managed macOS shells, place the export in the unmanaged `~/.profile.local`:

```sh
export TNEZDEV_KNOWLEDGE_BASE_ROOT="/absolute/path/to/knowledge-base"
```

`profile/dot-profile.local.example` is an example, not active configuration.
Bash and Zsh load the shared profile. The macOS environment LaunchAgent publishes
PATH and the KB root for subsequently launched GUI apps. Existing apps must be
fully restarted after an approved environment update.

On Omarchy, export the variable in the existing user shell configuration rather
than replacing its upstream shell setup. An export in a terminal does not change
already-running GUI applications; launch agents from that terminal until a
separately reviewed desktop environment setup is in place.

Optional `TNEZDEV_LOCAL_CONTEXT_ROOT` points to a private `AGENTS.md` router and is
loaded only when the task needs it. Dottie and Herdr are not required to read the
local KB. The `present-for-decision` skill adapter is retired; its source remains
readable through the KB index without installing a skill.

## Mise and applications

Homebrew installs mise on macOS. The managed interactive shells activate it;
noninteractive/GUI environments use existing mise shims. Prefer
`mise exec -- <command>` for project scripts and CI. Do not auto-install runtimes
or run `mise trust` in startup files. Existing fnm/pyenv installations and tool
versions are not deleted or migrated automatically.

Pi/Codex binaries are installed separately through a supported platform or mise
provider. No ad-hoc curl/npm/Bun agent installation runs during provisioning.
Homebrew still supplies the Codex desktop app. Omarchy owns its package setup.

## Activation (separate approval)

Automated mutation is macOS-only and refuses linked worktrees:

- `./dotfiles apply`: Stow, absent-only Codex seed, owned-copy retirement,
  launcher and GUI environment convergence; no packages or Herdr services.
- `./dotfiles provision`: install missing Brewfile packages, no routine upgrades.
- `./dotfiles upgrade`: explicit Homebrew updates/upgrades/cleanup, no package
  pruning. Formula-specific trust remains required.
- `./dotfiles bootstrap`: doctor, plan, provision, apply, final doctor.

For a new macOS machine, inspect `install.sh` and run it with an explicit
canonical primary checkout path. Configure KB access and resolve conflicts
before activation. `--yes` never grants formula trust or destructive consent.

Omarchy Stow remains manual. Review each selected module's `AGENT.md`, the dry
run, and existing target ownership before choosing which modules to activate.
Never use `--adopt`, force overwrites, or the real home as a test fixture.
Neovim, Bash, Zsh and the shared profile are **not** selected on Omarchy; the
existing LazyVim and upstream shell stay untouched.

See [module architecture](docs/architecture/agent-modules.md),
[candidate scope and baseline](docs/simplification.md), and
[retirement/recovery](docs/retirement.md).
