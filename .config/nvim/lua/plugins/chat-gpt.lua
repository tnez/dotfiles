return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup()
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>;", desc = "ChatGPT ->", mode = { "n", "v" } },
    {
      "<leader>;;",
      "<cmd>ChatGPT<cr>",
      mode = "n",
      desc = "Open ChatGPT",
    },
    {
      "<leader>;;",
      "<cmd>ChatGPTEditWithInstructions<cr>",
      mode = "v",
      desc = "Edit Region with ChatGPT",
    },
  },
}
