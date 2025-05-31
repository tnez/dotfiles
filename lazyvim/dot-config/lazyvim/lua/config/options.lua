-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Python Stuff
-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"

-- File auto-reload settings
-- Set up automatic file change detection
vim.opt.updatetime = 500 -- Check for file changes every 500ms during normal editing
vim.opt.autoread = true -- Enable automatic detection of file changes
vim.opt.autowriteall = true -- Auto-save modified buffers when switching between them
-- Disable file change warning messages
vim.opt.confirm = true -- Ask to save changes before exiting

-- Global wrap settings (will apply to all buffers)
vim.opt.wrap = false -- Don't wrap by default
vim.opt.linebreak = true -- Break at word boundaries when wrap is enabled
vim.opt.breakindent = true -- Maintain indent when wrapping
vim.opt.showbreak = "↪ " -- Show break indicator
vim.opt.breakindentopt = "shift:2" -- Indent wrapped lines by 2 spaces

-- This suppresses the "WARNING: File has changed" messages
vim.cmd([[
  augroup silent_file_reload
    autocmd!
    autocmd FileChangedRO * silent
    autocmd FileChangedShell * silent
  augroup END
]])
