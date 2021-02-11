" Completion Pop-Up Menu Config
set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list =  ['exact', 'substring', 'fuzzy']
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"Quick Information (hover)
nnoremap K :lua vim.lsp.buf.hover()<CR>

"Navigation
nnoremap <leader>gd :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>gi :lua vim.lsp.buf.implementation()<CR>

"Actions
nnoremap <leader>ar :lua vim.lsp.buf.rename()<CR>

" Hacks
nnoremap <F12> :lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>
      \ <bar> :edit<CR>
      \ <bar> :echo "LSP is reloading..."<CR>

" Language Servers
lua << EOF
require'lspconfig'.tsserver.setup{ on_attach=require'completion'.on_attach }
EOF
