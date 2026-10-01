# Pi

<!-- dotfiles-module
version 1
platform darwin
platform omarchy
stow no-folding
-->

Stow only personal navigation keybindings and the shared KB instruction link.
Pi's `settings.json` is machine-owned application state; this component ships no
whole-file settings template. Settings preferences in `README.md` are agent
guidance, not a complete target configuration. Do not create, adopt, replace,
or normalize settings during routine dotfiles work. For an explicitly requested
preference change, preserve all unrelated values and obtain approval before
editing live state.

Use upstream retry, compaction, thinking-level, and resource-discovery defaults.
No persistent personal workflow prompts, skills, or automatic extension
installations. On Omarchy, the separate `dev` command may pass a one-shot
project-work context note through the CLI; it does not alter Pi settings,
resources, or project-trust decisions.

Run `bash tests/portable.sh`; validate tracked keybindings JSON and consult the
installed Pi settings/keybindings documentation. Read `README.md` before
activation. Stow only after approval; never adopt or overwrite a local settings
file. On Omarchy activation is manual. Pi can rewrite its settings: review only
approved key changes and preserve auth, sessions, packages, runtime state, and
all unmanaged files.
