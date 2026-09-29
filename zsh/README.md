# Zsh

The macOS shell keeps vi editing (`kj`), history, completion and a few aliases.
`~/.profile` handles the environment; mise activates only in interactive shells.
Use project `mise.toml` files for tool versions and `mise exec -- <command>` in
scripts. There is no fnm/pyenv activation, forced default Node, worktree hook,
background tmux session, or personal workflow helper.

Omarchy's upstream shell configuration is left alone. Do not stow this package
there simply to obtain mise: use the platform's existing integration instead.

Run `bash tests/fnm.sh` (historical filename, now mise/profile regression tests).
Startup smoke tests use disposable homes; never change the login shell as a test.
