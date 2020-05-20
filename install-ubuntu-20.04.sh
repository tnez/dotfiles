#!/usr/bin/env sh

PROJECTS_DIR="$HOME/Projects"
CONFIG_DIR="$PROJECTS_DIR/tnez/config"

# install required software
sudo add-apt-repository ppa:kgilmer/speed-ricer
sudo add-apt-respository ppa:lazygit-team/release
sudo apt update
sudo apt install \
  alsa-utils \
  arandr \
  build-essential \
  compton \
  curl \
  fd-find \
  feh \
  file \
  fish \
  firefox \
  flameshot \
  fonts-firacode \
  ghi \
  gnome-flashback \
  htop \
  i3-gaps-wm \
  imagemagick \
  jq \
  keyutils \
  kitty \
  lazygit \
  libxdo-dev \
  libxdo3 \
  polybar \
  pulseaudio \
  python3-pip \
  python3-venv \
  rofi \
  silversearcher-ag \
  tig \
  vim \
  neovim \
  xclip \
  xdotool \
  xdg-utils \
  xdg-desktop-portal-dtk

sudo snap install bw
sudo snap install go --classic
sudo snap install hub --classic
sudo snap install slack --classic
sudo snap install spotify

# handle software required to be built from recent source code
VENDOR_DIR="$PROJECTS_DIR/vendor"
mkdir "$VENDOR_DIR"

# bitwarden-rofi
git clone https://github.com/mattydebie/bitwarden-rofi.git "$VENDOR_DIR/bitwarden-rofi"
cd "$VENDOR_DIR/bitwarden-rofi"
sudo install -D --mode=755 --group=root --owner=root bwmenu /usr/local/bin/bwmenu
sudo cp lib-bwmenu /usr/local/bin
cd "$HOME"

# i3-gnome-flashback
git clone https://github.com/deuill/i3-gnome-flashback "$VENDOR_DIR/i3-gnome-flashback"
cd "$VENDOR_DIR/i3-gnome-flashback"
sudo make install
cd "$HOME"

# i3-vim-nav
go get -u github.com/tnez/i3-vim-nav

# qutebrowser
git clone https://github.com/qutebrowser/qutebrowser.git "$VENDOR_DIR/qutebrowser"
cd "$VENDOR_DIR/qutebrowser"
python3 scripts/mkvenv.py
cd "$HOME"

# install node (and via n version manager)
curl -L https://git.io/n-install | bash
source $HOME/.bashrc
n lts

# install pywal
sudo pip3 install pywal
ln -s ~/.cache/wal/colors.Xresources ~/.Xresources

# install virtualfish
pip3 install virtualfish
vf install

# symlink stuff
_link() {
  echo "sym-linking $CONFIG_DIR/$1 as $HOME/$2"
  unlink "$HOME/$2" > /dev/null 2>&1
  ln -s "$CONFIG_DIR/$1" "$HOME/$2"
}

mkdir $HOME/.config # if it does not already exist

_link .profile .profile
_link .editorconfig .editorconfig
_link compton .config/compton
_link ctags/config .ctags
_link fish .config/fish
_link git/gitconfig .gitconfig
_link git/gitignore .gitignore
_link git/git_template .git_template
_link i3 .config/i3
_link kitty .config/kitty
_link polybar .config/polybar
_link qutebrowser/config.py .config/qutebrowser/config.py
_link rofi .config/rofi
_link scripts bin
_link secrets/.secrets .secrets
_link tig/tigrc .tigrc
_link tnez-snippets .config/tnez-snippets
_link vim/config .vimrc
_link nvim .config/nvim
_link wallpapers .config/wallpapers
_link xinit/config.sh .xinitrc

# links that require sudo
sudo ln -s compton/compton.conf /etc/xdg/compton.conf

# change default shell
sudo chsh -s /usr/bin/fish
