-- Define autocommands in a separate file
-- Create an augroup to group related autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General Settings
local general_group = augroup('GeneralSettings', { clear = true })
-- Example: Automatically resize splits when the window is resized
autocmd('VimResized', {
  group = general_group,
  callback = function()
    vim.cmd 'tabdo wincmd ='
  end,
})

-- Markdown Settings
local markdown_group = augroup('MarkdownSettings', { clear = true })
-- Autocommands for Markdown files
autocmd('FileType', {
  group = markdown_group,
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.breakindent = true
    vim.opt_local.linebreak = true
    vim.opt_local.showbreak = '↪ '
  end,
})
