-- set solarized colorscheme and inspect TERMINAL_COLOR_SCHEME_VARIANT to see if
-- we want to use dark or light variant
return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = vim.env.OS_INTERFACE_STYLE:lower()
    vim.o.termguicolors = true
    vim.cmd.colorscheme 'solarized'
  end,
}
