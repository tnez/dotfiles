return {
  { "matrosmartz/neotest-deno" },
  { "nvim-neotest/neotest", opts = {
    adapters = {
      ["neotest-deno"] = {},
    },
  } },
}
