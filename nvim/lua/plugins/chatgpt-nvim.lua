local HOMEDIR = vim.fn.expand("$HOME")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = HOMEDIR .. "/.scripts/get-env.sh OPEN_AI_API_KEY",
        predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/tnez/awesome-chatgpt-prompts/main/prompts.csv",
      })
    end,
    keys = {
      {
        "<leader>;;",
        function()
          require("chatgpt").openChat()
        end,
        desc = "ChatGPT",
      },
      {
        "<leader>;a",
        function()
          require("chatgpt").selectAwesomePrompt()
        end,
        desc = "ChatGPT: ActAs",
      },
      {
        "<leader>;e",
        function()
          require("chatgpt").edit_with_instructions()
        end,
        desc = "ChatGPT: Edit With Instructions",
      },
    },
    dependencies = {
      {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        {
          "folke/which-key.nvim",
          optional = true,
          opts = {
            defaults = {
              ["<leader>;"] = { name = "+ChatGPT" },
            },
          },
        },
      },
    },
  },
}
