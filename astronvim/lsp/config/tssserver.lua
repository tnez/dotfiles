return {
  opts = function(_, opts)
    opts.root_dir = require("lspconfig.util").root_pattern("package.json")
    return opts
  end,
}
