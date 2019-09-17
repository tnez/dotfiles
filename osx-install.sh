#!/usr/bin/env sh

CONFIG_DIR="$HOME/Projects/tnez--config"

# install brew...
/usr/bin/ruby -e \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# ...and all it's brew buddies
brew bundle

# symlink from config dir to home dir
# $1: item to be symlinked (tnez--config/<path>)
# $2: resulting link ($HOME/<path>)
_link() {
  echo "sym-linking $CONFIG_DIR/$1 as $HOME/$2"
  unlink "$HOME/$2" > /dev/null 2>&1
  ln -s "$CONFIG_DIR/$1" "$HOME/$2"
}

mkdir $HOME/.config # if it does not already exist

_link .editorconfig .editorconfig
_link base16-shell .config/base16-shell
_link ctags/config .ctags
_link fish .config/fish
_link git/gitconfig .gitconfig
_link git/gitignore .gitignore
_link git/git_template .git_template
_link scripts bin
_link secrets/.secrets .secrets
_link tnez-snippets .config/tnez-snippets
_link vim/config .vimrc


# install node version manager
npm install -g n
