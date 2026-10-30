# Pi

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow none
-->

Materialize regular config files through `./agent-config`, following
`docs/runbooks/agent-config.md`. `preferences.json` declares owned settings,
not a whole-file template. Merge these keys and the declared keybindings into
application-owned JSON, preserving unrelated values. Materialize shared
instructions from `agents/AGENTS.md`. No Stow activation for this component.
A setup request covers reviewing and preparing the declared end state; apply
requires explicit approval. Restore drift and migrate known links only with
the runbook's additional explicit choices.

Use the model lineup and high reasoning preferences in `README.md`; use upstream
retry, compaction, and resource-discovery defaults.
No persistent personal workflow prompts or automatic extension installations.
The two shared activity skills are an explicit exception, installed separately
through `./agent-skills` as documented in `agents/README.md`; preserve every
other installed skill. `agent-config` does not install skills. On Omarchy, the
separate `dev` command may pass a one-shot project-work context note through the
CLI; it does not alter Pi settings, resources, or project-trust decisions.

Run `python3 tests/agent-config.py`, `bash tests/portable.sh`, and
`bash tests/lifecycle.sh`. Validate declared JSON and consult installed Pi
settings/model/keybindings documentation. Read `README.md` before activation.
Keep Pi settings writers idle during apply. Preserve auth, sessions, packages,
runtime state, theme and unmanaged files. Fresh-session model cycling and
instruction discovery remain native smoke checks, not fixture guarantees.
