return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  opts = {
    plugins = {
      kitty = { enabled = true, font = "+2" },
    },
  },
  keys = { { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
}
