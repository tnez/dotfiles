return {
  {
    'maxmx03/solarized.nvim',
    config = function()
      vim.cmd 'colorscheme solarized'
    end,
  },
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.o.background = 'dark'
        vim.cmd 'colorscheme solarized'
      end,
      set_light_mode = function()
        vim.o.background = 'light'
        vim.cmd 'colorscheme solarized'
      end,
    },
  },
}
