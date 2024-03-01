return {
  "pwntester/octo.nvim",
  lazy = false,
  depends = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = true,
  options = {
    suppress_missing_scope = {
      projects_v2 = true,
    },
  },
  keys = {
    { "<leader>go", desc = "Octo -> " },
    { "<leader>goc", ":Octo pr create<CR>", desc = "Create New Pull-Request" },
    { "<leader>god", ":Octo pr diff<CR>", desc = "Diff current Pull-Request" },
    { "<leader>gol", ":Octo pr list<CR>", desc = "List Open Pull-Requests" },
    { "<leader>goo", ":Octo pr open<CR>", desc = "Open current Pull-Request" },
  },
}
