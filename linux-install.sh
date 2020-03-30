#!/usr/bin/env sh

PROJECTS_DIR="$HOME/Projects"
CONFIG_DIR="$PROJECTS_DIR/tnez/config"

# install required software
sudo add-apt-repository ppa:kgilmer/speed-ricer
sudo apt update
sudo apt install \
  build-essential \
  compton \
  curl \
  feh \
  file \
  fish \
  flameshot \
  fonts-firacode \
  ghi \
  htop \
  i3-gaps-wm \
  imagemagick \
  kitty \
  libxdo-dev \
  libxdo3 \
  polybar \
  python3-pip \
  rofi \
  silversearcher-ag \
  tig \
  tox \
  vim \
  neovim

sudo snap install hub --classic

# handle software required to be built from recent source code
VENDOR_DIR="$PROJECTS_DIR/vendor"
mkdir "$VENDOR_DIR"

# i3-vim-focus
git clone https://github.com/jwilm/i3-vim-focus.git "$VENDOR_DIR/i3-vim-focus"
curl https://sh.rustup.rs -sSf | sh
cd "$VENDOR_DIR/i3-vim-focus/i3-vim-focus"
cargo build --release
cp target/release/i3-vim-focus "$HOME/.cargo/bin"

# qutebrowser
git clone https://github.com/qutebrowser/qutebrowser.git
"$VENDOR_DIR/qutebrowser"
cd "$VENDOR_DIR/qutebrowser"
tox -e mkvenv-pypi

# install node (and via n version manager)
curl -L https://git.io/n-install | bash
source $HOME/.bashrc
n lts

# install pywal
sudo pip3 install pywal
ln -s ~/.cache/wal/colors.Xresources ~/.Xresources

# symlink stuff
_link() {
  echo "sym-linking $CONFIG_DIR/$1 as $HOME/$2"
  unlink "$HOME/$2" > /dev/null 2>&1
  ln -s "$CONFIG_DIR/$1" "$HOME/$2"
}

mkdir $HOME/.config # if it does not already exist

_link .profile .profile
_link .editorconfig .editorconfig
_link ctags/config .ctags
_link fish .config/fish
_link git/gitconfig .gitconfig
_link git/gitignore .gitignore
_link git/git_template .git_template
_link i3 .config/i3
_link kitty .config/kitty
_link polybar .config/polybar
_link qutebrowser/config.py ./config/qutebrowser/config.py
_link rofi .config/rofi
_link scripts bin
_link secrets/.secrets .secrets
_link tig/tigrc .tigrc
_link tnez-snippets .config/tnez-snippets
_link vim/config .vimrc
_link nvim .config/nvim

# links that require sudo
sudo ln -s compton/compton.conf /etc/xdg/compton.conf
