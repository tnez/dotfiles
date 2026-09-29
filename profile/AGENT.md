# Shared profile

<!-- dotfiles-module
version 1
platform darwin
stow standard
-->

POSIX environment for the managed macOS Bash/Zsh shells and GUI environment
bridge. Prepend existing Homebrew/local-bin/mise-shim directories once. No tool
installation, project trust, or version selection occurs here. Interactive mise
hooks belong in `.bashrc`/`.zshrc`; scripts should use `mise exec -- command`.

Machine choices live in unmanaged `~/.profile.local`, loaded last. In particular,
set `TNEZDEV_KNOWLEDGE_BASE_ROOT` explicitly to the local KB checkout. There is no
portable default checkout layout. The example is not an active configuration.

Do not stow over Omarchy's shell/profile files. Its native shell owns mise setup;
export the KB variable through its existing user configuration after approval.

Check with `sh -n`, `bash tests/fnm.sh`, and `bash tests/lifecycle.sh`. The fnm test
filename is retained for existing callers, but tests mise and profile behavior.
