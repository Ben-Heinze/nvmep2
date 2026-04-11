local function mymap(mode, key, value)
  vim.keymap.set(mode, key, value, { silent = true, remap = true })
end

local root_files = {
  '.git',
}

-- pythonPath = function()
--   local handle = io.popen("nix develop . --command bash -c 'which python' 2>/dev/null")
--   local result = handle:read('*a')
--   handle:close()
--
--   -- local handle = io.popen("which python")
--   -- local result = handle:read("*a")
--   -- handle:close()
--
--   if result and result ~= '' then
--     return result:gsub('%s+', '') -- Trim any whitespace
--   end
--
--   -- Fallback to virtual environments
--   local cwd = vim.fn.getcwd()
--   if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
--     return cwd .. '/venv/bin/python'
--   elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
--     return cwd .. '/.venv/bin/python'
--   else
--     return '/usr/bin/python'
--   end
-- end
--
-- local python_executable = pythonPath()
-- vim.print('Using Python executable: ' .. python_executable)

vim.defer_fn(function()
  print('Setting up Python LSP...')
  require('lspconfig').pylsp.setup {
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            ignore = { 'W391' },
            maxLineLength = 100,
          },
        },
      },
    },
  }
  vim.lsp.start {
    name = 'pylsp',
    root_dir = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1]),
    cmd = {
      'pylsp',
      -- Set the PYTHONPATH environment variable for the LSP
      -- env = { PYTHONPATH = python_executable },
    },
    root_markers = { '.git' },
    filetypes = { 'python' },
    capabilities = require('user.lsp').make_client_capabilities(),
  }
end, 1000)

local dap = require('dap')
require('dap-python').setup('python3')

mymap('n', '<Space>du', '<CMD>lua require"dapui".toggle()<CR>')
mymap('n', '<Space>db', '<CMD>DapToggleBreakpoint<CR>')
mymap('n', '<Space>dd', '<CMD>DapContinue<CR>')
mymap('n', '<Space>dc', '<CMD>DapContinue<CR>')
mymap('n', '<Space>dO', '<CMD>DapStepOut<CR>')
mymap('n', '<Space>di', '<CMD>DapStepInto<CR>')
mymap('n', '<Space>do', '<CMD>DapStepOver<CR>')
mymap('n', '<Space>dC', '<CMD>DapClearBreakpoints<CR>')
mymap('n', '<Space>dR', '<CMD>DapRestartFrame<CR>')
mymap('n', '<Space>dP', '<CMD>DapPause<CR>')

-- dap.adapters.python = function(cb, config)
--   if config.request == 'attach' then
--     ---@diagnostic disable-next-line: undefined-field
--     local port = (config.connect or config).port
--     ---@diagnostic disable-next-line: undefined-field
--     local host = (config.connect or config).host or '127.0.0.1'
--     cb {
--       type = 'server',
--       port = assert(port, '`connect.port` is required for a python `attach` configuration'),
--       host = host,
--       options = {
--         source_filetype = 'python',
--       },
--     }
--   else
--     cb {
--       type = 'executable',
--       -- command = 'path/to/virtualenvs/debugpy/bin/python',
--       command = pythonPath(),
--       args = { '-m', 'debugpy.adapter' },
--       options = {
--         source_filetype = 'python',
--       },
--     }
--   end
-- end

-- dap.configurations.python = {
--   {
--     -- The first three options are required by nvim-dap
--     type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
--     request = 'launch';
--     name = "Launch file";
--
--     -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
--
--     program = "${file}"; -- This configuration will launch the current file if used.
--     pythonPath = function()
--       -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
--       -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
--       -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
--       local cwd = vim.fn.getcwd()
--       if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
--         return cwd .. '/venv/bin/python'
--       elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
--         return cwd .. '/.venv/bin/python'
--       else
--         return pythonPath()
--         -- return '/usr/bin/python'
--       end
--     end;
--   },
-- }
