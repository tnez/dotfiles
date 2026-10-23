# Neovim

This is the macOS Neovim configuration, managed by Stow and Lazy. Omarchy's
LazyVim configuration is separate and is not changed by this package.

## Review a checked-out PR locally

Diffview provides a changed-file sidebar and side-by-side diffs in a new Neovim
tab. From the root of the checked-out PR branch:

```sh
nvim -c 'DiffviewOpen origin/main...HEAD'
```

This is the portable launcher: it works in a normal terminal or an existing
tmux pane, without starting or attaching tmux. No alias, shell changes, personal
project paths, GitHub authentication, or tmux dependency are needed.

In Neovim (leader is Space):

| Key / command | Action |
| --- | --- |
| `Space g d` | Open `origin/main...HEAD` for the current repository |
| `Space g D` / `:DiffviewClose` | Close the active Diffview tab |
| `Tab` / `Shift-Tab` | Open the next / previous changed file |
| `:DiffviewFocusFiles` | Focus the changed-file sidebar |
| `:DiffviewToggleFiles` | Toggle the sidebar |
| `g?` | Show Diffview's context-specific keys |
| `]c` / `[c` | Jump between hunks (built-in diff mode) |

The explicit three-dot range compares the merge base of `origin/main` and
`HEAD` to committed `HEAD`, like a PR's Files changed view. It excludes unrelated
changes added only to the base branch and excludes uncommitted local edits.
Both sides are historical snapshots, not editable working-tree buffers.
Diffview still has staging/restoration actions (including `X` in the sidebar);
use the browsing keys above for review, not those mutating actions.
`:DiffviewOpen` **without** a range instead reviews local/index changes; it is
not the PR review shortcut.

### Base ref and prerequisites

- Git >= 2.31 and the locally available base and head commits are required.
  This configuration uses Neovim 0.12 options; use the configured Neovim runtime.
- Lazy installs `sindrets/diffview.nvim`; its revision is in `lazy-lock.json`.
  If missing, restart Neovim with network access or use
  `:Lazy install diffview.nvim`. Do not run a broad plugin update for this.
- Icons are disabled for Diffview to avoid adding a second icon provider.
- `origin/main` is an intentional convenience default, **not** PR-base
  detection. For a PR targeting another branch or a fork's upstream, supply the
  actual base explicitly, e.g. `:DiffviewOpen upstream/develop...HEAD` or
  `nvim -c 'DiffviewOpen upstream/develop...HEAD'`.
- No refs are fetched automatically. A missing/stale ref or shallow history
  requires a deliberate fetch/deepen in that repository before reviewing.
  Check `git merge-base origin/main HEAD` if the range cannot be resolved.
  Do not use the current branch's tracking upstream as an inferred PR base:
  that often names the PR branch itself.

Close the review with `Space g D` to return to the prior editing tab. To undo
this addition, remove only the Diffview spec and its lockfile entry; Gitsigns
and all other plugin state can remain intact. No Stow migration is needed for
an already linked Neovim directory.

## GitHub conversation and review submission

Diffview and the existing Gitsigns integration operate on local Git data. They
do not show GitHub review threads, publish inline comments, or submit reviews.

Start with the already-declared GitHub CLI (`gh`) and a browser handoff:

- `:!gh pr view --web` opens the current branch's PR in the browser for threads,
  inline comments and review submission.
- `:terminal gh pr view` shows the PR summary inside Neovim.
- `:terminal gh pr view --comments` shows conversation comments, not a complete
  replacement for inline review threads.

These commands require `gh` on PATH and access to the repository; private/API
operations need a suitable authenticated account (`gh auth status` checks it).
Browser access uses the browser's own login. Authenticate deliberately when
needed; the dotfiles do not manage credentials or submit reviews.

Octo.nvim is a possible later addition if writing/replying to inline reviews
inside Neovim becomes frequent. It adds a separate GitHub UI/plugin and uses
an authenticated `gh` plus its plugin dependencies. Do not add it merely for
local diffs: the CLI/browser path is the smaller useful starting point.

## Optional agent assistance

A tmux-aware agent can open a dedicated review window in an existing session,
with an explicit checkout directory and the same `nvim -c` command. It should
verify the target session/window and refs, create rather than overwrite a busy
pane, and leave comments/submission under human control. Manipulating tmux is
not needed to make Diffview work and is not available outside tmux without
additional session policy. Prefer the manual command and keys first; no new
skill, session manager, automatic fetching, or review automation is included.

## Verification

```sh
./dotfiles doctor
./dotfiles plan
python3 tests/nvim-diffview.py
```

The native smoke check needs installed Diffview and Lazy checkouts; set
`DIFFVIEW_PATH` / `LAZY_PATH` to use other reviewed copies. It never downloads
plugins. It loads only the Git/Diffview spec through Lazy in an isolated home
and divergent fixture repository, checks the exact merge-base/head revisions,
added/modified/deleted files, sidebar, horizontal two-pane diff, lazy command
and key launch, close behavior, missing-base errors without fallback, empty
ranges, and preservation of dirty/untracked files and the index. It does not
replace an interactive check in the complete configuration.
