--https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    '3rd/image.nvim', -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_by_name = {
          '.DS_Store',
          '.git',
          '.venv',
          'node_modules',
        },
      },
    },
    window = {
      position = 'right',
      mappings = {
        ['l'] = 'open',
        ['h'] = 'close_node',
      },
    },
  },
  keys = {
    { '<leader>ob', '<cmd>Neotree buffers toggle=true<cr>', desc = '[O]pen [B]uffers' },
    { '<leader>of', '<cmd>Neotree reveal=true toggle=true<cr>', desc = '[O]pen [F]iles' },
    { '<leader>og', '<cmd>Neotree git_status<cr>', desc = '[O]pen [G]it Status' },
  },
}
