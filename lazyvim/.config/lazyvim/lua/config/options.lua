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
-- Set to 0 to disable file change check messages (more suitable for timer-based reloading)
vim.opt.confirm = true -- Ask to save changes before exiting
