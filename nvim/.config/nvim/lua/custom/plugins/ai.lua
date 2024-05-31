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
      model = 'gpt-4-turbo-preview',
    },
    openai_edit_params = {
      model = 'gpt-4-turbo-preview',
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
