# Herdr workflow

Repository work uses one Herdr workspace per repository and one tab per Git
checkout. The primary checkout is the `main` tab. Linked worktrees use their
branch names as tab labels.

`herdr-session.sh` opens repository containers at their primary `main/`
checkout and creates or focuses worktree tabs by checkout path.

`herdr-worktree-start.sh` is the agent-facing delegation boundary. It uses
`wtp` to create a branch worktree, creates a tab in the repository's existing
Herdr workspace, starts a worker agent, and submits a prompt read from standard
input. It does not infer task intent or remove completed work. If orchestration
fails after checkout creation, it reports the recovery path and leaves the new
worktree and tab intact for inspection.

## Validate a candidate worktree

From the candidate dotfiles worktree, set its path without changing the live
Stow links:

```bash
candidate="$(git rev-parse --show-toplevel)"
```

Verify that a repository container resolves to its primary checkout:

```bash
"$candidate/scripts/dot-scripts/herdr-session.sh" \
  --resolve "$HOME/Code/tnez/dotfiles"
```

From an agent running in the repository's Herdr workspace, validate delegation
prerequisites without creating a branch, tab, or agent:

```bash
"$candidate/scripts/dot-scripts/herdr-worktree-start.sh" \
  --check \
  --repo "$HOME/Code/tnez/dotfiles/main"
```

Open the candidate worktree as a tab in the existing `dotfiles` workspace:

```bash
"$candidate/scripts/dot-scripts/herdr-session.sh" "$candidate"
```

Close that tab through Herdr when finished. Closing a tab does not remove the
Git worktree.

Test candidate configuration in an isolated Herdr session:

```bash
HERDR_CONFIG_PATH="$candidate/herdr/dot-config/herdr/config.toml" \
  herdr --session dotfiles-validation
```

After detaching from the validation session, remove its runtime state:

```bash
herdr session stop dotfiles-validation
herdr session delete dotfiles-validation
```

## End-to-end worker check

Run this from a coordinating agent in the `dotfiles` workspace. The worker is
asked to report context without modifying files:

```bash
prompt='Validation only. Read AGENTS.md, report your current branch and working directory, and make no changes.'
printf '%s\n' "$prompt" |
  "$candidate/scripts/dot-scripts/herdr-worktree-start.sh" \
    --repo "$HOME/Code/tnez/dotfiles/main" \
    --branch chore/validate-herdr-delegation \
    --agent-name dot-validate
```

Keep the returned JSON. After the worker finishes, verify the checkout is clean,
close the returned tab, and remove the disposable worktree:

```bash
git -C "$HOME/Code/tnez/dotfiles/chore/validate-herdr-delegation" status --short
herdr tab close RETURNED_TAB_ID
wtp remove --with-branch chore/validate-herdr-delegation
```

Run the final `wtp` command from any checkout in the dotfiles repository. Do not
remove the validation worktree if its status is not clean.

## Activate after merge

From the updated primary dotfiles checkout, run `./dotfiles apply` to install
the new script and shared skill and reload Herdr configuration. Restart any
running agent application afterward so it discovers the new skill and global
agent instructions. If the behavior needs to be reverted, revert the dotfiles
change, rerun `./dotfiles apply`, and reload or restart the affected agent
applications.
