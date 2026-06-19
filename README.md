`@tnez/dotfiles`

This is my collection of personal dotfiles.

# Setting up on a new machine

1. Clone this repo: `git clone https://github.com/tnez/dotfiles.git`
1. Hop into directory: `cd dotfiles`
1. Run the bootstrap script: `./bootstrap.sh`

# Managing Homebrew dependencies

Dependencies are tracked in `/Users/tnez/Code/tnez/dotfiles/brew/Brewfile` and managed via `brew bundle`.

## Adding a new package

```bash
./scripts/brew-add.sh <package>          # For formulas
./scripts/brew-add.sh <package> --cask   # For casks
```

Then manually:
1. Edit `/Users/tnez/Code/tnez/dotfiles/brew/Brewfile` to add description comment
2. Place entry alphabetically within its section
3. Commit: `git add brew/Brewfile && git commit -m 'chore(brew): add <package>'`

## Upgrading packages

Weekly or as needed:

```bash
./scripts/brew-upgrade.sh
```

This upgrades all installed packages.

- **Brewfile**: Desired packages (manually curated, commented, alphabetized)
- Run `brew bundle install --global` to converge the machine on the Brewfile
- Run `brew bundle cleanup --force --file=brew/Brewfile` when you intentionally want to prune packages not listed there

# Managing stow packages

All packages use the `--dotfiles` flag to convert `dot-` prefixes:

```bash
stow --target=$HOME --dotfiles profile # Links profile/dot-profile → ~/.profile
stow --target=$HOME --dotfiles zsh     # Links zsh/dot-zshrc → ~/.zshrc
stow --target=$HOME --dotfiles nvim    # Links nvim/dot-config/nvim → ~/.config/nvim
stow --target=$HOME --dotfiles vim     # Links vim/dot-vimrc → ~/.vimrc
stow --target=$HOME --dotfiles git     # Links git/dot-gitconfig → ~/.gitconfig
```

To unstow a package:

```bash
stow --target=$HOME -D --dotfiles zsh  # Removes zsh symlinks
```
