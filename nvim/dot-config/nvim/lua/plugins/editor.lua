local zen_markdown_conceallevel

local function move_or_focus_herdr(wincmd, direction)
  local previous_window = vim.api.nvim_get_current_win()

  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= previous_window then
    return
  end

  local herdr = vim.env.HERDR_BIN_PATH or "herdr"
  local pane = vim.env.HERDR_PANE_ID
  vim.fn.system({ herdr, "pane", "focus", "--direction", direction, "--pane", pane })
end

local function tab_window_sizes()
  local sizes = {}

  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(window).relative == "" then
      local position = vim.api.nvim_win_get_position(window)
      sizes[window] = table.concat({
        vim.api.nvim_win_get_width(window),
        vim.api.nvim_win_get_height(window),
        position[1],
        position[2],
      }, ":")
    end
  end

  return sizes
end

local function resize_herdr(direction)
  local herdr = vim.env.HERDR_BIN_PATH or "herdr"
  local pane = vim.env.HERDR_PANE_ID
  vim.fn.system({ herdr, "pane", "resize", "--direction", direction, "--pane", pane })
end

local function resize_or_resize_herdr(method, direction)
  local before = tab_window_sizes()

  if vim.tbl_count(before) == 1 then
    resize_herdr(direction)
    return
  end

  require("smart-splits")[method]()
  for window, size in pairs(tab_window_sizes()) do
    if before[window] ~= size then
      return
    end
  end

  resize_herdr(direction)
end

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

  -- Smart split navigation (works with tmux/wezterm/herdr)
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
      {
        "<C-h>",
        function()
          if vim.env.HERDR_PANE_ID then
            move_or_focus_herdr("h", "left")
          else
            require("smart-splits").move_cursor_left()
          end
        end,
        desc = "Move left",
      },
      {
        "<C-j>",
        function()
          if vim.env.HERDR_PANE_ID then
            move_or_focus_herdr("j", "down")
          else
            require("smart-splits").move_cursor_down()
          end
        end,
        desc = "Move down",
      },
      {
        "<C-k>",
        function()
          if vim.env.HERDR_PANE_ID then
            move_or_focus_herdr("k", "up")
          else
            require("smart-splits").move_cursor_up()
          end
        end,
        desc = "Move up",
      },
      {
        "<C-l>",
        function()
          if vim.env.HERDR_PANE_ID then
            move_or_focus_herdr("l", "right")
          else
            require("smart-splits").move_cursor_right()
          end
        end,
        desc = "Move right",
      },
      {
        "<M-h>",
        function()
          if vim.env.HERDR_PANE_ID then
            resize_or_resize_herdr("resize_left", "left")
          else
            require("smart-splits").resize_left()
          end
        end,
        desc = "Resize left",
      },
      {
        "<M-j>",
        function()
          if vim.env.HERDR_PANE_ID then
            resize_or_resize_herdr("resize_down", "down")
          else
            require("smart-splits").resize_down()
          end
        end,
        desc = "Resize down",
      },
      {
        "<M-k>",
        function()
          if vim.env.HERDR_PANE_ID then
            resize_or_resize_herdr("resize_up", "up")
          else
            require("smart-splits").resize_up()
          end
        end,
        desc = "Resize up",
      },
      {
        "<M-l>",
        function()
          if vim.env.HERDR_PANE_ID then
            resize_or_resize_herdr("resize_right", "right")
          else
            require("smart-splits").resize_right()
          end
        end,
        desc = "Resize right",
      },
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
