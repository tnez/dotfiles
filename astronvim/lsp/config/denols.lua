return {
  opts = function(_, opts)
    opts.root_dir =
      require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
    return opts
  end,
}
