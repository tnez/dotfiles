local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  execute 'packadd packer.nvim'
end

vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile'

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- General
  use 'airblade/vim-rooter'
  use 'editorconfig/editorconfig-vim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'qpkorr/vim-bufkill'
  use 'scrooloose/nerdcommenter'
  use 'tpope/vim-surround'
  use 'voldikss/vim-floaterm'
  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'
  use 'windwp/nvim-autopairs'

  -- git
  use 'samoshkin/vim-mergetool'

  -- IDE magic
  use 'honza/vim-snippets'
  use 'hrsh7th/nvim-compe'
  use 'neovim/nvim-lspconfig'
  use 'sbdchd/neoformat'
  use 'tjdevries/lsp_extensions.nvim'
  use 'tjdevries/nlua.nvim'
  use 'xojs/vim-xo'
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'glepnir/lspsaga.nvim'

  -- Asthetics
  use 'dylanaraps/wal.vim'
  use 'junegunn/goyo.vim'
end)
