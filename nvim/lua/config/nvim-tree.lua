vim.g.nvim_tree_disable_netrw = 0
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_lsp_diagnostics = 1
vim.g.nvim_tree_auto_close = 1

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
vim.g.nvim_tree_bindings = {
  ['<CR>'] = tree_cb('edit'),
  ['l'] = tree_cb('edit'),
  ['o'] = tree_cb('edit'),
  ['v'] = tree_cb('vsplit'),
  ['s'] = tree_cb('split'),
  ['t'] = tree_cb('tabnew'),
  ['x'] = tree_cb('close_node'),
  ['r'] = tree_cb('refresh'),
  ['a'] = tree_cb('create'),
  ['d'] = tree_cb('remove'),
  ['R'] = tree_cb('rename'),
}
