" Leader
let mapleader = " "

set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autoread      " Re-read buffers when they change on disk
set autowrite     " Automatically :write before running commands
set title         " Set title so that i3-vim-nav works as expected
set encoding=UTF-8
set nowrap
execute "set titleold=".hostname()

" Use system clipboard by default
set clipboard=unnamedplus

set shell=/bin/bash

" Exclude files from Ctrl-P and other indexing/checking/etc
set wildignore+=node_modules

" Use relative line numbers (with actual line number on current)
set number
set relativenumber

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

" Vim-Plug
call plug#begin(stdpath('data') . '/plugged')

" General
Plug 'tpope/vim-surround'
Plug 'editorconfig/editorconfig-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'qpkorr/vim-bufkill'
Plug 'liuchengxu/vim-which-key'
Plug 'voldikss/vim-floaterm'
Plug 'airblade/vim-rooter'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-obsession'
Plug 'preservim/nerdtree'

" Git
Plug 'tpope/vim-fugitive'
Plug 'samoshkin/vim-mergetool'

" All language
Plug 'sheerun/vim-polyglot'

" Web (General)
Plug 'mattn/emmet-vim'

" IDE-like Automagic
Plug 'honza/vim-snippets'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'tjdevries/nlua.nvim'
Plug 'tjdevries/lsp_extensions.nvim'
Plug 'sbdchd/neoformat'

" Looks
Plug 'dylanaraps/wal.vim'
Plug 'junegunn/goyo.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" load this last
Plug 'ryanoasis/vim-devicons'

call plug#end()

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md,gitcommit,*/qutebrowser-editor-* set filetype=markdown
  autocmd BufRead,BufNewFile *.md,gitcommit,*/qutebrowser-editor-* setlocal textwidth=0
  autocmd BufRead,BufNewFile *.md,gitcommit,*/qutebrowser-editor-* setlocal spell
  autocmd FileType gitcommit,*/qutebrowser-editor-* setlocal textwidth=0
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
  autocmd BufRead,BufNewFile aliases.local,zshrc.local,*/zsh/configs/* set filetype=sh
  autocmd BufRead,BufNewFile gitconfig.local set filetype=gitconfig
  autocmd BufRead,BufNewFile tmux.conf.local set filetype=tmux
  autocmd BufRead,BufNewFile vimrc.local,*/vim/config set filetype=vim
  autocmd BufRead,BufNewFile Dockerfile* set filetype=dockerfile

  " Enable completion in all buffers
  autocmd BufEnter * lua require'completion'.on_attach()
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
set nojoinspaces

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Numbers
set number
set numberwidth=5

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Git mappings
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gl :FloatermNew --height=0.8 --width=0.8 tig<CR>
nnoremap <Leader>gs :FloatermNew --height=0.8 --width=0.8 lazygit<CR>
nnoremap <Leader>gS :FloatermNew --height=0.8 --width=0.8 hub sync<CR>

" Git Mergetool configuration
let g:mergetool_layout = 'mr'
let g:mergetool_prefer_revision = 'local'
nmap <leader>mt <plug>(MergetoolToggle)
nmap <expr> <C-S-Left> &diff? '<Plug>(MergetoolDiffExchangeLeft)': '<C-S-Left>'
nmap <expr> <C-S-Right> &diff? '<Plug>(MergetoolDiffExchangeRight)': '<C-S-Right>'

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Split navigation that works with i3 by using
" https://github.com/termhn/i3-vim-nav
nnoremap <silent> <c-right> :call Focus('right', 'l')<CR>
nnoremap <silent> <c-left> :call Focus('left', 'h')<CR>
nnoremap <silent> <c-up> :call Focus('up', 'k')<CR>
nnoremap <silent> <c-down> :call Focus('down', 'j')<CR>

" Move between linting errors
nnoremap ]r :ALENextWrap<CR>
nnoremap [r :ALEPreviousWrap<CR>

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Always use vertical diffs
set diffopt+=vertical

" Keybindings
nnoremap <Space> <Nop>
inoremap kj <esc>

" Snippets
"
imap <C-;> <Plug>(coc-snippets-expand)
vmap <TAB> <Plug>(coc-snippets-select)
let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'
imap <TAB> <Plug>(coc-snippets-expand-jump)

" Javascript
let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0

" Web General
let g:user_emmet_leader_key='<C-y>'
let g:user_emmet_settings = {
\ 'javascript.jsx': { 'extends': 'jsx' }
\}

" Markdown
let g:vim_markdown_folding_disabled = 1
nmap <leader>mm <Plug>MarkdownPreviewToggle

" Set color theme
colorscheme wal

" Font stuff
highlight Comment cterm=italic
highlight htmlArg cterm=italic
highlight Type cterm=italic

" Motion
let g:sneak#label = 1

" File / Buffer navigation
nnoremap <leader>fs :w<CR>
nnoremap <leader>bd :BD<CR>
nnoremap <leader>q :BD<CR>
nnoremap <leader><TAB> :BB<CR>
nnoremap <leader><S-TAB> :BF<CR>
nnoremap <leader>Q :q<CR>
nnoremap <leader>wd :close<CR>

" File Explorer
nnoremap <leader>el :NERDTreeToggle<CR>

" Telescope
" TODO: I'd like to use <C-p> for everything Telescope and then be able to
" switch between pickers once I pull up telescope.
nnoremap <C-p> <cmd>Telescope git_files<cr>

" Floaterm
let g:floaterm_shell = '/usr/bin/fish'
let g:floaterm_autoclose = 1
nnoremap <leader>tt :FloatermNew<CR>
nnoremap <leader>tn :FloatermNew node<CR>
nnoremap <leader>tr :FloatermNew R<CR>

" vim-which-key
" TODO: need to define a key map to make results more readable, see:
" https://github.com/liuchengxu/vim-which-key#miminal-configuration
set timeoutlen=500
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey ','<CR>

" Startify
" let g:startify_sessions_dir = '~/.config/nvim/session'
" let g:startify_session_delete_buffers = 1
" let g:startify_session_persistence = 1
let g:startify_session_autoload = 1
let g:startify_change_to_vcs_root = 1
let g:startify_enable_special = 0
let g:startify_lists = [
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
      \ ]
let g:startify_bookmarks = [
      \ { 'a': '~/notes/what-am-i-doing.md' },
      \ { 'i': '~/notes/inbox.md' },
      \ { 'd': '~/Downloads' },
      \ ]
let g:startify_custom_header = [
      \ '',
      \ '   MAKE SOMETING!!!',
      \]
nnoremap <leader>ss :Obsess<CR>
nnoremap <leader>x :SClose<CR>
nnoremap <leader>X :Obsess!<CR>

" Status Line
if !has('gui_running')
  set t_Co=256
endif
let g:airline_theme = 'base16'
let g:airline_left_sep = "\uE0B0"
let g:airline_right_sep = "\uE0B2"
let g:airline#extensions#branch#enabled = 0
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = "\uE0B0"

" Check to see if buffers have changed on disk
au FocusGained,BufEnter * :checktime

