local function mymap(mode, key, value)
  vim.keymap.set(mode, key, value, { silent = true, remap = true })
end

vim.lsp.start {
  'ts_ls',
  cmd = { 'typescript-language-server', '--stdio' },
}
require('dap-vscode-js').setup {
  -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  -- debugger_path = '/nix/store/d2fsblp1jz3i5c0g902xs4mv1mkigrb4-vscode-js-debug-1.104.0/',
  debugger_cmd = { 'js-debug' }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
  -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
  -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
  -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
}

for _, language in ipairs { 'typescript', 'javascript' } do
  require('dap').configurations[language] = {
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      cwd = '${workspaceFolder}',
    },

    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach',
      processId = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
    },
  }
end

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
