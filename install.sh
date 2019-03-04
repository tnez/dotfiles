#!/usr/bin/env sh

CONFIG_DIR="$HOME/Projects/tnez--config"

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
_link .npmrc .npmrc
_link base16-shell .config/base16-shell
_link chunkwm/config .chunkwmrc
_link ctags/config .ctags
_link fish .config/fish
_link git/gitconfig .gitconfig
_link i3 .config/i3
_link kitty .config/kitty
_link scripts bin
_link secrets/.secrets .secrets
_link skhd/config .skhdrc
_link spacemacs/.spacemacs .spacemacs
_link tmux .config/tmux
_link tnez-snippets .config/tnez-snippets
_link vim/config .vimrc
