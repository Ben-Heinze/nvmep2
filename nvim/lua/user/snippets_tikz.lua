-- TikZ graph snippets, registered for the `tex` filetype and shared with `org`
-- via `ls.filetype_extend('org', { 'tex' })` (see plugin/luasnip.lua). Org exports
-- a raw `\begin{tikzpicture}...\end{tikzpicture}` block verbatim to the LaTeX
-- backend, so these expand and render inside `.org` notes too.
--
-- Unlike snippets_math.lua these are *regular* (Tab / <C-n>-expanded) snippets,
-- NOT `in_mathzone`-gated autosnippets: a tikzpicture is not math content and
-- must not fire the moment its trigger is typed.
--
-- Layout is automatic via the pgf `graphdrawing` engine (the `\graph` syntax),
-- which requires the org->PDF exporter to run LuaLaTeX -- see
-- nvim/scripts/org-pdf-export.el, which loads tikz + graphdrawing + quotes and
-- sets `org-latex-compiler "lualatex"`.

local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmta = require('luasnip.extras.fmt').fmta

ls.add_snippets('tex', {
  -- Full auto-laid-out graph. Nodes are `id [as={name \\ value}]` (name and
  -- value stacked inside one rounded box); `<C-n>` on the first field cycles the
  -- graphdrawing algorithm. Add more lines inside `\graph{ ... }`; use `--` for
  -- undirected and `->` for directed edges.
  --
  -- Note: the `[as={... \\ ...}]` form is required for the line break -- the
  -- shorter `id/{...}` node-text shorthand can't contain `\\`.
  s('graph', fmta([[
\begin{tikzpicture}[
  >={Stealth[]},
  every node/.style={draw, rounded corners, align=center, inner sep=4pt},
]
  \graph[<>, node distance=20mm]{
    <> [as={<> \\ <>}] -- <> [as={<> \\ <>}];
  };
\end{tikzpicture}]], {
    c(1, { t('spring layout'), t('layered layout'), t('tree layout') }),
    i(2, 'a'), i(3, 'A'), i(4, '1'),
    i(5, 'b'), i(6, 'B'), i(7, '2'),
  })),

  -- A single node for use inside a `\graph{ ... }`: name and value stacked.
  s('gnode', fmta('<> [as={<> \\\\ <>}]', { i(1, 'id'), i(2, 'name'), i(3, 'value') })),

  -- An edge inside a `\graph{ ... }`; the choice node cycles the arrow style.
  s('gedge', fmta('<> <> <>;', {
    i(1, 'a'),
    c(2, { t('--'), t('->'), t('<->') }),
    i(3, 'b'),
  })),

  -- A weighted / labelled edge via the `quotes` library.
  s('gwedge', fmta('<> <>["<>"] <>;', {
    i(1, 'a'),
    c(2, { t('--'), t('->'), t('<->') }),
    i(3, '1'),
    i(4, 'b'),
  })),
}, {
  key = 'tikz',
})
