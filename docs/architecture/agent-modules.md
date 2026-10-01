# Agent-driven dotfiles modules

Status: accepted

## Context

The repository contains declarative configuration, but its composition is
imperative. A single shell program knows which Stow packages exist, assumes
Homebrew and launchd, and embeds one-off convergence for several tools. That
makes the macOS setup reproducible, but it prevents the lifecycle from even
reasoning about the Omarchy package on its native host.

An agent needs two kinds of information:

1. deterministic state that can be validated and planned without judgment;
2. operating context for unusual installation, update, health, and retirement
   decisions.

A prose file alone is flexible, but treating prose as executable input would
make plans irreproducible and unsafe. A scripts-only layout has the opposite
problem: it exposes commands without enough context to decide whether they
should run.

## Decision

Each activatable component has an `AGENT.md` entrypoint. It combines normal
Markdown guidance with one small, line-oriented declaration:

```markdown
<!-- dotfiles-module
version 1
platform darwin
stow standard
-->
```

The declaration is the deterministic interface. The surrounding Markdown is
the agent interface. The lifecycle parses only the declaration and never
executes Markdown, shell fragments, or frontmatter.

Version 1 supports these directives:

- `version 1` exactly once;
- one or more `platform` directives, whose values are `darwin` or `omarchy`;
- `stow standard`, `stow no-folding`, or `stow none` exactly once;
- optional repeatable `capability` directives selected from a closed lifecycle
  vocabulary (`homebrew`, `codex-seed`, `launchd-environment`,
  `materialized-skills`, and `knowledge-base-adapter`).

Declarations are discovered from immediate child directories, sorted by
component name, and validated before any convergence. A directory without an
`AGENT.md` is not an activatable component. This replaces the root
`dotfiles-packages` activation manifest, so ownership lives beside the files
it describes.

The `brew` component declares `stow none` and `capability homebrew`. Its
Brewfile remains the declarative macOS dependency inventory and its `AGENT.md`
explains provider-specific install, update, and health behavior. Other closed
capabilities attach existing lifecycle-owned convergence (skill materializing,
Codex seeding, and LaunchAgent loading) to the component
that owns it. Capabilities select reviewed implementation; they are not command
strings and cannot execute Markdown.

A component can also declare `stow none` without a lifecycle capability for
mixed-ownership settings. The Omarchy-only `cliamp` component uses this for its
focused `mux-profile` runbook: discovery lists the component, but lifecycle
commands do not execute its runbook. The component's explicit read-only checks
and approved setup are separate operations. This needs no new declaration syntax
or general synchronization framework; application-written state is not Stowed.

The existing Omarchy module also owns small desktop preference inputs, without
owning whole mixed-configuration directories. Its `hypr/preferences.lua` is a
separately activated include; `omarchy/preferences.json` declares just the bar
position. The repository-root `./omarchy-preferences` runbook offers explicit
read-only checks and approved settings-level reconciliation of `shell.json`.
It is not a lifecycle capability or background synchronizer. Root doctor/plan
check links/prerequisites, while this focused check reports preference drift;
neither automatically chooses between a local change and the shared preference.
See `omarchy/AGENT.md` for activation, hot-reload and recovery boundaries.

Platform selection is conservative:

- existing configuration remains `darwin` until it is reviewed for portability;
- the `omarchy` and `cliamp` components are `omarchy` only;
- `agents`, `codex`, `pi`, `git`, and `tmux` now list both platforms after
  isolated layout validation; native macOS verification remains a delivery gate;
- shared declarations do not enable macOS-only copy or service capabilities
  on Omarchy. Its Stow activation remains manual.

This prevents a Linux plan from proposing macOS links and prevents macOS from
activating Hyprland overrides.

## Agent operating model

An agent starts with read-only discovery:

1. identify the host platform;
2. run `dotfiles doctor` and `dotfiles plan`;
3. inspect the selected components' `AGENT.md` files;
4. distinguish deterministic convergence from policy or destructive work;
5. mutate only from the canonical primary checkout and only after required
   decisions are explicit.

The lifecycle remains a safety boundary, not an autonomous decision maker.
It validates declarations, detects conflicts, and performs known convergence.
The agent decides whether a component belongs on a host, whether prose-only
special instructions apply, and whether package or service changes are
appropriate.

## Consequences

- Adding a component no longer requires editing a remote root manifest.
- Platform applicability is visible beside each component.
- `doctor` and `plan` can be useful on both supported host families.
- Existing macOS provisioning and integrations can be retained while their
  ownership is incrementally moved into component entrypoints.
- The declaration intentionally stays small. New directives require a schema
  version and tests; arbitrary action commands will not be added to Markdown.

## Simplification and retirement

Herdr convergence has been removed. Project tools are managed with mise, not
ad-hoc lifecycle installers. The copied-skill and KB-adapter capabilities remain
for ownership-checked retirement of prior installations, not new workflows.
See `docs/retirement.md` before integrating source deletions into a live checkout.
Future removal of those capabilities waits for retirement evidence.

## Deferred dependency-state design

Track the cross-platform dependency direction in
[issue #93](https://github.com/tnez/dotfiles/issues/93): declare what a machine
needs independently of how a platform installs it. Dotfiles should inspect and
plan drift, then reconcile approved missing requirements through reviewed
providers. Declaration is not permission for automatic upgrades, removal of
unrelated software, or background convergence.

The declaration format, provider mapping, version policy and migration from the
Brewfile remain design decisions. Preserve mise's project-runtime role and the
existing platform, primary-checkout, approval and trust safeguards. No new schema
or installer is introduced by this note; current provisioning remains unchanged.

## Original delivery plan

1. Record this decision and the no-activation constraint for the current Arch
   host.
2. Add strict module discovery, validation, platform detection, and tests.
3. Add component entrypoints and replace `dotfiles-packages` with local
   declarations.
4. Make read-only lifecycle commands platform-aware while preserving the
   macOS mutation path.
5. Update installer and agent documentation, then run isolated tests and
   read-only checks on Arch.
