return { -- Autoformat
  'stevearc/conform.nvim',
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      json = { 'prettier' },
      markdown = { 'prettier' },
      svelte = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      toml = { 'prettier' },
      yaml = { 'prettier' },
    },
  },
}
