`@tnez/dotfiles`

This is my collection of personal dotfiles.

# Setting up on a new machine

1. Clone this repo: `git clone https://github.com/tnez/dotfiles.git`
1. Hop into directory: `cd dotfiles`
1. Run the bootstrap script: `./bootstrap.sh`

# Managing individual packages

All packages use the `--dotfiles` flag to convert `dot-` prefixes:

```bash
stow --target=$HOME --dotfiles fish    # Links fish/dot-config/fish → ~/.config/fish
stow --target=$HOME --dotfiles nvim    # Links nvim/dot-config/nvim → ~/.config/nvim
stow --target=$HOME --dotfiles vim     # Links vim/dot-vimrc → ~/.vimrc
stow --target=$HOME --dotfiles git     # Links git/dot-gitconfig → ~/.gitconfig
```

To unstow a package:

```bash
stow --target=$HOME -D --dotfiles fish # Removes fish symlinks
```
