# Shared Agent Surface

This package is the canonical dotfiles home for agent-agnostic behavior.

Shared skills, command prompts, and hook scripts live here when their
instructions are independent of a specific harness. Harness packages such as
Claude, Codex, and OpenCode should expose these files with the smallest
possible surface:

- symlink directly when the file format and discovery behavior are compatible
- use a thin wrapper when the harness needs custom frontmatter, tool
  declarations, argument syntax, or discovery paths
- keep runtime state, caches, logs, auth, and app-specific preferences in the
  harness package or out of dotfiles entirely

Codex currently needs special handling for user skill discovery: it can skip
symlinked `SKILL.md` files. `dotfiles apply` materializes shared skill
entrypoints into `~/.agents/skills` after stowing so Codex can discover them
while this package remains the source of truth. Ownership and checksums live in
`~/.local/state/dotfiles/materialized-skills`. Apply removes only unchanged
files recorded there (or current files that exactly match their source); it
never sweeps arbitrary regular `SKILL.md` files.

`~/.agents/skills` is the only supported shared local skill root. The separate
knowledge-base-owned `present-for-decision` trial is a lifecycle-generated
whole-directory link and never enters this copied materializer. See the root
README for its source, ownership, validation, and rollback boundary.

`~/.claude/skills` is **LEGACY**. Existing wrappers are frozen pending separate
cleanup; do not add or maintain shared skills there.
