---
name: start-work
description: >-
  Acquire or resume an independent activity clone and open its tmux development
  session. Use when asked to spin up a workspace, open a repo for an activity,
  or resume that work. Not for implementing the task, project bootstrap, or
  creating a permanent main checkout.
compatibility: macOS or Omarchy with Git and tmux; dev launcher is optional.
---

# Start work

Prepare the workspace, not the task. A repo identifier and short activity label
are enough. Do not ask for a brief, plan, requirements, or acceptance criteria
for the eventual coding task. Do not send the task or conversation to the new
agent, start coding, or run project bootstrap/dependency installation. Ordinary
launcher guidance to read project instructions is not a task handoff.

## Resolve and inspect

1. Read the invoking project's `AGENTS.md` if applicable. If
   `TNEZDEV_KNOWLEDGE_BASE_ROOT` is available, read its agent guide, bundle index,
   consumption contract and active Repository Checkout Lifecycle. A missing KB
   root is not permission to guess its location; report it and use this skill's
   bounded procedure. Project-specific conventions take precedence.
2. Establish the authoritative URL and an activity label. Accept a URL or an
   unambiguous `owner/repo` on a known host. Do not assume GitHub from a bare
   name, pick between forks, change remotes, or infer repository visibility.
   Ask only about ambiguity that affects acquisition or launch.
3. Default to `~/Work/<owner>/<repo>/<activity>`, using an unused directory.
   Respect a supplied workspace root. Distinguish hosts if owner/repo collides.
   Validate each owner/repo/activity path component: no separators, `.`/`..`,
   leading `-`, shell syntax, or control characters. Derive a readable lowercase
   hyphenated activity label; it need not describe the eventual implementation.
   Quote all command arguments; never evaluate a repo name or pane label as code.
4. Look only in that repository's workspace directory and relevant tmux session
   metadata for matching work; do not crawl HOME. Inspect a candidate's physical
   path, `git remote get-url origin`, branch, `git status --short --branch`, and
   associated sessions/processes. Confirm it is the intended activity and not
   owned by another active worker. Existing directories are never overwritten.
   Offer a clear matching checkout for resume; ask if matches are ambiguous.

## Acquire or resume

A new activity uses an independent clone, not a linked worktree or permanent
anchor. Check Git/network access without changing credentials. Inspect the
remote for an existing branch matching the requested activity before inventing
another branch. If resuming published work, use that exact branch. Missing or
ambiguous refs require a choice, not a fresh branch that loses the existing work.

For a new clone, with resolved variables and an absent destination:

```sh
git clone -- "$remote_url" "$checkout_path"
git -C "$checkout_path" fetch origin --prune
```

Read the clone's `AGENTS.md` and documented branch conventions before choosing
its activity branch. Do not execute repository setup scripts or grant project
trust. Default to `feat/<activity>` only when no documented convention applies;
use `fix/`, `docs/`, etc. when the user has clearly identified that kind of work.
Validate the branch with `git check-ref-format --branch "$branch"` and reject
leading `-`. For a new activity, verify `refs/remotes/origin/main` exists; do not
silently substitute the remote's default branch. Then:

```sh
git -C "$checkout_path" switch --no-track -c "$branch" origin/main
git -C "$checkout_path" rev-parse HEAD
```

For a requested published branch, verify its exact remote ref and instead use:

```sh
git -C "$checkout_path" switch --track -c "$branch" "origin/$branch"
```

For an existing checkout, inspect staged, unstaged and untracked state before
any branch/update operation. Resume the current matching branch without resetting,
rebasing, pulling, or discarding work. Fetch only when needed to resolve remote
state; if offline, say it is unverified. Do not switch a dirty or busy checkout
into another activity. Unpublished work cannot be recovered by a remote clone.

A partial clone or failed launch is retained and reported, not automatically
removed. Retry only after verifying the actual path, remote, branch, and state.

## Open the session

Read [the tmux launch procedure](references/tmux.md) before acting. It handles
Scout's nested popup without switching its client or sending keys into an
existing shell. Use an installed, reviewed `dev` launcher if suitable; it creates
the session itself. Do not create a duplicate session first. Otherwise create a
plain shell session rooted in the checkout. Never run `dev resize` during entry.

Where launch requires missing tools, stop with the checkout path and blocker;
do not install tools or modify machine configuration as a side effect. Starting
an editor/Pi normally may invoke their existing user configuration; this skill
neither changes that configuration nor adds project trust.

## Verify and finish

Read back the actual checkout remote, branch and HEAD, session identity, checkout
marker, and originating client's session. For new work, record the selected base
commit before any implementation. Report checkout, branch, base (or current
revision for resumed work), session and any blocker. Do not claim a shell session
proves the application is bootstrapped or ready to test. Do not write a task
brief or inject a message into the project agent. The user thinks there.

Installation of this skill and cleanup of workspaces require their own approval;
opening work does not authorize pushing, publishing, deletion, or live dotfiles
activation.
