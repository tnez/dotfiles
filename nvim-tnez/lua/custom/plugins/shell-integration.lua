return {
  -- unified navigation between editor and tmux
  {
    'alexghergh/nvim-tmux-navigation',
    opts = {
      disable_when_zoomed = true,
    },
    keys = {
      { '<C-h>', '<cmd>NvimTmuxNavigateLeft<cr>', desc = 'Move focus to the left window' },
      { '<C-l>', '<cmd>NvimTmuxNavigateRight<cr>', desc = 'Move focus to the right window' },
      { '<C-j>', '<cmd>NvimTmuxNavigateDown<cr>', desc = 'Move focus to the lower window' },
      { '<C-k>', '<cmd>NvimTmuxNavigateUp<cr>', desc = 'Move focus to the upper window' },
    },
  },
}
