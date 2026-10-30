# Preservation evidence before removal

Run these only against the resolved, verified activity root. Commands gather
facts, not automatic permission to delete. Treat filenames/labels as data and
avoid dumping credential/config contents. Use NUL-delimited output when
processing filenames programmatically.

## Files, refs and hidden work

```sh
git -C "$checkout_path" remote -v
git -C "$checkout_path" status --short --branch
git -C "$checkout_path" diff --stat
git -C "$checkout_path" diff --cached --stat
git -C "$checkout_path" ls-files --others --exclude-standard -z
git -C "$checkout_path" ls-files --others --ignored --exclude-standard -z
git -C "$checkout_path" for-each-ref --format='%(refname) %(objectname)'
git -C "$checkout_path" rev-parse HEAD
git -C "$checkout_path" stash list
git -C "$checkout_path" reflog --all --format='%H %gs'
git -C "$checkout_path" fsck --full --no-reflogs --unreachable
git -C "$checkout_path" worktree list --porcelain
```

Check all local branches, not only the current branch. Reflogs and unreachable
commits can hold work after a reset or detached session. Inspect relevant
unreachable commits/blobs rather than assuming they are disposable; stop if
unique work cannot be classified. Inventory nested repos, submodule metadata,
ignored files, symlinks and mount points without following them outside the
checkout. Opaque subdirectories or incomplete inspection are blockers.

Ignored does not mean generated. `.env`, local databases, private evidence,
notes, and ignored plans may need preservation or an explicit discard decision.
Never copy them elsewhere without authority; never attach their raw contents to
a public receipt. Reconstructible dependencies/build outputs can be identified
by name and documented regeneration procedure.

## Verify a destination, not a story

For the user-selected authoritative remote, refresh refs and verify the current
remote tips rather than trusting stale tracking refs:

```sh
git -C "$checkout_path" fetch origin --prune
git -C "$checkout_path" ls-remote --heads --tags origin
```

Confirm the remote URL and fetched tips match the intended destination. For each
local result commit, check that it is reachable from a currently verified
remote ref (`git merge-base --is-ancestor "$commit" "$verified_tip"`). Do not
count a stale ref or an unrelated remote. A local `git log --all --not --remotes`
is useful triage, not independent proof the remote still preserves the work.
Tags/other local refs and detached work also need accounting.

Squash/rebase integration may not preserve original commit IDs. Require verified
content/integration evidence and an explicit decision about losing local history;
do not declare work lost or disposable solely from an ancestry check. If a
result exists only in another local clone, verify it there and say that this is
local-only preservation, not recovery after host loss.

For non-Git artifacts, verify the approved handoff's actual content, not merely
that a destination folder exists. If any required artifact has no authorized,
verified destination, retain the checkout. Stashes are not transferred by clone.

## Processes and final recheck

Use explicit tmux socket/session/pane IDs. List relevant pane IDs, physical cwd,
foreground command and pane PID; inspect descendants and relevant open files.
Account for detached services and another session whose cwd/files use the same
checkout. Session markers alone are not proof no other process uses it.

After approved graceful stops, repeat the file/ref/process inspection and
compare with the approved inventory, including file contents, not just names
or counts. A running writer or ambiguous state blocks deletion. Filesystem
inspection and model instructions are not a security sandbox or atomic snapshot;
if a stable, quiescent state cannot be established, do not remove it.
