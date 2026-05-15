# Pi Coding Agent

This package bootstraps [Pi](https://pi.dev) as another Dottie harness.

- `dot-pi/agent/settings.json` configures model defaults and shared resources.
- `dot-pi/agent/AGENTS.md` gives Pi the same lappy-session identity anchor as
  the other harnesses.
- Shared skills are discovered from `~/.agents/skills` by Pi itself.
- Shared command prompts are loaded from `~/.agents/commands` through settings.

Runtime state, credentials, sessions, caches, and package installs under
`~/.pi/agent` are intentionally left out of dotfiles.
