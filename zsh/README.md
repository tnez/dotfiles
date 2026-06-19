# Zsh

This package is the daily-driver zsh setup.

Environment and PATH live in `profile/dot-profile` so zsh and bash can share
them. Interactive zsh behavior lives in `zsh/dot-zshrc`.

Migration test:

```bash
stow --target="$HOME" --dotfiles zsh profile
zsh -lic 'echo ok'
```

This package does not change the login shell. After testing manually:

```bash
chsh -s /bin/zsh
```
