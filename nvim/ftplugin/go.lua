vim.lsp.start {
  name = 'gopls',
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod' },
  root_dir = vim.fs.dirname(vim.fs.find({ 'go.mod', '.git' }, { upward = true })[1]),
  on_attach = function(_, bufnr)
    -- Optional: Set some buffer-specific key mappings
    vim.api.nvim_buf_set_keymap(
      bufnr,
      'n',
      'gd',
      '<cmd>lua vim.lsp.buf.definition()<CR>',
      { noremap = true, silent = true }
    )
    -- Add other mappings as desired
  end,
}
