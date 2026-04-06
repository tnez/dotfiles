return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>aa", ":CodeCompanionActions<CR>", desc = "Open Actions" },
      { "<leader>ac", ":CodeCompanionChat Toggle<CR>", desc = "Toggle Chat" },
      { "<leader>aA", ":CodeCompanionChat Add<CR>", desc = "Add to Chat" },
      { "<leader>ai", ":CodeCompanion<CR>", mode = { "n", "v" }, desc = "Inline Assistant" },
      { "ga", ":CodeCompanion<CR>", mode = { "n", "v" }, desc = "Inline Assistant" },
      { "<leader>ae", ":CodeCompanion explain<CR>", mode = "v", desc = "Explain Code" },
      { "<leader>ar", ":CodeCompanion refactor<CR>", mode = "v", desc = "Refactor Code" },
      { "<leader>at", ":CodeCompanion tests<CR>", mode = "v", desc = "Generate Tests" },
    },
    opts = {
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "cmd:cat ~/.secrets/ANTHROPIC_API_KEY",
            },
            schema = {
              model = {
                default = "claude-sonnet-4-0",
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "anthropic" },
        inline = { adapter = "anthropic" },
        cmd = { adapter = "anthropic" },
        workflow = { adapter = "anthropic" },
      },
      display = {
        action_palette = { width = 95, height = 10 },
        chat = {
          window = {
            width = 0.35,
            height = 0.8,
            relative = "editor",
            position = "right",
          },
          show_settings = true,
        },
        inline = {
          diff = { enabled = true },
        },
      },
      opts = {
        log_level = "DEBUG",
        system_prompt = [[You are an AI programming assistant integrated into Neovim.
Be concise and focused on the specific task at hand.
Follow the existing code style and conventions in the project.]],
      },
    },
  },
}
