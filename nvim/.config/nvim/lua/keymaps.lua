-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Provide more convenient escape bindings
vim.keymap.set('i', 'kj', '<Esc>', { desc = 'Escape' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Escape' })
vim.keymap.set('v', '<BS>', '<Esc>', { desc = 'Escape' })
vim.keymap.set('v', 'q', '<Esc>', { desc = 'Escape' })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Buffer navigation
vim.keymap.set('n', '<leader>bd', '<cmd>bd<cr>', { desc = '[B]uffer [D]elete' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>od', vim.diagnostic.open_float, { desc = '[O]pen [D]iagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Move selected regions of text up and down with <C-K> and <C-J>
vim.api.nvim_set_keymap('v', '<C-K>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-J>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
