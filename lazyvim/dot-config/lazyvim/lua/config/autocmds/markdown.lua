vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Basic settings
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"

    -- Enable soft wrapping for markdown files
    vim.opt_local.wrap = true
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.textwidth = 80

    -- These settings ensure proper soft wrapping
    vim.opt_local.linebreak = true -- Break at word boundaries
    vim.opt_local.breakindent = true -- Preserve indentation in wrapped lines
    vim.opt_local.breakindentopt = "shift:2" -- Indent wrapped lines by 2 spaces
    vim.opt_local.showbreak = "↪ " -- Show indicator for wrapped lines

    -- Disable options that might interfere with soft wrapping
    vim.opt_local.list = false -- Disable listchars, which can break wrapping
    vim.opt_local.formatoptions:remove("t") -- Don't auto-wrap text when typing

    -- Improve navigation on wrapped lines
    vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })
    vim.keymap.set("v", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("v", "k", "gk", { buffer = true, silent = true })
  end,
})
