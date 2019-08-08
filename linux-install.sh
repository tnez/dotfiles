#!/usr/bin/env sh

PROJECTS_DIR="$HOME/Projects"
CONFIG_DIR="$PROJECTS_DIR/tnez--config"

# install required software
sudo apt install \
  build-essential \
  curl \
  file \
  fish \
  fonts-firacode \
  ghi \
  htop \
  silversearcher-ag \
  tig \
  vim

# install stuff for i3-vim-focus
VENDOR_DIR="$HOME/Vendor"
mkdir "$VENDOR_DIR"
git clone https://github.com/jwilm/i3-vim-focus.git "$VENDOR_DIR/i3-vim-focus"
curl https://sh.rustup.rs -sSf | sh
cd "$VENDOR_DIR/i3-vim-focus/i3-vim-focus"
cargo build --release
cp target/release/i3-vim-focus "$HOME/.cargo/bin"

# install node (and via n version manager)
curl -L https://git.io/n-install | bash
source $HOME/.bashrc
n lts

# symlink stuff
_link() {
  echo "sym-linking $CONFIG_DIR/$1 as $HOME/$2"
  unlink "$HOME/$2" > /dev/null 2>&1
  ln -s "$CONFIG_DIR/$1" "$HOME/$2"
}

mkdir $HOME/.config # if it does not already exist

_link .profile .profile
_link .editorconfig .editorconfig
_link .npmrc .npmrc
_link base16-shell .config/base16-shell
_link chunkwm/config .chunkwmrc
_link ctags/config .ctags
_link fish .config/fish
_link git/gitconfig .gitconfig
_link git/gitignore .gitignore
_link git/git_template .git_template
_link i3 .config/i3
_link i3-regolith .config/i3-regolith
_link kitty .config/kitty
_link scripts bin
_link secrets/.secrets .secrets
_link skhd/config .skhdrc
_link spacemacs/.spacemacs .spacemacs
_link tmux .config/tmux
_link tnez-snippets .config/tnez-snippets
_link vim/config .vimrc

# links that require sudo
sudo ln -s compton/compton.conf /etc/xdg/compton.conf
