vim.defer_fn(function()
  if vim.fn.executable('R') == 0 then
    return
  end
  vim.lsp.start {
    name = 'r',
    root_dir = vim.fs.dirname(vim.fs.find({ '.git' }, { upward = true })[1]),
    cmd = {
      'R',
      '--slave',
      '-e',
      'options(lintr = list(trailing_blank_lines_linter = NULL, snake_case_linter = NULL)); languageserver::run()',
    },
    root_markers = { '.clangd', 'compile_commands.json' },
    filetypes = { 'r', 'R' },
    capabilities = require('user.lsp').make_client_capabilities(),
  }
end, 1000)
