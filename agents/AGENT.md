# Shared agent instructions

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow no-folding
capability materialized-skills
capability knowledge-base-adapter
-->

`AGENTS.md` is the shared instruction source linked by the Codex and Pi packages.
Stow also exposes it at `~/AGENTS.md`. No personal prompts or skills are shipped.

The two Darwin lifecycle capabilities remain solely for safe retirement: the
empty adapter declaration retires only a state-proven KB link, and the empty
skill inventory retires only unchanged checksum-owned copies. Modified copies
are conflicts. Do not delete state files to bypass these ownership checks.

On Omarchy use manual Stow only after approval; copied-skill/adapter retirement
is not automated there. Preserve externally installed skills, especially Dottie,
and the KB itself. See `docs/retirement.md` before integrating deletions.

Verify with `bash tests/lifecycle.sh` and `bash tests/portable.sh`.
