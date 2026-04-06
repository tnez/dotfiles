return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>FzfLua commands<CR>", desc = "Commands" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document Symbols" },
      { "<leader>fw", "<cmd>FzfLua lsp_workspace_symbols<CR>", desc = "Workspace Symbols" },
      { "<leader>fk", "<cmd>FzfLua keymaps<CR>", desc = "Keymaps" },
      { "<leader>/", "<cmd>FzfLua live_grep<CR>", desc = "Grep" },
      { "<leader><space>", "<cmd>FzfLua files<CR>", desc = "Find Files" },
    },
    opts = {},
  },
}
