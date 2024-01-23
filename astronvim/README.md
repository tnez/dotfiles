# AstroNvim User Configuration

This is where my [AstroNvim](https://astronvim.com) user configuration goes.

## How to setup fresh

1. Set **dotfiles directory**: `set DOTFILES_DIR ~/Code/tnez/dotfiles`
1. Clone the [AstroNvim Repo](https://git.astronvim.com/AstroNvim):
   `git clone --depth 1 https://github.com/AstroNvim/AstroNvim "$DOTFILES_DIR"/.config/nvim`
1. Symlink this User Configuration:
   `ln -s "$DOTFILES_DIR"/astronvim "$DOTFILES_DIR"/.config/nvim/lua/user`
