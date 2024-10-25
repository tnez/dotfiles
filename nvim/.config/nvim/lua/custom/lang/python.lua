return {
  { 'nvim-neotest/neotest-python' },
  {
    'mfussenegger/nvim-dap-python',
    config = function()
      local python_path = 'python'
      if vim.env.VIRTUAL_ENV ~= nil then
        python_path = vim.env.VIRTUAL_ENV .. '/bin/python'
      end

      require('dap-python').setup(python_path)
      require('dap-python').test_runner = 'pytest'
    end,
  },
}
