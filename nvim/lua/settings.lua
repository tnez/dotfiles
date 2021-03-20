vim.cmd('set iskeyword+=-')
vim.cmd('set shortmess+=c')
vim.cmd('set whichwrap+=<,>,[,],h,l')
vim.cmd('syntax on')

-- global
vim.o.backup=false
vim.o.clipboard="unnamedplus"
vim.o.conceallevel = 0
vim.o.fileencoding="utf-8"
vim.o.hidden=true
vim.o.joinspaces=false
vim.o.shell="/bin/bash"
vim.o.smartindent=true
vim.o.splitbelow=true
vim.o.timeoutlen=500
vim.o.updatetime=300
vim.o.writebackup=false

-- winder
vim.wo.foldenable=false
vim.wo.number=true
vim.wo.numberwidth=5
vim.wo.relativenumber=true
vim.wo.scrolloff=10
vim.wo.wrap=false

-- buffer
vim.bo.expandtab = true
