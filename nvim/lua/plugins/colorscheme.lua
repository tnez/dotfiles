-- Get the value of the THEME_VARIANT from the parent shell if it is set,
-- otherwise default to "storm"
local ALLOWED_VARIANTS = { "night", "storm", "moon", "day" }
local DEFAULT_VARIANT = "storm"

local variant = vim.env.THEME_VARIANT

if variant ~= nil and not vim.tbl_contains(ALLOWED_VARIANTS, variant) then
  error("Invalid THEME_VARIANT: " .. variant)
end

if variant == nil then
  variant = DEFAULT_VARIANT
end

return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = variant },
  },
  { "LazyVim/LazyVim", opts = {
    colorscheme = "tokyonight",
  } },
}
