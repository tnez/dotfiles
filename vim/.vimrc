call plug#begin('~/.vim/plugged')

" Declare the list of plugins to be installed
" Plug 'tnez/cool-stuff'
" Plug 'other/another-thing'
" ...
Plug 'altercation/vim-colors-solarized'

call plug#end()

" UI Customization
syntax enable
set background=dark
colorscheme solarized
