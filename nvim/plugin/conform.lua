-- NOTE: conform might be redundant with null-ls.nvim
require('conform').setup {
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' }, -- redundant w/ none-ls?
    -- Conform will run multiple formatters sequentially
    python = { 'isort', 'black' },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { 'rustfmt', lsp_format = 'fallback' },
    -- Conform will run the first available formatter
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    cpp = { 'clang_format' },

    sh = { 'beautysh', lsp_format = 'fallback' },

    nix = { 'alejandra', lsp_format = 'fallback' },
    haskell = { 'hindent', lsp_format = 'fallback' },
  },
}

vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})
vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})
