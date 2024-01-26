return {
  i = {
    ["kj"] = { "<esc>", desc = "Better Better Escape" },
  },
  n = {
    ["kj"] = false,
    ["<leader>c"] = false,
    ["<C-c><C-c>"] = { ":Neotest run<cr>", desc = "Testing: Run nearest" },
    ["<C-c><C-o>"] = { ":Neotest summary<cr>", desc = "Testing: Open summary" },
  },
}
