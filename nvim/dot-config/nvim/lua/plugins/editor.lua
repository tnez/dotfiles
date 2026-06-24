local zen_markdown_conceallevel

return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "echasnovski/mini.icons",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "File Explorer" },
      { "<leader>E", "<cmd>Neotree reveal<CR>", desc = "Reveal in Explorer" },
    },
    opts = {
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              vim.fn.setreg("+", node:get_id(), "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
    },
  },

  -- Smart split navigation (works with tmux/wezterm)
  -- IMPORTANT: must not be lazy-loaded — the @pane-is-vim tmux variable is
  -- set on plugin load and tmux's smart pane switching depends on it.
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      at_edge = "wrap",
      multiplexer_integration = "tmux",
    },
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move left" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move down" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move up" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move right" },
      { "<M-h>", function() require("smart-splits").resize_left() end, desc = "Resize left" },
      { "<M-j>", function() require("smart-splits").resize_down() end, desc = "Resize down" },
      { "<M-k>", function() require("smart-splits").resize_up() end, desc = "Resize up" },
      { "<M-l>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
    },
  },

  -- Fixed-width focus view for prose without hard-wrapping files
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>uz", "<cmd>ZenMode<CR>", desc = "Toggle Focus Width" },
    },
    opts = {
      window = {
        width = 100,
      },
      on_open = function()
        if vim.bo.filetype == "markdown" or vim.bo.filetype == "markdown.mdx" then
          zen_markdown_conceallevel = vim.wo.conceallevel
          vim.wo.conceallevel = 2
        else
          zen_markdown_conceallevel = nil
        end
      end,
      on_close = function()
        if zen_markdown_conceallevel ~= nil then
          vim.wo.conceallevel = zen_markdown_conceallevel
          zen_markdown_conceallevel = nil
        end
      end,
    },
  },

  -- Which-key for discoverability
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>u", group = "ui/ux" },
        { "<leader>a", group = "ai" },
      },
    },
  },

  -- Mini utilities (just the essentials)
  { "echasnovski/mini.icons", version = false, lazy = true, opts = {} },
  { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
