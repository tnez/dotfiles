-- leader
vim.api.nvim_set_keymap('n', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = ' '

-- escape is so far away
vim.api.nvim_set_keymap('i', 'kj', '<ESC>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {noremap = true, silent = true})

-- remove those pesky highlights
vim.api.nvim_set_keymap('n', '<Leader>h', ':set hlsearch!<CR>', {noremap = true, silent = true})

-- buffer operations
vim.api.nvim_set_keymap('n', '<TAB>', ':bnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-TAB>', ':bprevious<CR>', {noremap = true, silent = true})

-- window operations
vim.api.nvim_set_keymap('n', '<Leader>ws', ':sp<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>wv', ':vs<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>wd', ':close<CR>', {noremap = true, silent = true})

-- file operations
vim.api.nvim_set_keymap('n', '<Leader>fs', ':w<CR>', {noremap = true, silent = true})

-- application operations
vim.api.nvim_set_keymap('n', '<Leader>Q', ':qa<CR>', {noremap = true, silent = true})

-- TODO: Need to introduce an indirection layer in between these bindings and
-- their commands
-- Git Mappings
vim.api.nvim_set_keymap('n', '<Leader>gb', ':GBlame<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>gl', ':FloatermNew tig<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>gs', ':FloatermNew lazygit<CR>', {noremap = true, silent = true})
-- File Explorer
vim.api.nvim_set_keymap('n', '<C-e>', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
-- File Fuzzy Finder
vim.api.nvim_set_keymap('n', '<C-o>', ':Telescope git_files<CR>', {noremap = true, silent = true})
-- Terminals
vim.api.nvim_set_keymap('n', '<Leader>tt', ':FloatermNew<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>tn', ':FloatermNew node<CR>', {noremap = true})
