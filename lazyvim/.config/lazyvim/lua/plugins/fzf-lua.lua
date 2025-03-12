return {
  "ibhagwan/fzf-lua",
  lazy = false,
  opts = {},
  keys = {
    { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
  },
}
