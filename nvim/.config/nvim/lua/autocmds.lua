-- Define autocommands in a separate file
-- Create an augroup to group related autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General Settings
local general_group = augroup('GeneralSettings', { clear = true })
-- Example: Automatically resize splits when the window is resized
autocmd('VimResized', {
  group = general_group,
  callback = function()
    vim.cmd 'tabdo wincmd ='
  end,
})

-- Markdown Settings
local markdown_group = augroup('MarkdownSettings', { clear = true })
-- Autocommands for Markdown files
autocmd('FileType', {
  group = markdown_group,
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.breakindent = true
    vim.opt_local.linebreak = true
    vim.opt_local.showbreak = '↪ '
  end,
})

-- Auto-reload files changed outside of Neovim
local autoreload_group = augroup('AutoReloadFile', { clear = true })

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
    autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
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
autocmd("VimEnter", {
  group = autoreload_group,
  callback = setup_file_check_timer,
  once = true,
})

-- Notification and visual highlight after file change
autocmd("FileChangedShellPost", {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    -- Flash the screen to make changes more noticeable
    vim.cmd("diffupdate")
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})
