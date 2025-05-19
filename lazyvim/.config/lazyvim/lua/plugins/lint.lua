return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {}, -- Disable all markdown linting since markdownlint is not installed
      },
    },
  },
}