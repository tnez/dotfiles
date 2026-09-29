# Retiring the pre-simplification configuration

This is a human-approved migration checklist, **not an executable cleanup hook**.
No live migration was performed while preparing the candidate. Read-only checks
and candidate verification do not authorize activation or deletion.

## Before merging into a live Stow checkout

Deleting source files in the primary checkout can instantly leave live links
broken. Do not merge this candidate until each affected host has a retirement
plan and recoverable backup. Keep the old source revision `97158b7` available.

1. From the old primary checkout run doctor and plan. Stop for `ACTION_REQUIRED`.
   Inspect Git status and preserve all uncommitted work, local config, and the
   dotfiles state directory. Do not publish backups containing private data.
2. Inventory **exact link ownership** at the affected paths. Stow packages can
   own a directory link rather than leaf links. `readlink` is evidence; a familiar
   basename is not. Never follow a link while removing or resetting its target.
3. Separately approve removal of only verified repo-owned links. Using the old
   primary checkout and its original Stow mode, first simulate unstow. Review
   each operation before executing it. Do not unstow from the candidate or move
   the old checkout and assume its relative links still work.
4. Whole retired packages: `gh-dash ghostty glow raycast sesh television claude
   opencode herdr hunk hud lazygit`. Each used standard folding.
5. Changed surviving packages with deleted paths: `agents codex pi scripts
   launchagents yazi`. Unstow these before merge as well, then restow surviving
   paths only after approval. `agents`, `codex`, and `pi` used `--no-folding`;
   other packages used standard folding. Ignore `AGENT.md` and the adapter
   manifest just as the lifecycle does. For `agents`, also ignore `SKILL.md`:
   copied skills are not Stow links and must not be treated as such.
6. Preserve unrelated files inside all those directories. Never delete entire
   `~/.claude`, `~/.codex`, `~/.pi`, `~/.agents`, `~/.scripts`, or app config roots.
   Unstow does not authorize removal of regular files, even if identical to a
   previous repo source. Modified copies require an explicit preservation choice.
7. The two retired tmux LaunchAgents may still be loaded. Inspect exact labels
   and origins before any approved unload; do not stop live sessions or unload
   unrelated LaunchAgents. Herdr services/plugins and app installations are not
   removed by the candidate and require separate decisions if no longer wanted.
8. Neovim is unchanged, including guarded Herdr navigation and the Anthropic
   CodeCompanion adapter. Do not remove its dependencies as part of retiring
   standalone agents. Review those choices in the later Neovim decision.
9. Back up runtime-managed agent settings. Removing generated Herdr hook files
   from Git does not edit existing live Codex config/hook references. Review and
   retire references individually; preserve trust, credentials and sessions.
10. Only after ownership review and approved link retirement, integrate the
   candidate. Existing retained symlinks can make settings edits live immediately.

## Copied skills and KB adapter

Retain `~/.local/state/dotfiles/materialized-skills` and
`~/.local/state/dotfiles/knowledge-base-skill-adapter` until retirement completes.
The Darwin lifecycle still contains the old ownership checks. The now-empty
inventories make plan/apply retire only unchanged checksum-owned skill copies
and the exact state-owned KB adapter link. Modified copies and changed targets
remain conflicts. Do not delete ownership records to bypass a conflict.

On Omarchy there is no automated copy/adapter retirement. If any such state was
installed manually, review it separately; do not run the macOS mutation path by
faking the platform. Dottie CLI/config/skills are externally owned and untouched.
The KB checkout is never removed, copied into dotfiles, or rewritten.

## Activation after review

Configure the real KB root in the launching environment first. Review doctor and
plan from the updated primary checkout. On macOS use apply only after approval;
on Omarchy choose reviewed modules and their correct Stow modes manually.
Preserve existing regular config conflicts instead of force-linking them.

An existing Codex config is not reseeded. Existing Pi settings require a reviewed
migration if regular; if already stowed, edits become live when sources change.
Check both agents' instruction discovery and KB reading without a model/network
request where possible. Check native macOS GUI environment inheritance separately.
Omarchy's shell, LazyVim, unmanaged desktop configuration, and Dottie remain intact.

Shell startup now uses mise, not fnm/pyenv. Ensure needed project versions exist
and their configurations are trusted by the user before relying on them. No
runtime migration, installation, trust grant, or package uninstall is automatic.

## Recovery

Keep backups and the old revision until native checks pass. With approval, first
unstow only links owned by the candidate, restore the old source revision, and
restow the old packages with their original modes. Restore modified regular files
from reviewed backups, not blindly from Git. Copied skills and ownership records
must be restored together; do not manufacture ownership for unrelated files.
Re-enable services only after inspecting their previous state. No destructive
reset, forced Stow adoption, or blanket deletion is a recovery procedure.
