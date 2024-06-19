return {
  'jackMort/ChatGPT.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    openai_params = {
      model = 'gpt-4o',
      max_tokens = 4000,
    },
    openai_edit_params = {
      model = 'gpt-4o',
      max_tokens = 4000,
    },
  },
  keys = {
    { '<leader>oc', '<cmd>ChatGPT<cr>', desc = '[O]pen [C]hat' },
    {
      '<leader>oc',
      '<cmd>ChatGPTEditWithInstructions<cr>',
      mode = 'v',
      desc = '[O]pen [C]hat to Edit Region',
    },
  },
}
