-- Leader key (must be set before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.showmode = false

-- Wrapping
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
vim.opt.breakindentopt = "shift:2"

-- File handling
vim.opt.updatetime = 500
vim.opt.autoread = true
vim.opt.autowriteall = true
vim.opt.confirm = true
vim.opt.undofile = true
vim.opt.swapfile = false

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Completion (Neovim 0.12 built-in)
vim.opt.completeopt = "menu,menuone,noselect,popup"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Mouse
vim.opt.mouse = "a"
