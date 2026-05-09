local ensure_installed = {
  "bash",
  "css",
  "diff",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vento",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = function()
      require("nvim-treesitter").install(ensure_installed):wait(300000)
    end,
    lazy = false,
    opts = {
      ensure_installed = ensure_installed,
    },
    config = function(_, opts)
      local ok, ts = pcall(require, "nvim-treesitter")
      if ok and type(ts.setup) == "function" then
        ts.setup()
        ts.install(opts.ensure_installed)

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("TreesitterStart", {}),
          callback = function()
            if vim.bo.filetype ~= "markdown" then
              pcall(vim.treesitter.start)
            end
          end,
        })
        return
      end

      require("nvim-treesitter.configs").setup({
        ensure_installed = opts.ensure_installed,
        highlight = { enable = true, disable = { "markdown", "markdown_inline" } },
        indent = { enable = true, disable = { "markdown", "markdown_inline" } },
      })
    end,
  },
}
