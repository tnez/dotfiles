# Shared Agent Surface

This package is the canonical home for agent-agnostic behavior.

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
symlinked `SKILL.md` files. Bootstrap materializes shared skill entrypoints into
`~/.agents/skills` after stowing so Codex can discover them while this package
remains the source of truth.
