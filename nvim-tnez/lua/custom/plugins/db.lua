return {
  -- database explorer
  -- dependencies command line client: mysql-client, psql(postgresql client), sqlite3, redis-cli
  {
    'tpope/vim-dadbod',
    event = 'VeryLazy',
    dependencies = {
      {
        'kristijanhusak/vim-dadbod-ui',
        cmd = { 'DBUIToggle' },
      },
    },
  },

  -- vim-dadbod-completion cmp source
  {
    'nvim-cmp',
    dependencies = {
      {
        'kristijanhusak/vim-dadbod-completion',
        ft = { 'sql', 'mysql', 'plsql' },
      },
    },
    opts = function()
      require('cmp').setup.filetype({ 'sql', 'mysql', 'plsql' }, {
        sources = {
          { name = 'vim-dadbod-completion' },
        },
      })
    end,
  },
}
