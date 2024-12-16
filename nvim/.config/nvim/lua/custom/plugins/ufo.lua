return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  config = function()
    require('ufo').setup {
      provider_selector = function(_, filetype)
        if filetype == 'yaml' or filetype == 'markdown' then
          return { 'treesitter', 'indent' }
        else
          return { 'lsp', 'indent' }
        end
      end,
    }
  end,
}
