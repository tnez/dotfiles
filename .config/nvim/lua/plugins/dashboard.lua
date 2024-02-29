local _tagline = "get shiz done"
local _header =
  vim.split(string.rep("\n", 6) .. _tagline .. string.rep("\n", 3), "\n")

return {
  "nvimdev/dashboard-nvim",
  opts = {
    config = {
      header = _header,
    },
  },
}
