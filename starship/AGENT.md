# Starship component

<!-- dotfiles-module
version 1
platform darwin
stow standard
-->

## Desired state

The files in this directory are the source of truth for the `starship`
configuration activated with GNU Stow on `darwin` hosts.

The prompt is two lines, entirely left-aligned. The first line shows the short
hostname in square brackets (also locally), project/checkout and relative
directory, actual Git branch (or `@commit` when detached), and nonzero Git
status counts. The second line is only `❯`, green on success and red after a
failed command. No right
prompt, runtime versions, cloud context, or tmux status changes are included.

Directory rendering uses native Starship plus a small project prefix:

- Ordinary repositories show their checkout name and relative path.
- In the `project/main` layout, retain `project/main`, not just `main`.
- Linked worktrees use the primary checkout's project name plus their own
  directory name. If the primary is named `main`, its parent names the project.
- Outside Git, show the directory path with home abbreviated to `~`.

Git indicators are `+` staged, `!` modified, `?` untracked, `=` conflicted,
`✘` deleted, `»` renamed, `~` type-changed, `↑` ahead, and `↓` behind, each
followed by a count. Clean working trees with no upstream divergence show no
status indicators. Stash counts are intentionally omitted.

## Operations

- Install or update configuration with `dotfiles apply` from the canonical
  primary checkout after reviewing `dotfiles plan`.
- Check declaration, target, and link health with `dotfiles doctor` and
  `dotfiles plan`.
- Install or update application binaries through the platform provider; on
  macOS, the declared provider inventory is `brew/Brewfile`.
- Run `python3 tests/starship.py` with Starship and Git installed. It renders
  the native prompt in disposable repositories, covering normal and linked
  checkouts, nested paths, detached/unborn branches, status counts, non-Git
  directories, failure color, and the empty right prompt.
- Run `bash tests/portable.sh` and `bash tests/lifecycle.sh` for retained Stow
  and lifecycle safety. Validate the embedded POSIX shell with `sh -n` and
  ShellCheck when changing the custom project prefix.
- Existing Stow links make source edits visible on the next prompt redraw;
  no shell restart, tmux reload, or lifecycle activation is needed. Visually
  check wrapping and text selection in the actual terminal after editing.
- To recover, restore the prior version of this component's TOML file. Preserve
  the existing link and unrelated host configuration.

## Agent guidance

Preserve unmanaged files and machine-local state. Read any colocated README
and inspect the target application’s current configuration before changing
this component. Do not infer consent for destructive migration or package
trust decisions.
