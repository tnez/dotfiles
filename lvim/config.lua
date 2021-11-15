----------
-- GENERAL
--
lvim.format_on_save = true
lvim.lint_on_save = true
lvim.colorscheme = "tokyonight"

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
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    exe = "prettier",
    filetypes = {
      "css",
      "html",
      "javascript",
      "javascriptreact",
      "markdown",
      "typescript",
      "typescriptreact",
    },
  },
}

---------------------
-- ADDITIONAL PLUGINS
--
lvim.plugins = {
  {"christoomey/vim-tmux-navigator"},
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
  {"ryanoasis/vim-devicons"},
  {"sotte/presenting.vim"},
  {"sindrets/diffview.nvim"},
  {"xojs/vim-xo"},
}
