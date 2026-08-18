-- Org-mode structure / note-template snippets. Required from plugin/luasnip.lua.
-- General-purpose (no notes directory assumed); expand via <C-n> or the cmp menu.

local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt

local function today()
  return os.date('%Y-%m-%d')
end

ls.add_snippets('org', {
  -- Code block with a language choice (Tab/<C-n> to cycle the language).
  s(
    'src',
    fmt(
      [[
#+begin_src {}
{}
#+end_src]],
      {
        c(1, { t('python'), t('lua'), t('bash'), t('R'), t('cpp'), t('') }),
        i(2),
      }
    )
  ),
  -- Named source block (handy for referencing/tangling results).
  s(
    'nsrc',
    fmt(
      [[
#+NAME: {}
#+begin_src {} :results output
{}
#+end_src]],
      {
        i(1, 'name'),
        c(2, { t('python'), t('lua'), t('bash'), t('R'), t('cpp'), t('') }),
        i(3),
      }
    )
  ),
  -- Single-language code blocks (skip the language choice) for the four
  -- languages user.org_babel can actually execute (see M.languages there).
  s('pysrc', fmt('#+begin_src python\n{}\n#+end_src', { i(1) })),
  s('rsrc', fmt('#+begin_src R\n{}\n#+end_src', { i(1) })),
  s('javasrc', fmt('#+begin_src java\n{}\n#+end_src', { i(1) })),
  s('cppsrc', fmt('#+begin_src cpp\n{}\n#+end_src', { i(1) })),
  s(
    'ex',
    fmt(
      [[
#+begin_example
{}
#+end_example]],
      { i(1) }
    )
  ),
  s(
    'quote',
    fmt(
      [[
#+begin_quote
{}
#+end_quote]],
      { i(1) }
    )
  ),
  -- File header for a new note.
  s(
    'title',
    fmt(
      [[
#+TITLE: {}
#+AUTHOR: {}
#+DATE: {}
#+STARTUP: noindent
#+MACRO: hl @@html:<span class="hl-$1">$2</span>@@@@latex:\hl{{$1}}{{$2}}@@

# This is used to shrink the pdf page margins
#+LATEX_HEADER: \usepackage[left=0.75in,right=0.75in,top=1in,bottom=1in]{{geometry}}

# This is used to shrink the spacing between bullet points
#+LATEX_HEADER: \usepackage{{enumitem}}
#+LATEX_HEADER: \setlist[itemize]{{itemsep=2pt, topsep=4pt}}

{}]],
      {
        i(1, 'Title'),
        i(2, 'Ben Heinze'),
        f(today),
        i(0),
      }
    )
  ),
  -- Image / file link (text only -- no inline rendering).
  s('img', fmt('[[file:{}][{}]]', { i(1, 'path'), i(2, 'caption') })),
  s('link', fmt('[[{}][{}]]', { i(1, 'target'), i(2, 'description') })),
  -- Starter org table: header row, separator, one data row. Press TAB to realign
  -- and to add cells/rows.
  s(
    'tbl',
    fmt(
      [[
| {} | {} |
|----+----|
| {} | {} |]],
      { i(1, 'h1'), i(2, 'h2'), i(3), i(4) }
    )
  ),
  s('date', f(today)),
  -- Citations (org-cite syntax; resolved via the shared bibliography set in
  -- scripts/org-pdf-export.el -- no per-file `#+bibliography:` needed).
  s('cite', fmt('[cite:@{}]', { i(1, 'key') })),
  -- References section + bibliography-printing keyword, dropped at the end
  -- of a note once it has citations.
  s('refs', t { '* References', '', '#+print_bibliography:' }),
  -- Headings.
  s('h1', fmt('* {}', { i(1) })),
  s('h2', fmt('** {}', { i(1) })),
  s('h3', fmt('*** {}', { i(1) })),
  -- Inline / display math delimiters, to open a math zone quickly.
  s('mm', fmt('${}$', { i(1) })),
  s(
    'dm',
    fmt(
      [==[
\[
{}
\]]==],
      { i(1) }
    )
  ),
}, { key = 'org' })
