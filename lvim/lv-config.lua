----------
-- GENERAL
--
lvim.format_on_save = true
lvim.lint_on_save = true
lvim.colorscheme = "xresources"

--------------
-- KEYMAPPINGS
--
lvim.leader = "space"
-- WhichKey
lvim.builtin.which_key.mappings["t"] = {
  name = "Diagnostics",
  t = { "<cmd>TroubleToggle<cr>", "trouble" },
  w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "workspace" },
  d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "document" },
  q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
  l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
  r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}
lvim.builtin.which_key.mappings["P"] = {
  "<cmd>PresentingStart<cr>", "Present"
}

------------------
-- BUILTIN PLUGINS
--
lvim.builtin.lualine.active = true
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true

-------------------
-- TREESITTER STUFF
--
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.lang.javascript.formatters = {
  {
    exe = 'prettier',
    args = {},
  }
}
lvim.lang.javascript.linters = {
  {
    exe = 'xo',
    args = {},
  }
}

---------------------
-- ADDITIONAL PLUGINS
--
lvim.plugins = {
  {"folke/tokyonight.nvim"},
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {"nekonako/xresources-nvim"},
  {
    "ray-x/lsp_signature.nvim",
    config = function() require"lsp_signature".on_attach() end,
    event = "InsertEnter"
  },
  {"sotte/presenting.vim"},
  {
    "tpope/vim-fugitive",
    cmd = { "Gdiffsplit" },
  },
  {"xojs/vim-xo"},
}
