# Shared dev launcher

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow no-folding
-->

## Desired state

Own only `~/.local/bin/dev`, installed from `dot-local/bin/dev`. macOS and
Omarchy use the same Bash/tmux launcher, layout and ownership metadata. This
component does not own the containing directories, shell configuration, tmux
configuration, editor configuration or any running session.

Run `dev` from the chosen directory to start or resume a project session. It
uses the physical directory, without inspecting Git, creating branches/worktrees,
running project startup scripts, installing software or granting project trust.
Dependencies are Bash (including macOS 3.2), tmux, Neovim, Pi, and either
`sha256sum` or `shasum`. `dev resize` additionally needs `realpath` and a usable
Pi default model. No new dependencies are installed by the launcher.

## Layout and re-entry

- A new owned `dev-*` session starts Neovim in its `dev` window, initially
  focused, with Pi and a shell rooted in the same directory.
- Reserve 120 columns and 50 rows for editing. At 201–220 columns, Pi takes
  the remaining 80–99 columns on the right; at 221+ it takes 100. Below 201,
  use an `agent` window. At 66+ usable rows, use a full-width bottom shell
  15 rows high; otherwise use a `shell` window. Status rows are not usable.
  These two fallback decisions are independent.
- Inside tmux, measure the full dimensions of the unique client displaying
  the invoking pane, not that pane's dimensions. Outside tmux, read stdin's
  terminal size. Missing/invalid size fails before new-session creation.
- Re-entry matches canonical directory ownership, including renamed sessions,
  and leaves existing processes, windows and manually adjusted layouts alone.
  Name collisions, incomplete sessions and ambiguous clients are refused,
  never adopted or repaired. Normal tmux sizing remains in effect.
- Pi receives only a one-shot general project context note. Its normal KB root,
  model, settings, credentials and resource discovery remain machine-owned.

After changing screens, `dev resize --check` previews a refit without mutation;
`dev resize` approves preview followed by application to verified `dev-*`
roles only. The wrapper delegates to default headless Pi using
[the layout runbook](../docs/runbooks/dev-layout.md). It requires an attached,
unique invoking client and the canonical primary checkout on macOS or Omarchy.
The launcher sends no task or model prompt on bare entry; the resize subcommand
does make a model request. Inspect its summary: a Pi exit code alone
is not proof of successful refitting. Preserve process IDs, other sessions and
normal sizing. No watcher, hook, automatic reset or separate layout engine.

## Install, check and migrate

Run `./dotfiles doctor` and `./dotfiles plan` before activation. Use the canonical
primary checkout, never a disposable worktree. On macOS, approved
`./dotfiles apply` installs the shared component; a package-only install works on either
host after reviewing its simulation and obtaining approval:

```sh
repo=$(git rev-parse --show-toplevel)
stow --dir="$repo" --target="$HOME" --dotfiles --no-folding \
  --ignore='^(AGENT[.]md|README.*)$' --simulate --verbose dev
# After reviewing the simulation and obtaining approval:
stow --dir="$repo" --target="$HOME" --dotfiles --no-folding \
  --ignore='^(AGENT[.]md|README.*)$' dev
```

Do not activate the whole Omarchy package on macOS. Never adopt or overwrite
an existing command. Verify the installed leaf's exact target and `dev --help`;
no tmux reload or restart is needed. Creation/re-entry should be smoke-tested in
a disposable directory/server first, using inert editor/agent fixtures rather
than altering live sessions. Live refitting requires its separate invocation.

Existing Omarchy installations can still link to
`omarchy/dot-local/bin/dev`. That source is retained as a forwarding wrapper,
ignored by new Omarchy Stow operations, so updating Git does not strand the old
link. To transfer ownership, inspect the leaf **and its parent directories**.
After approval, remove only a verified legacy leaf link, then simulate/install
`dev` as above. Keep regular files and foreign links unchanged. If a parent is
itself a folded Stow link, stop and review an unfolding migration; never unlink
files through that directory link or unstow the entire desktop blindly. Until
migration, the legacy wrapper continues to work from the same checkout.

## Validation and recovery

- `bash tests/dev.sh`: layouts, re-entry, collisions, failures and preservation.
- `python3 tests/dev-layout.py`: real PTYs, terminal dimensions and unique-client
  targeting on a private tmux server, with inert Neovim/Pi; no model requests.
- `bash tests/dev-resize.sh`: both supported platform handoffs and refusal paths
  using fake Pi/clients; not proof of model judgment or real refit success.
- `bash tests/dev-stow.sh`: initial/repeated Stow, exact leaf ownership,
  unmanaged conflicts, legacy-link migration and unstow preservation.
- `bash tests/modules.sh`, `bash tests/portable.sh`, `bash tests/omarchy.sh`,
  `bash tests/lifecycle.sh`, and `python3 tests/work-session-skills.py` cover
  consumers. Portable tests require Python 3.11+. Use existing installed tools;
  do not install tools merely to hide a verification gap.
- Check syntax with `/bin/bash -n` and ShellCheck; run native macOS checks and
  retain separate Omarchy runtime verification where unavailable.

To remove the command after approval, simulate then unstow only `dev` with the
same options used for installation. Verify exact ownership first, preserve
unmanaged commands/directories and do not stop sessions created by the launcher.
Rollback of a legacy migration may restore only the reviewed old link while its
wrapper and shared source still exist. Restore the prior launcher revision to
undo code behavior; existing sessions/layouts are not automatically rolled back.
