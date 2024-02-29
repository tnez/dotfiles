return {
  "alexghergh/nvim-tmux-navigation",
  lazy = false,
  config = true,
  opts = {
    disable_when_zoomed = true,
  },
  keys = {
    { "<C-h>", "<cmd>NvimTmuxNavigateLeft<cr>" },
    { "<C-j>", "<cmd>NvimTmuxNavigateDown<cr>" },
    { "<C-k>", "<cmd>NvimTmuxNavigateUp<cr>" },
    { "<C-l>", "<cmd>NvimTmuxNavigateRight<cr>" },
  },
}
