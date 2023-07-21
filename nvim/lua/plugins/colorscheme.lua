-- Get the value of the MODE environment variable and set the flavour accordingly
local mode = vim.env.MODE
local inferredFlavour = "latte"
if mode == "DARK" then
  inferredFlavour = "frappe"
end

return {
  { "catppuccin/nvim", lazy = true, name = "catppuccin", opts = {
    flavour = inferredFlavour,
  } },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
