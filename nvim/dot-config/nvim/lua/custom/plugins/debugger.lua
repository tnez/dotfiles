return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', opts = {} },
      { 'theHamsta/nvim-dap-virtual-text', opts = {} },
    },

    -- stylua: ignore
    keys = {
      { '<leader>d', '', desc = '[D]ebug', mode = { 'n', 'v' } },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Continue' },
    },
  },
}
