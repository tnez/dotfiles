return {
  -- Override gitsigns configuration
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      watch_gitdir = {
        interval = 1000, -- Check for git changes every second
        follow_files = true,
      },
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
      },
      diff_opts = {
        internal = true, -- Use internal diff library for better performance
      },
      on_attach = function(bufnr)
        -- Highlight changed text visually
        vim.api.nvim_buf_set_option(bufnr, 'diffopt', 'internal,filler,algorithm:histogram,indent-heuristic')
      end,
    },
  },
}