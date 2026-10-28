# Shared agent instructions

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow none
capability materialized-skills
capability knowledge-base-adapter
-->

`AGENTS.md` declares the shared instructions. `./agent-config` materializes
regular files at `~/AGENTS.md`, `~/.codex/AGENTS.md`, and
`~/.pi/agent/AGENTS.md`; Stow does not activate this component.
See `docs/runbooks/agent-config.md` for inspection, approval, migration,
verification and recovery. No personal prompts or skills are shipped.

The two Darwin lifecycle capabilities remain solely for safe retirement: the
empty adapter declaration retires only a state-proven KB link, and the empty
skill inventory retires only unchanged checksum-owned copies. Modified copies
are conflicts. Do not delete state files to bypass these ownership checks.

On Omarchy copied-skill/adapter retirement is not automated. Preserve externally
installed skills, especially Dottie, and the KB itself. See `docs/retirement.md` before integrating deletions.

The old `./omarchy-agent-links` recovery mutator is retired. Its `check`
command redirects to the materialized-state check; existing hooks cannot
recreate links. Disable verified old hooks as documented in the runbook.
This component does not own `.agents` or install skills.

Verify with `bash tests/lifecycle.sh` and `bash tests/portable.sh`; test the
focused runbook with `python3 tests/agent-config.py` and the legacy refusal
boundary with `python3 tests/omarchy-agent-links.py`.
