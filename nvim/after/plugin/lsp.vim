" Completion Pop-Up Menu Config
set completeopt=menuone,noinsert,noselect
let g:completion_matching_strategy_list =  ['exact', 'substring', 'fuzzy']
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

"Quick Information (hover)
nnoremap <silent>K :Lspsaga hover_doc<CR>

"Navigation
nnoremap <silent>gh :Lspsaga lsp_finder<CR>

"Diagnostics
nnoremap <silent>cd :Lspsaga show_line_diagnostics<CR>
nnoremap <silent>[e :Lspsaga diagnostic_jump_prev<CR>
nnoremap <silent>]e :Lspsaga diagnostic_jump_next<CR>

"Actions
nnoremap <silent>ca :Lspsaga code_action<CR>
vnoremap <silent>ca :<C-U>Lspsaga range_code_action<CR>
nnoremap <silent>cr :Lspsaga rename<CR>

" Smart scroll
nnoremap <silent><Down> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
nnoremap <silent><Up> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>

" Hacks
nnoremap <F12> :lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>
      \ <bar> :edit<CR>
      \ <bar> :echo "LSP is reloading..."<CR>
