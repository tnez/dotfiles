function switch-color-theme -a name -d "Globally change to color theme by name"
  if test -z "$name"
    echo "ERROR: Name is required"
    return 127
  end

  if test -n "$TMUX"
    echo "ERROR: Must be run outside of tmux"
    return 127
  end

  # Kitty
  ln -sf $HOME/.config/kitty/colors/{$name}.conf $HOME/.config/kitty/colors/current.conf
  kitty @set-colors -a -c $HOME/.config/kitty/colors/current.conf

  # TMUX
  ln -sf $HOME/.config/tmux/status-line/{$name}.conf $HOME/.config/tmux/status-line/current.conf
  tmux source-file $HOME/.config/tmux/status-line/current.conf

  # NeoVim
  ln -sf $HOME/.config/nvim/lua/user/colorscheme/{$name}.lua $HOME/.config/nvim/lua/user/colorscheme/current.lua
  # TODO: I'm not yet sure of the best way to refresh the color scheme for all running NeoVim instances
  #       For now, we just need to restart NeoVim to get the new colors
end

set -l available_color_themes tokyonight_day tokyonight_storm
complete --no-files --command switch-color-theme --condition "not __fish_seen_subcommand_from $available_color_themes" --arguments "$available_color_themes"
