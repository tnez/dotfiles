-- Native LSP configuration using Neovim 0.12 vim.lsp.config()
-- No nvim-lspconfig needed — just mason for installing servers.

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

local float_opts = {
  border = "rounded",
  focusable = false,
  max_width = 100,
}

vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  config = vim.tbl_deep_extend("force", float_opts, config or {})
  return vim.lsp.handlers.hover(err, result, ctx, config)
end

vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
  config = vim.tbl_deep_extend("force", float_opts, config or {})
  return vim.lsp.handlers.signature_help(err, result, ctx, config)
end

-- Configure LSP servers natively
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
    },
  },
})

-- ts_ls for Node/Bun projects, denols for Deno projects (mutually exclusive)
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    if vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }) then
      return
    end

    on_dir(vim.fs.root(bufnr, { "package.json", "tsconfig.json", "jsconfig.json", ".git" }))
  end,
})

vim.lsp.config("denols", {
  cmd = { "deno", "lsp" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }))
  end,
  workspace_required = true,
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
})

vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  settings = {
    python = {
      analysis = {
        disableOrganizeImports = true, -- Use Ruff for imports
      },
    },
  },
})

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown" },
})

-- Enable all configured servers
vim.lsp.enable({ "lua_ls", "ts_ls", "denols", "ruff", "pyright", "marksman" })

-- LSP keymaps (attached when a server connects)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspKeymaps", {}),
  callback = function(event)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Type Definition")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format")
  end,
})

return {
  -- Mason for installing LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "pyright",
        "ruff",
        "marksman",
        "typescript-language-server",
        "deno",
        "shellcheck",
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- Auto-install listed tools
      local mr = require("mason-registry")
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
