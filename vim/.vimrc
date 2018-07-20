call plug#begin('~/.vim/plugged')

" Declare the list of plugins to be installed
" Plug 'tnez/cool-stuff'
" Plug 'other/another-thing'
" ...
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/syntastic'

call plug#end()

" UI Customization
syntax enable
set background=dark
colorscheme solarized

" Syntax Checking
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
