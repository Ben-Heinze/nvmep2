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

-- "Outside math mode" gate. Reuse the buffer-scanning `in_mathzone` exported by
-- snippets_math.lua -- NOT the tex-`synstack` version in plugin/luasnip.lua, which
-- keys off `texMathZone*` syntax groups that org buffers (treesitter-highlighted,
-- not tex-syntax) never set. snippets_math is required before this file in
-- plugin/luasnip.lua, so the module is already loaded/cached by the time we get here.
local in_mathzone = require('user.snippets_math').in_mathzone
local function not_mathzone()
  return not in_mathzone()
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
  -- Pseudocode block: body is LaTeX math-mode pseudocode, one statement per
  -- line; indent with \quad / \qquad, keywords via \textbf{...}.
  s(
    'pcode',
    fmt(
      [[
#+begin_pseudocode
{}
#+end_pseudocode]],
      { i(1) }
    )
  ),
  -- Ready-made example pseudocode block (condensed nearest neighbour) showing
  -- the idiom: \gets, \textbf keywords, \quad indentation, \text prose.
  s(
    'pcodex',
    t({
      '#+begin_pseudocode',
      '\\mathcal{Z} \\gets \\emptyset',
      '\\textbf{repeat}',
      '\\quad \\textbf{for all } x \\in \\mathcal{X} \\text{ (in random order)}',
      "\\qquad \\text{find } x' \\in \\mathcal{Z} \\text{ such that } \\lVert x-x' \\rVert = \\min_{x^{j} \\in \\mathcal{Z}} \\lVert x-x^{j} \\rVert",
      "\\qquad \\textbf{if } \\operatorname{class}(x) \\neq \\operatorname{class}(x') \\text{ add } x \\text{ to } \\mathcal{Z}",
      '\\textbf{until } \\mathcal{Z} \\text{ does not change}',
      '#+end_pseudocode',
    })
  ),
  -- Callout / admonition: a quote block with a bold label lead-in -- the "real"
  -- mechanism for asides otherwise written as whole-line bold. Renders as a quote
  -- block in-editor, <blockquote> on the site, a quote env in the PDF. <C-n>/Tab
  -- cycles the label; delete it for a plain aside.
  s(
    'callout',
    fmt(
      [[
#+begin_quote
*{}:* {}
#+end_quote]],
      { c(1, { t('Note'), t('Tip'), t('Warning'), t('Definition'), t('Example') }), i(2) }
    )
  ),
  -- "Come back later" marker: an orange highlight (via the `hl` macro seeded by
  -- the `title` snippet) flagging an unfinished section to return to. Renders
  -- orange in-editor (note-highlight.lua), as <span class="hl-orange"> on the
  -- site, and \hl{orange}{...} in the PDF. Gated to prose only (`not_mathzone`),
  -- per the request, so it never expands inside `$...$` / math environments.
  s({
    trig = 'cbl',
    condition = not_mathzone,
    show_condition = not_mathzone,
  }, t('{{{hl(orange,COME BACK LATER)}}}')),
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
  -- Embed a PDF that lives in the current directory. On HTML export the raw
  -- block passes through verbatim, so the viewer shows the PDF inline.
  s(
    'pdf',
    fmt(
      [[
#+begin_export html
<embed src="{}" width="100%" height="{}px" type="application/pdf">
#+end_export]],
      { i(1, 'file.pdf'), i(2, '800') }
    )
  ),
  s('link', fmt('[[{}][{}]]', { i(1, 'target'), i(2, 'description') })),
  -- Cross-referencing other org pages/sections. `file:` links are rewritten
  -- to point at the published .html on export (org-html-link-org-files-as-html).
  -- Drop this on a heading to give it a stable anchor that survives rewording.
  s(
    'cid',
    fmt(
      [[
:PROPERTIES:
:CUSTOM_ID: {}
:END:]],
      { i(1, 'anchor-id') }
    )
  ),
  -- Link to another org page as a whole (path relative to this file).
  s('oref', fmt('[[file:{}][{}]]', { i(1, '../page/index.org'), i(2, 'description') })),
  -- Link to a specific CUSTOM_ID section in another org page.
  s('sref', fmt('[[file:{}::#{}][{}]]', { i(1, '../page/index.org'), i(2, 'anchor-id'), i(3, 'description') })),
  -- Link to a CUSTOM_ID anchor within the current file.
  s('aref', fmt('[[#{}][{}]]', { i(1, 'anchor-id'), i(2, 'description') })),
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
  -- Math openers. `mm` is single-line inline `$…$`. `dm` and `cm` put the opener
  -- on its own line so the org grammar forms a `latex_env` and snacks.image renders
  -- it in-editor; they differ only on export -- `dm` (\(…\)) stays inline/uncentered,
  -- `cm` (\[…\]) is centered display (both PDF and MathJax HTML). Mirrors the
  -- autosnippet pair dk/ck in snippets_math.lua.
  s('mm', fmt('${}$', { i(1) })),
  s(
    'dm',
    fmt(
      [==[
\(
  {}
\)]==],
      { i(1) }
    )
  ),
  s(
    'cm',
    fmt(
      [==[
\[
  {}
\]]==],
      { i(1) }
    )
  ),
  -- Numbered, labelled display equation. Unlike `align*`/`flalign*` (starred =>
  -- unnumbered) this NUMBERS the line, and the `\label` lets you cite that number
  -- elsewhere with `eqref`. Opener on its own line + trailing newline => org forms
  -- a `latex_env`, so it renders in-editor (snacks.image) and exports as a centered
  -- numbered equation (PDF via amsmath; HTML via MathJax once the site sets
  -- `tags: ams` in publish.el). Keep the `eq:` label prefix so refs read clearly.
  s(
    'eqn',
    fmt(
      [==[
\begin{{equation}}
  \label{{eq:{}}}
  {}
\end{{equation}}]==],
      { i(1, 'name'), i(2, 'E = mc^2') }
    )
  ),
  -- Reference the number of an `eqn` block -> "(1)", linked. Wrapped in \(...\) so
  -- MathJax processes it on the HTML site (a bare \eqref in prose sits OUTSIDE math
  -- delimiters, so MathJax would print it literally); the same form resolves in the
  -- PDF (amsmath \eqref). Org internal links [[eq:name]] do NOT work -- org can't
  -- resolve a link to a raw \label -- so this LaTeX form is the mechanism.
  s('eqref', fmt('\\(\\eqref{{eq:{}}}\\)', { i(1, 'name') })),
}, { key = 'org' })
