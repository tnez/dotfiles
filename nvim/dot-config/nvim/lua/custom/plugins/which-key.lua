return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    local wk = require 'which-key'
    wk.add {
      { '<leader>a', group = 'ai', mode = { 'n', 'v' } },
      { '<leader>b', group = 'buffer' },
      { '<leader>c', group = 'code' },
      { '<leader>d', group = 'debug' },
      { '<leader>o', group = 'open' },
      { '<leader>r', group = 'rename' },
      { '<leader>s', group = 'search' },
      { '<leader>t', group = 'test' },
      { '<leader>u', group = 'ui' },
      { '<leader>w', group = 'workspace' },
    }
  end,
}
