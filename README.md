# `@tnez/dotfiles`

Personal macOS dotfiles managed with GNU Stow. The root `dotfiles` executable is
the canonical lifecycle interface.

## New Machine

The default zsh install path uses process substitution so the installer can
read prompts from the terminal instead of consuming a script from standard
input:

```zsh
/bin/bash <(curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/tnez/dotfiles/main/install.sh)
```

The installer defaults to `$HOME/Code/tnez/dotfiles/main`. It safely reuses a
primary checkout at that path or clones the repository, then runs the local
`dotfiles bootstrap` command.

For an inspect-first installation:

```bash
installer="$(mktemp -t dotfiles-install.XXXXXX)"
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/tnez/dotfiles/main/install.sh \
  -o "$installer"
less "$installer"
/bin/bash "$installer"
rm -f "$installer"
```

Agents use an explicit path and noninteractive mode. `--yes` approves only
routine convergence; it never grants third-party formula trust:

```bash
/bin/bash "$installer" \
  --path "$HOME/Code/tnez/dotfiles/main" \
  --non-interactive \
  --yes
```

If bootstrap reports `ACTION_REQUIRED` for a formula, stop and have a human
review it. Reviewed formulae can be approved explicitly on retry:

```bash
/bin/bash "$installer" \
  --path "$HOME/Code/tnez/dotfiles/main" \
  --non-interactive \
  --yes \
  --trust-formula modem-dev/tap/hunk \
  --trust-formula satococoa/tap/wtp
```

## Lifecycle

```text
dotfiles bootstrap   preflight, plan, provision, apply, final doctor
dotfiles doctor      read-only health and conflict checks
dotfiles plan        read-only provisioning and Stow simulation
dotfiles apply       fast configuration and integration convergence
dotfiles provision   install missing dependencies without routine upgrades
dotfiles upgrade     slow, explicit update/upgrade/cleanup
```

Run `dotfiles <command> --help` for command-specific details. After the first
successful apply, `~/.local/bin/dotfiles` points to the canonical checkout, and
`~/.local/bin` is loaded by `profile/dot-profile`.

`doctor` and `plan` are safe in candidate linked worktrees. Every mutating
command refuses a checkout whose `.git` is a file. Merge the change first, then
activate it from the primary checkout whose `.git` is a directory.

The shared `~/.profile` exports
`TNEZDEV_KNOWLEDGE_BASE_ROOT`, defaulting to
`$HOME/Code/tnezdev/knowledge-base/main`. Bash and zsh both load this profile.
Machines using another checkout layout can set the variable in
`~/.profile.local`; `~/.profile.local.example` documents the expected syntax.
`dotfiles doctor` verifies that the variable is set and that its agent and OKF
entrypoints are readable.

Global agent instructions also recognize the optional
`TNEZDEV_LOCAL_CONTEXT_ROOT`. It has no portable default and is not required by
`doctor`. A participating machine may export it from `~/.profile.local` to
advertise a private `AGENTS.md` router; agents consult that router only when a
task needs machine-local operating context.

The `com.tnez.launchd-environment` LaunchAgent loads that same profile at macOS
login and selectively publishes `PATH`, `TNEZDEV_KNOWLEDGE_BASE_ROOT`, and
`TNEZDEV_LOCAL_CONTEXT_ROOT` through `launchctl`. This gives Finder- and
Dock-launched applications the same configured roots without duplicating them
in the LaunchAgent plist. Run `dotfiles apply` after changing the agent or its
script, then fully restart already-running GUI applications so they inherit the
updated environment.

Most edits to already-stowed files are immediately live through their existing
symlinks. Run:

- `dotfiles apply` after adding/removing paths, changing copied files, or
  changing service/integration state
- `dotfiles provision` after adding a dependency or when doctor reports one
  missing
- `dotfiles upgrade` only when intentionally updating installed packages
- `dotfiles bootstrap` for first-time setup or full convergence

`provision` uses this repository's `brew/Brewfile` explicitly, suppresses
Homebrew auto-update in the convergence path, and passes `--no-upgrade`.
Third-party trust is declared formula-by-formula in
`dotfiles-trusted-formulae`; no tap-wide trust is granted.

## Stow Packages

`dotfiles-packages` is the explicit activation manifest. It records every Stow
package and whether it needs `--no-folding`. For packages that remain listed,
apply uses restow semantics to converge links and prune paths removed from that
package without deleting unmanaged regular files.

Removing an entire package from the manifest cannot identify links previously
owned by that package. Before deleting its manifest entry, unstow it from the
primary checkout with the same folding mode recorded in the manifest, verify
the result, then remove the entry:

```bash
stow --dir="$HOME/Code/tnez/dotfiles/main" \
  --target="$HOME" --dotfiles --delete <package>
```

Include `--no-folding` in that command when the manifest records that mode.

`~/.agents/skills` is the only supported shared local skill-discovery root.
Dotfiles-owned shared `SKILL.md` files are materialized because Codex does not
reliably load symlinked entrypoints. Ownership and checksums are recorded in
`~/.local/state/dotfiles/materialized-skills`. Apply removes stale copies only
when that state proves ownership and the file is unchanged. A regular file or
unmanaged symlink at any managed target is reported as a conflict, not
overwritten.

The separate knowledge-base trial exposes only `present-for-decision` as a
whole-directory link:

```text
${TNEZDEV_KNOWLEDGE_BASE_ROOT}/root/skills/present-for-decision
  -> ~/.agents/skills/present-for-decision
```

The knowledge base owns that entire directory, including frontmatter and
supporting files; dotfiles never copies or rewrites it. The adapter requires an
absolute, readable `TNEZDEV_KNOWLEDGE_BASE_ROOT` with `AGENTS.md`,
`root/index.md`, and the trial skill. `doctor` and `plan` validate the source,
its three required context files, managed link, and ownership state read-only.
After integration, run `apply` from the primary checkout to create or repair
the link. The live skill resolves its `/processes/...`, `/principles/...`, and
`/meta/...` required-context links against
`${TNEZDEV_KNOWLEDGE_BASE_ROOT}/root`, as directed by the global agent
instructions and the knowledge-base Agent Consumption Contract; these links
are not host-filesystem-root paths.

Ownership is recorded in
`~/.local/state/dotfiles/knowledge-base-skill-adapter`. An unmanaged symlink,
file, or directory at the adapter path is always a conflict. To retire the
trial, remove its sole declaration from
`dotfiles-knowledge-base-skill-adapter`, review `doctor` and `plan`, then run
`apply` from the primary checkout. Apply removes only the link whose exact
target still matches recorded ownership, removes its state, and leaves the KB
source and unrelated Agents skills untouched.

`~/.claude/skills` is **LEGACY**. Do not add or maintain shared skills there;
the existing Claude package and installed legacy entries are intentionally
deferred to separately reviewed cleanup. There is no Claude adapter for
`present-for-decision`, and Claude Code access to it is out of scope.

Manual Stow operations still require `--dotfiles`, for example:

```bash
stow --dir="$HOME/Code/tnez/dotfiles/main" \
  --target="$HOME" --dotfiles --restow zsh
```

## Homebrew Dependencies

Dependencies are curated in `brew/Brewfile`.

```bash
./scripts/brew-add.sh <formula>
./scripts/brew-add.sh <cask> --cask
dotfiles provision
dotfiles upgrade
```

`dotfiles upgrade` updates Homebrew metadata, upgrades Brewfile dependencies,
and cleans old Homebrew artifacts. It does not prune unrelated installed
packages.
