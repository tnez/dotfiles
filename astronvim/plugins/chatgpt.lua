local prefix = "<leader>c"

require("astronvim.utils").set_mappings({
  n = {
    [prefix] = { desc = "ChatGPT" },
  },
})

return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      openai_params = {
        model = "gpt-4-turbo-preview",
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 4000,
        temperature = 0,
        top_p = 1,
        n = 1,
      },
      openai_edit_params = {
        model = "gpt-4-turbo-preview",
        frequency_penalty = 0,
        presence_penalty = 0,
        temperature = 0,
        top_p = 1,
        n = 1,
      },
      use_openai_functions_for_edits = true,
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "folke/trouble.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  opts = {},
  keys = {
    {
      prefix .. "c",
      "<cmd>ChatGPT<CR>",
      desc = "ChatGPT",
    },

    {
      prefix .. "e",
      "<cmd>ChatGPTEditWithInstruction<CR>",
      desc = "Edit with instruction",
    },
    {
      prefix .. "g",
      "<cmd>ChatGPTRun grammar_correction<CR>",
      desc = "Grammar Correction",
    },
    {
      prefix .. "t",
      "<cmd>ChatGPTRun translate<CR>",
      desc = "Translate",
    },
    {
      prefix .. "k",
      "<cmd>ChatGPTRun keywords<CR>",
      desc = "Keywords",
    },
    {
      prefix .. "d",
      "<cmd>ChatGPTRun docstring<CR>",
      desc = "Docstring",
    },
    {
      prefix .. "a",
      "<cmd>ChatGPTRun add_tests<CR>",
      desc = "Add Tests",
    },
    {
      prefix .. "o",
      "<cmd>ChatGPTRun optimize_code<CR>",
      desc = "Optimize Code",
    },
    {
      prefix .. "s",
      "<cmd>ChatGPTRun summarize<CR>",
      desc = "Summarize",
    },
    {
      prefix .. "f",
      "<cmd>ChatGPTRun fix_bugs<CR>",
      desc = "Fix Bugs",
    },
    {
      prefix .. "x",
      "<cmd>ChatGPTRun explain_code<CR>",
      desc = "Explain Code",
    },
    {
      prefix .. "r",
      "<cmd>ChatGPTRun roxygen_edit<CR>",
      desc = "Roxygen Edit",
    },
    {
      prefix .. "l",
      "<cmd>ChatGPTRun code_readability_analysis<CR>",
      desc = "Code Readability Analysis",
    },
  },
}
