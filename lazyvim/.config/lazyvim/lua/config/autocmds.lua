-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
local autocmd_files = {
  "markdown",
}

for _, file in ipairs(autocmd_files) do
  local ok, err = pcall(require, "config.autocmds." .. file)
  if not ok then
    vim.api.nvim_err_writeln("Error loading autocmds for " .. file .. ": " .. err)
  end
end

-- Auto-reload files changed outside of Neovim
local autoreload_group = vim.api.nvim_create_augroup("AutoReloadFile", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Notification after file change with visual highlight
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    -- Flash the screen to make changes more noticeable
    vim.cmd("diffupdate")
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})
