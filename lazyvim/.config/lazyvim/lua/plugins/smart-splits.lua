return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {},
  keys = {
    -- Navigate Windows with Ctrl + hjkl
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      mode = { "n" },
      desc = "Move left",
    },
    {
      "<C-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      mode = { "n" },
      desc = "Move down",
    },
    {
      "<C-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      mode = { "n" },
      desc = "Move up",
    },
    {
      "<C-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      mode = { "n" },
      desc = "Move right",
    },
    -- Reisze Windows with Meta + hjkl
    {
      "<M-h>",
      function()
        require("smart-splits").resize_left()
      end,
      mode = { "n" },
      desc = "Resize left",
    },
    {
      "<M-j>",
      function()
        require("smart-splits").resize_down()
      end,
      mode = { "n" },
      desc = "Resize down",
    },
    {
      "<M-k>",
      function()
        require("smart-splits").resize_up()
      end,
      mode = { "n" },
      desc = "Resize up",
    },
    {
      "<M-l>",
      function()
        require("smart-splits").resize_right()
      end,
      mode = { "n" },
      desc = "Resize right",
    },
  },
}
