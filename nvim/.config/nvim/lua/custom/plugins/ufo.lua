return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  --    event = 'VeryLazy',   -- You can make it lazy-loaded via VeryLazy, but comment out if thing doesn't work
  config = function()
    require('ufo').setup {
      -- your config goes here
      -- open_fold_hl_timeout = ...,
      -- provider_selector = function(bufnr, filetype)
      --  ...
      -- end,
    }
  end,
}
