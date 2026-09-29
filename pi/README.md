# Pi

Keep the OpenAI Codex provider/model preference, system theme, telemetry opt-out,
quiet startup, tool-hidden tree view, Alt-h/j/k/l navigation and a tree shortcut.
The installed Pi 0.87.1 settings/keybindings reference confirms the removed
thinking-level, retry, compaction, external-editor, follow-up, dequeue and newline
settings duplicate defaults. The old changelog version was runtime bookkeeping.
The personal prompt/skill references and pi-docparser declaration are retired;
no installed extension or skill is deleted by this change.

`AGENTS.md` links to `agents/AGENTS.md`. KB content stays in its own checkout.
Configure `TNEZDEV_KNOWLEDGE_BASE_ROOT` in the launching environment as described
in the root README; no Dottie or Herdr bridge is needed for direct KB access.

Pi itself is installed separately using the supported platform or mise provider.
Credentials, sessions, caches, and package installations remain machine-owned.
Stow uses no-folding so it doesn't take over the entire `~/.pi/agent` directory.
It still refuses an existing regular settings file. Back up and review it before
any approved migration. Pi writes settings; inspect `git diff` after UI changes.
