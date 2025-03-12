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

-- Create a timer for periodic file checking regardless of focus
local reload_timer = vim.loop.new_timer()

-- Setup function for periodic file checking
local function setup_file_check_timer()
  if reload_timer then
    reload_timer:stop()
    
    -- Check files every 2 seconds even without focus
    reload_timer:start(0, 2000, function()
      -- Schedule the checktime to run in the main Neovim loop
      vim.schedule(function()
        if vim.fn.getcmdwintype() == "" then
          vim.cmd("checktime")
        end
      end)
    end)
    
    -- Also keep the traditional focus-based checks for immediate response when focused
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
      group = autoreload_group,
      pattern = "*",
      callback = function()
        if vim.fn.getcmdwintype() == "" then
          vim.cmd("checktime")
        end
      end,
    })
  end
end

-- Set up the timer on startup
setup_file_check_timer()

-- Also create an autocmd to restart the timer if needed (e.g. after session reload)
vim.api.nvim_create_autocmd("VimEnter", {
  group = autoreload_group,
  callback = setup_file_check_timer,
  once = true,
})

-- Subtle visual indication of file changes without notifications
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    -- Just do a diff update to refresh the display, no notification
    vim.cmd("diffupdate")
    
    -- Optional: You can use a more subtle indicator like a status line flash
    -- or highlight the line number instead of showing a notification
    
    -- For a subtle status line flash, you could use:
    -- local current_statusline = vim.o.statusline
    -- vim.o.statusline = '%#DiffAdd#  File Updated  %#Normal#'
    -- vim.defer_fn(function() vim.o.statusline = current_statusline end, 1000)
  end,
})
