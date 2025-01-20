-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.api.nvim_set_keymap

-- make it easier to exit insert mode
keymap("i", "jj", "<ESC>", { noremap = true, silent = true })
keymap("i", "jk", "<ESC>", { noremap = true, silent = true })
keymap("i", "kj", "<ESC>", { noremap = true, silent = true })
keymap("i", "kk", "<ESC>", { noremap = true, silent = true })
