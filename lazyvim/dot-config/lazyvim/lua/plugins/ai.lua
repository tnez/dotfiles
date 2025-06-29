return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      -- Chat and actions
      { "<leader>aa", ":CodeCompanionActions<CR>", desc = "Open Actions" },
      { "<leader>ac", ":CodeCompanionChat Toggle<CR>", desc = "Toggle Chat" },
      { "<leader>aA", ":CodeCompanionChat Add<CR>", desc = "Add to Chat" },
      
      -- Inline operations (for quick code edits)
      { "<leader>ai", ":CodeCompanion<CR>", mode = { "n", "v" }, desc = "Inline Assistant" },
      { "ga", ":CodeCompanion<CR>", mode = { "n", "v" }, desc = "Inline Assistant" },
      
      -- Quick workflows
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
                default = "claude-sonnet-4-0", -- Claude Sonnet 4.0
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "anthropic",
          tools = {
            -- Enable agentic capabilities
            ["Full Stack Developer"] = {
              enabled = true,
              mode = "auto", -- Automatically use tools without manual tagging
              tools = {
                cmd_runner = {
                  enabled = true,
                  auto_execute = true, -- Run commands without confirmation
                },
                file_creator = {
                  enabled = true,
                },
                file_editor = {
                  enabled = true,
                },
                file_searcher = {
                  enabled = true,
                },
                web_searcher = {
                  enabled = true,
                },
              },
            },
          },
        },
        inline = {
          adapter = "anthropic",
        },
        cmd = {
          adapter = "anthropic",
        },
        workflow = {
          adapter = "anthropic",
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
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
          diff = {
            enabled = true,
            mode = "mini_diff", -- or "default" for classic diff
          },
        },
      },
      opts = {
        log_level = "DEBUG", -- View logs at: ~/.local/state/nvim/codecompanion.log
        system_prompt = [[You are an AI programming assistant integrated into Neovim.
You are currently working with a developer who uses Claude Code for high-level planning and research,
and uses you for direct code editing and implementation tasks.
Be concise and focused on the specific task at hand.
Follow the existing code style and conventions in the project.
You have access to tools for file operations, searching, and running commands - use them proactively when needed to accomplish tasks.]],
        tools = {
          auto_use = true, -- Automatically use appropriate tools
          approval_mode = "auto", -- Options: "auto", "manual", "confirm"
        },
      },
    },
  },
}
