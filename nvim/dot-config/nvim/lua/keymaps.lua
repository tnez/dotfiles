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

-- Better window navigation (overridden by smart-splits when loaded)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Resize windows
map("n", "<M-h>", "<cmd>vertical resize -2<CR>")
map("n", "<M-j>", "<cmd>resize -2<CR>")
map("n", "<M-k>", "<cmd>resize +2<CR>")
map("n", "<M-l>", "<cmd>vertical resize +2<CR>")

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
