local map = vim.keymap.set

-- Exit insert mode
map("i", "jj", "<ESC>", { silent = true })
map("i", "jk", "<ESC>", { silent = true })
map("i", "kj", "<ESC>", { silent = true })
map("i", "kk", "<ESC>", { silent = true })

-- Hover (LSP will override per-buffer when attached)
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })

-- Clear search highlight
map("n", "<ESC>", "<cmd>nohlsearch<CR>")

-- Window navigation + resize handled by smart-splits.nvim (see plugins/editor.lua)

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<CR>==")
map("n", "<A-k>", "<cmd>m .-2<CR>==")
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete Buffer" })

-- Save
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })

-- Quit
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- Terminal
map("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
