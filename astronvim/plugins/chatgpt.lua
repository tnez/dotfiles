local prefix = "<leader><leader>"

require("astronvim.utils").set_mappings({
  n = {
    [prefix] = { desc = "󰻞 ChatGPT" },
  },
  v = {
    [prefix] = { desc = "󰻞 ChatGPT" },
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
        temperature = 0,
        top_p = 1,
        max_tokens = 4096,
        n = 1,
      },
      openai_edit_params = {
        model = "gpt-4-turbo-preview",
        frequency_penalty = 0,
        presence_penalty = 0,
        temperature = 0,
        top_p = 1,
        max_tokens = 4096 - 1024,
        n = 1,
      },
      openai_functions_params = {
        model = "gpt-4-turbo-preview",
        frequency_penalty = 0,
        presence_penalty = 0,
        temperature = 0,
        top_p = 1,
        max_tokens = 4096 - 1024,
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
      prefix .. "<leader>",
      "<cmd>ChatGPT<CR>",
      desc = "ChatGPT",
    },
    {
      prefix .. "e",
      "<cmd>ChatGPTEditWithInstruction<CR>",
      desc = "Edit with instruction",
      mode = { "n", "v" },
    },
    {
      prefix .. "g",
      "<cmd>ChatGPTRun grammar_correction<CR>",
      desc = "Grammar Correction",
      mode = { "n", "v" },
    },
    {
      prefix .. "t",
      "<cmd>ChatGPTRun translate<CR>",
      desc = "Translate",
      mode = { "n", "v" },
    },
    {
      prefix .. "k",
      "<cmd>ChatGPTRun keywords<CR>",
      desc = "Keywords",
      mode = { "n", "v" },
    },
    {
      prefix .. "d",
      "<cmd>ChatGPTRun docstring<CR>",
      desc = "Docstring",
      mode = { "n", "v" },
    },
    {
      prefix .. "a",
      "<cmd>ChatGPTRun add_tests<CR>",
      desc = "Add Tests",
      mode = { "n", "v" },
    },
    {
      prefix .. "o",
      "<cmd>ChatGPTRun optimize_code<CR>",
      desc = "Optimize Code",
      mode = { "n", "v" },
    },
    {
      prefix .. "s",
      "<cmd>ChatGPTRun summarize<CR>",
      desc = "Summarize",
      mode = { "n", "v" },
    },
    {
      prefix .. "f",
      "<cmd>ChatGPTRun fix_bugs<CR>",
      desc = "Fix Bugs",
      mode = { "n", "v" },
    },
    {
      prefix .. "x",
      "<cmd>ChatGPTRun explain_code<CR>",
      desc = "Explain Code",
      mode = { "n", "v" },
    },
    {
      prefix .. "l",
      "<cmd>ChatGPTRun code_readability_analysis<CR>",
      desc = "Code Readability Analysis",
      mode = { "n", "v" },
    },
  },
}