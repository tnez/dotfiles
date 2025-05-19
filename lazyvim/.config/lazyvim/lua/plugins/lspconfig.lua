return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      denols = {},
      ruff = {},
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
