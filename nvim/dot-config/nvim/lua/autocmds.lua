local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", {}),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-reload files changed outside Neovim
local reload_group = augroup("AutoReloadFile", {})

autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = reload_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Periodic file check timer (catches changes even without focus)
local timer = vim.uv.new_timer()
if timer then
  timer:start(0, 2000, function()
    vim.schedule(function()
      if vim.fn.getcmdwintype() == "" then
        vim.cmd("checktime")
      end
    end)
  end)
end

-- Suppress file change warnings
autocmd("FileChangedShellPost", {
  group = reload_group,
  callback = function()
    vim.cmd("diffupdate")
  end,
})

vim.cmd([[
  augroup silent_file_reload
    autocmd!
    autocmd FileChangedRO * silent
    autocmd FileChangedShell * silent
  augroup END
]])

-- Markdown settings
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.wrap = true
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.textwidth = 80
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = "shift:2"
    vim.opt_local.showbreak = "↪ "
    vim.opt_local.list = false
    vim.opt_local.formatoptions:remove("t")

    -- Navigate wrapped lines naturally
    vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })
    vim.keymap.set("v", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("v", "k", "gk", { buffer = true, silent = true })
  end,
})

-- Resize splits when terminal is resized
autocmd("VimResized", {
  group = augroup("ResizeSplits", {}),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Go to last cursor position when opening a buffer
autocmd("BufReadPost", {
  group = augroup("LastPlace", {}),
  callback = function(event)
    local buf = event.buf
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
