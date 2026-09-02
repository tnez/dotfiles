# Agents component

<!-- dotfiles-module
version 1
platform darwin
stow no-folding
capability materialized-skills
capability knowledge-base-adapter
-->

## Desired state

The files in this directory are the source of truth for the `agents`
configuration activated with GNU Stow on `darwin` hosts.

## Operations

- Review `dotfiles plan`, then use `dotfiles apply` from the canonical primary
  checkout to restow shared commands and converge owned skills.
- `materialized-skills` copies repository `SKILL.md` files into
  `~/.agents/skills` with checksum ownership because Codex does not reliably
  discover symlinked entrypoints.
- `knowledge-base-adapter` manages the declared whole-directory trial adapter;
  `dotfiles doctor` validates its source, target, and ownership state.

## Agent guidance

Never overwrite unmanaged skill files or directories. A modified managed copy
is a conflict, not disposable output. Preserve knowledge-base source content
and require exact ownership evidence before repairing or retiring an adapter.
