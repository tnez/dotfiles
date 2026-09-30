-- Extend LazyVim, not the whole editor config. Pair with tmux/dot-tmux.conf.
return {
  {
    'mrjones2014/smart-splits.nvim',
    lazy = false, -- Set @pane-is-vim before tmux receives a navigation key.
    opts = {
      multiplexer_integration = vim.env.TMUX and 'tmux' or false,
      at_edge = 'wrap',
    },
    keys = {
      {
        '<C-h>',
        function()
          require('smart-splits').move_cursor_left()
        end,
        desc = 'Move left (Vim/tmux)',
      },
      {
        '<C-j>',
        function()
          require('smart-splits').move_cursor_down()
        end,
        desc = 'Move down (Vim/tmux)',
      },
      {
        '<C-k>',
        function()
          require('smart-splits').move_cursor_up()
        end,
        desc = 'Move up (Vim/tmux)',
      },
      {
        '<C-l>',
        function()
          require('smart-splits').move_cursor_right()
        end,
        desc = 'Move right (Vim/tmux)',
      },
    },
  },
}
