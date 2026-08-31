require('orgmode').setup {
  org_agenda_files = '~/orgfiles/**/*',
  org_default_notes_file = '~/orgfiles/refile.org',
  -- Don't auto-indent body content under headlines. Default `true` inserts real
  -- spaces (heading level + 1) on every new line and stacks more under list
  -- items, which makes typing lists tedious. Keep content flush left.
  org_adapt_indentation = false,

  -- Workflow keywords. `RETURN` marks a section I started writing but left
  -- unfinished and need to come back to. It sits *before* the `|`, so org counts
  -- it as an active (not-done) state -- such headings show up as outstanding in
  -- agendas, just like TODO. Cycle a heading's state with `cit` (forward:
  -- none -> TODO -> RETURN -> DONE -> none) or `ciT` (backward). To instead get a
  -- one-key popup that jumps straight to a state, append shortcut letters --
  -- `{ 'TODO(t)', 'RETURN(r)', '|', 'DONE(d)' }` -- which makes `cit` open a
  -- selector (press t/r/d) rather than cycle.
  org_todo_keywords = { 'TODO', 'RETURN', '|', 'DONE' },

  -- Colour RETURN bold orange so half-finished sections stand out when scanning,
  -- distinct from TODO (red) and DONE (green). Face string syntax is parsed by
  -- orgmode's colors/highlights.lua (`:foreground <hex>`, `:weight bold`, etc.).
  org_todo_keyword_faces = {
    RETURN = ':foreground #FE8019 :weight bold',
  },
}

-- Experimental LSP support
vim.lsp.enable('org')
