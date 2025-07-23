return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      denols = {},
      ruff = {},
      pyright = {
        capabilities = {
          textDocument = {
            formatting = false,
          },
        },
        settings = {
          python = {
            analysis = {
              -- Use Ruff for import organization
              disableOrganizeImports = true,
            },
          },
        },
      },
      marksman = {
        settings = {
          markdown = {
            validation = {
              ignoreLineLength = true,
            },
          },
        },
      },
    },
  },
}
