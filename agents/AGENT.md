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
verification and recovery. No persistent personal prompts are shipped.
`skills/start-work` and `skills/clean-up-work` are explicitly owned activity
skills, installed separately by `./agent-skills`; see `README.md` for use,
inspection, approval, verification and recovery.

The two Darwin lifecycle capabilities remain solely for safe retirement: the
empty adapter declaration retires only a state-proven KB link, and the empty
skill inventory retires only unchanged checksum-owned copies. Modified copies
are conflicts. Do not delete state files to bypass these ownership checks.

On Omarchy copied-skill/adapter retirement is not automated. Preserve externally
installed skills, especially Dottie, and the KB itself. See `docs/retirement.md` before integrating deletions.

The old `./omarchy-agent-links` recovery mutator is retired. Its `check`
command redirects to the materialized-state check; existing hooks cannot
recreate links. Disable verified old hooks as documented in the runbook.
This component does not own the `.agents` directory. `./agent-skills` owns only
the two documented leaf directory links; the legacy lifecycle materializer must
not discover or retire them.

Validate the activity skills with `python3 tests/agent-skills.py` and
`python3 tests/work-session-skills.py`; perform native discovery and a disposable
Scout walkthrough only after approved installation. Skills are instructions,
not a permission sandbox; fixture commands do not prove model judgment.

Verify with `bash tests/lifecycle.sh` and `bash tests/portable.sh`; test the
focused runbook with `python3 tests/agent-config.py` and the legacy refusal
boundary with `python3 tests/omarchy-agent-links.py`.
