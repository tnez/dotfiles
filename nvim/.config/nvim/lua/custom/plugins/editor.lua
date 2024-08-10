return {
  { -- format files according to `.editorconfig` file
    'editorconfig/editorconfig-vim',
  },

  { -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',
  },

  { -- "gc" to comment visual regions/lines
    'numToStr/Comment.nvim',
    opts = {},
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<C-f>',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },

  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  {
    'gbprod/yanky.nvim',
    opts = {},
    keys = {
        -- stylua: ignore
      { "<leader>p", function() require("telescope").extensions.yank_history.yank_history({ }) end, desc = "Open Yank History" },
      { 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank text' },
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put yanked text after cursor' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put yanked text before cursor' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put yanked text after selection' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put yanked text before selection' },
      { '[y', '<Plug>(YankyCycleForward)', desc = 'Cycle forward through yank history' },
      { ']y', '<Plug>(YankyCycleBackward)', desc = 'Cycle backward through yank history' },
      { ']p', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put indented after cursor (linewise)' },
      { '[p', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put indented before cursor (linewise)' },
      { ']P', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put indented after cursor (linewise)' },
      { '[P', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put indented before cursor (linewise)' },
      { '>p', '<Plug>(YankyPutIndentAfterShiftRight)', desc = 'Put and indent right' },
      { '<p', '<Plug>(YankyPutIndentAfterShiftLeft)', desc = 'Put and indent left' },
      { '>P', '<Plug>(YankyPutIndentBeforeShiftRight)', desc = 'Put before and indent right' },
      { '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)', desc = 'Put before and indent left' },
      { '=p', '<Plug>(YankyPutAfterFilter)', desc = 'Put after applying a filter' },
      { '=P', '<Plug>(YankyPutBeforeFilter)', desc = 'Put before applying a filter' },
    },
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Autopairs
      require('mini.pairs').setup()

      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      statusline.setup()

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  { -- For makring and jumping around buffers
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      save_on_toggle = true,
    },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      -- Setting Marks
      local add_mark = function(idx)
        if idx then
          return function()
            harpoon:list():replace_at(idx)
          end
        end

        return function()
          harpoon:list():add()
        end
      end
      vim.keymap.set('n', 'm.', add_mark(nil), { desc = 'Append to Harpoon Marks' })
      vim.keymap.set('n', 'mA', add_mark(1), { desc = 'Add to Harpoon Marks [a]' })
      vim.keymap.set('n', 'mS', add_mark(2), { desc = 'Add to Harpoon Marks [s]' })
      vim.keymap.set('n', 'mD', add_mark(3), { desc = 'Add to Harpoon Marks [d]' })
      vim.keymap.set('n', 'mF', add_mark(4), { desc = 'Add to Harpoon Marks [f]' })

      -- Clearing Marks
      local clear_marks = function()
        harpoon:list():clear()
      end
      vim.keymap.set('n', 'mx', clear_marks, { desc = 'Clear Marks' })

      -- Searching Marks
      local open_harpoon_picker = function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end
      vim.keymap.set('n', 'mm', open_harpoon_picker, { desc = 'Open Marks' })

      -- Jumping to marks
      local function jump_to_mark(idx)
        harpoon:list():select(idx)
      end
      vim.keymap.set('n', 'ma', function()
        jump_to_mark(1)
      end, { desc = 'Jump to mark 1' })
      vim.keymap.set('n', 'ms', function()
        jump_to_mark(2)
      end, { desc = 'Jump to mark 2' })
      vim.keymap.set('n', 'md', function()
        jump_to_mark(3)
      end, { desc = 'Jump to mark 3' })
      vim.keymap.set('n', 'mf', function()
        jump_to_mark(4)
      end, { desc = 'Jump to mark 4' })

      -- Opening in splits
      harpoon:extend {
        UI_CREATE = function(cx)
          vim.keymap.set('n', '/', function()
            harpoon.ui:select_menu_item { vsplit = true }
          end, { buffer = cx.bufnr })

          vim.keymap.set('n', '-', function()
            harpoon.ui:select_menu_item { split = true }
          end, { buffer = cx.bufnr })
        end,
      }
    end,
  },

  -- TODO: Decide if I want to keep `tris203/precongnition.nvim`
  -- Plugin that hints useful movements using virtual text
  {
    'tris203/precognition.nvim',
    very_lazy = true,
    opts = {
      startVisible = true,
      showBlankVirtLine = true,
      highlightColor = { link = 'Comment' },
      hints = {
        Caret = { text = '^', prio = 2 },
        Dollar = { text = '$', prio = 1 },
        MatchingPair = { text = '%', prio = 5 },
        Zero = { text = '0', prio = 1 },
        w = { text = 'w', prio = 10 },
        b = { text = 'b', prio = 9 },
        e = { text = 'e', prio = 8 },
        W = { text = 'W', prio = 7 },
        B = { text = 'B', prio = 6 },
        E = { text = 'E', prio = 5 },
      },
      gutterHints = {
        G = { text = 'G', prio = 10 },
        gg = { text = 'gg', prio = 9 },
        PrevParagraph = { text = '{', prio = 8 },
        NextParagraph = { text = '}', prio = 8 },
      },
    },
    keys = {
      {
        'gm',
        function()
          require('precognition').peek()
        end,
        desc = 'Peek Movements',
      },
      {
        '<leader>um',
        function()
          require('precognition').toggle()
        end,
        desc = 'Toggle Movements',
      },
    },
  },
}
