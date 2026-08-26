require('orgmode').setup {
  org_agenda_files = '~/orgfiles/**/*',
  org_default_notes_file = '~/orgfiles/refile.org',
  -- Don't auto-indent body content under headlines. Default `true` inserts real
  -- spaces (heading level + 1) on every new line and stacks more under list
  -- items, which makes typing lists tedious. Keep content flush left.
  org_adapt_indentation = false,
}

-- Experimental LSP support
vim.lsp.enable('org')
