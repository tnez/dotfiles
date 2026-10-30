---
name: clean-up-work
description: >-
  Inspect and safely retire an activity checkout and its associated tmux session.
  Use when asked to clean up, finish with, or remove a work workspace. Verify
  preservation and obtain exact removal approval; never infer deletion from
  closing a session, merging a PR, or a clean git status.
compatibility: macOS or Omarchy with Git, tmux, and process inspection tools.
---

# Clean up work

Disposable workspaces must not mean disposable work. Inspect first, explain the
proposed removal, obtain explicit approval, recheck, then remove only what was
approved. Do not push, publish, open/close PRs, copy secrets, reset, clean, force
remove, or delete branches as an implicit part of cleanup.

## Identify and protect

1. Resolve the exact activity checkout from the user's path/name and bounded
   repo workspace directory/session metadata. Ask about ambiguous matches; do
   not crawl HOME. Read the target project's `AGENTS.md`. Load the active
   Repository Checkout Lifecycle via the configured KB entrypoints if available;
   do not guess another KB checkout when its root is missing.
2. Verify physical path, remote, branch/HEAD, and `git rev-parse --show-toplevel`.
   Require the selected path to be the exact checkout root, not a parent, home,
   workspace collection, symlink, or redirected directory. Treat paths and tmux
   labels as data, quote them, and reject traversal/control characters.
3. This skill retires independent activity clones. Inspect the Git common
   directory and `git worktree list --porcelain`. Linked worktrees, anchors with
   dependent worktrees, submodules, nested repositories, mounts, or unclear
   ownership need a separate reviewed cleanup; do not recurse through them.
4. Protect the canonical dotfiles source (including this installed skill's
   resolved source), configured `TNEZDEV_KNOWLEDGE_BASE_ROOT` and optional local
   context root, and any checkout backing live configuration/skill links. A
   directory under `~/Work` is not proof of disposability. Inspect relevant
   known link destinations; if infrastructure dependencies are uncertain, retain
   the checkout. Do not relocate source anchors as part of activity cleanup.
5. Verify associated tmux sessions by exact `@activity_checkout` or the reviewed
   dev launcher's `@dev_workflow_root`, plus actual pane paths/processes. A name
   prefix is not ownership. Scout's `@dotfiles-agent-popup` session, its history,
   other workspaces, and foreign sessions are never cleanup targets. Mixed-use
   sessions or processes belonging to another worker require a decision.

## Inspect preservation and activity

Read [the preservation checklist](references/preservation.md) and execute its
applicable inspections. Inventory staged/unstaged, untracked and ignored files,
all local branches, detached/reflog work, stashes, and local services/databases.
Inspect metadata and filenames first; do not dump secrets or entire pane output.
A clean status, configured upstream, old push message, or closed/merged PR is
not sufficient preservation evidence.

Identify where every result that must survive is preserved, and verify its
commit identity/content at that destination. Distinguish a local-only handoff
from durable off-machine preservation. Fetching/reading the selected remote is
allowed for verification; publishing is not. If offline or destination access
is unavailable, report the verification gap and retain the checkout.

Inventory all relevant panes, agents, workers and services before stopping
anything. Use process ancestry, cwd and open-file information on the host
(e.g. `lsof` when available), not just the foreground pane command. Inspect only
the relevant tree. If tools cannot establish whether it is still in use, stop
and report the missing check rather than treating it as idle.

## Propose, approve, and quiesce

Give a concise proposal with:

- Exact checkout and verified session IDs, plus processes that would stop.
- Preservation evidence for commits and non-Git artifacts, with its limits.
- Named ignored/generated state that can be reconstructed versus unique state.
- Any uncertainty or unpreserved work, and the precise decision needed.

If work is unpreserved, retain it and offer preservation or explicit discard as
separate choices. Generic "clean up" is not approval to discard named unique
state. Never publish work to make a deletion check pass.

Obtain explicit approval of the exact removal and process stops. If quiescing a
worker/service has not been approved, do not interrupt it. Stop only approved
processes gracefully, without sending arbitrary keys into another agent. If a
process will not stop, do not escalate to a force kill; retain and report.
Reinspect files/refs after workers stop; request renewed approval for newly found
state. Detaching a tmux client alone does not stop its processes.

## Remove and verify

Immediately before deletion, recheck the physical path, remote, HEAD, all refs,
status, untracked/ignored inventory and relevant file contents, stash/reflog
state, mounts, links and processes against the reviewed state. Use private
snapshots/digests when necessary without publishing payloads. Changed state or
uncertain preservation means stop; do not race a writer or force cleanup.

After those checks, remove only approved, verified activity sessions by exact
session ID. Do not kill the server or Scout. Recheck the now-quiescent checkout
and remove only that exact directory using an operation that does not follow
symlinks. Never use glob deletion, a parent-directory removal, `git clean -fdx`,
`git reset --hard`, forced worktree removal, or broad `pkill`/`kill-server`.
An approved deliberate discard must name the affected unique state explicitly.

Verify the exact directory and approved sessions are absent, the preservation
destination still contains the required results, and protected/unrelated
sessions remain. Leave parent directories, credentials, skills, history, and
remote branches alone. If any step fails, report the partial result and retained
path; do not conceal failure by broadening deletion. Return a short completed,
retained-with-blocker, or partially-completed summary.
