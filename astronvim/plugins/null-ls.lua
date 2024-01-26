return {
  "jose-elias-alvarez/null-ls.nvim",
  opts = function(_, opts)
    local null_ls = require("null-ls")
    opts.sources = {

      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.ruff,
      null_ls.builtins.formatting.shfmt.with({
        args = { "-i", "2" },
      }),

      null_ls.builtins.diagnostics.luacheck,
      null_ls.builtins.diagnostics.mypy,
      null_ls.builtins.diagnostics.ruff,
    }
    return opts
  end,
}
