return {
  i = {
    ["kj"] = { "<esc>", desc = "Better Better Escape" },
  },
  n = {
    ["kj"] = false,
    ["<C-c><C-c>"] = { ":Neotest run<cr>", desc = "Testing: Run nearest" },
    ["<C-c><C-d>"] = {
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      desc = "Testing: Run nearest with debugger",
    },
    ["<C-c><C-o>"] = { ":Neotest summary<cr>", desc = "Testing: Open summary" },
    ["<S-H>"] = { ":bp<CR>", desc = "Jump to previous buffer" },
    ["<S-L>"] = { ":bn<CR>", desc = "Jump to next buffer" },
    ["<leader>bd"] = {
      function()
        require("astronvim.utils.buffer").close()
      end,
      desc = "Close buffer",
    },
    ["<leader>bo"] = {
      function()
        require("astronvim.utils.buffer").close_all(true)
      end,
      desc = "Close all buffers except for current",
    },
  },
}
