-- Org-mode buffer ergonomics for math-heavy note-taking.
-- Runs per org buffer (native ftplugin). orgmode.nvim sets its own defaults;
-- these are prose/math conveniences layered on top.

vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = 'nc'
vim.opt_local.spell = true
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- Export this buffer to PDF (Emacs ox-latex) and view it in zathura.
vim.keymap.set('n', '<Space>oe', function()
  require('user.org_pdf').export_and_view()
end, { buffer = true, silent = true, desc = 'Export org → PDF & view (zathura)' })

-- While a zathura preview is open for this buffer, refresh it on every save.
-- No-op until the user opens the preview (via <Space>oe / the winbar button).
vim.api.nvim_create_autocmd('BufWritePost', {
  buffer = 0,
  desc = 'Refresh open org PDF preview in zathura',
  callback = function()
    require('user.org_pdf').on_save()
  end,
})
