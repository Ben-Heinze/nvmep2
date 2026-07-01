require('neotest').setup {
  adapters = {

    require('neotest-jest') {
      jestCommand = 'npm test --',
      jestConfigFile = 'custom.jest.config.ts',
      env = { CI = true },
      cwd = function(_)
        return vim.fn.getcwd()
      end,
    },

    require('neotest-testthat'),

    require('neotest-python') {
      -- Extra arguments for nvim-dap configuration
      -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
      dap = { justMyCode = false },
      -- Command line arguments for runner
      -- Can also be a function to return dynamic values
      args = { '--log-level', 'DEBUG' },
      -- Runner to use. Will use pytest if available by default.
      -- Can be a function to return dynamic value.
      runner = 'pytest',
      -- Custom python path for the runner.
      -- Can be a string or a list of strings.
      -- Can also be a function to return dynamic value.
      -- If not provided, the path will be inferred by checking for
      -- virtual envs in the local directory and for Pipenev/Poetry configs
      python = function()
        return vim.fn.system("nix develop . --command bash -c 'which python' 2>/dev/null"):gsub('%s+', '')
      end,
      -- return vim.fn.system("nix develop . --command bash -c 'which python'")
      -- return '/nix/store/v110k9yl0jh83ggq695ji88yx06lxwwl-python3-3.13.6-env/bin/python'
      -- return vim.fn.system('which python'):gsub('%s+', '')
      -- Returns if a given file path is a test file.
      -- NB: This function is called a lot so don't perform any heavy tasks within it.
      -- is_test_file = function(file_path)
      --   ...
      -- end,
      -- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
      -- instances for files containing a parametrize mark (default: false)
      pytest_discover_instances = true,
    },

    -- require('neotest-java') {
    --   -- config here
    -- },

    -- adapters = {
    --   require('neotest-bash'),
    -- },

    -- require('neotest-java')
    -- require('neotest-gradle')
  },
}
