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
  -- Getting-started cheatsheet: an org table of the most useful triggers and
  -- keybinds, grouped into Neovim / LaTeX / Org. Press TAB inside the table to
  -- realign it. Math autosnippets (//, ^^, ;a ...) only fire inside a math zone;
  -- mk / dk open one.
  s(
    'cheat',
    t {
      '| Trigger / Key | Mode | Does                                       |',
      '|---------------+------+--------------------------------------------|',
      '| * Neovim *    |      |                                            |',
      '| <C-n>         | ins  | expand snippet / next completion           |',
      '| <Space>n{c}   | vis  | colour selection: r o y g c b p            |',
      '| <Space>nx     | vis  | clear colour on selection                  |',
      '| <Space>oe     | norm | export to PDF and view in zathura          |',
      '|---------------+------+--------------------------------------------|',
      '| * LaTeX *     |      | (fire inside a math zone; mk/dk open one)  |',
      '| mk / dk       | auto | inline $...$  / display \\[ ... \\]           |',
      '| // ^^ __      | math | \\frac{}{}  superscript  subscript          |',
      '| sq sum int    | math | \\sqrt  \\sum  \\int                          |',
      '| ;a ;b ;th     | math | greek: \\alpha \\beta \\theta                 |',
      '| -> >= inf     | math | \\to  \\geq  \\infty                          |',
      '|---------------+------+--------------------------------------------|',
      '| * Build *     |      |                                            |',
      '| bmat / pmat   | math | NxM matrix; & = next col, \\\\ = new row     |',
      '| cvec          | math | column-vector template                     |',
      '| tbl           | snip | starter org table (TAB realigns/extends)   |',
      '|---------------+------+--------------------------------------------|',
      '| * Org *       |      |                                            |',
      '| title         | snip | note header (title, author, date, macros)  |',
      '| src           | snip | #+begin_src code block (pick language)     |',
      '| ex / quote    | snip | #+begin_example / #+begin_quote            |',
      '| link / img    | snip | [[target][desc]] link / [[file:...]] image |',
    }
  ),
  -- Math symbol cheatsheet for CS / statistics writing. Every Trigger cited here
  -- is a real autosnippet from snippets_math.lua (available in org via
  -- filetype_extend) and fires inside a math zone. Wrapper triggers (cal/bf/rm/bb)
  -- expand around your cursor -- type the letter inside. Press TAB to realign.
  s(
    'symbols',
    t {
      '| Name               | Trigger  | LaTeX                       |',
      '|--------------------+----------+-----------------------------|',
      '| * Sets *           |          |                             |',
      '| Reals / Ints / Nat | RR ZZ NN | \\mathbb{R} \\mathbb{Z} \\mathbb{N} |',
      '| Rationals / Complex| QQ CC    | \\mathbb{Q}  \\mathbb{C}       |',
      '| union / intersect  | uu nn    | \\cup  \\cap                  |',
      '| big union/intersect| bigcup bigcap | \\bigcup_{}^{}  \\bigcap_{}^{} |',
      '| subset / superset  | subs sups | \\subseteq  \\supseteq       |',
      '| setminus / empty   | smin empty | \\setminus  \\emptyset      |',
      '| set literal        | set      | \\{ \\}                       |',
      '|--------------------+----------+-----------------------------|',
      '| * Logic *          |          |                             |',
      '| and / or / not     | land lor neg | \\land  \\lor  \\neg       |',
      '| implies / iff      | => iff   | \\implies  \\iff              |',
      '| forall / exists    | AA EE    | \\forall  \\exists            |',
      '| in / not in        | in notin | \\in  \\notin                 |',
      '|--------------------+----------+-----------------------------|',
      '| * Probability *    |          |                             |',
      '| Expectation        | Ev       | \\mathbb{E}\\left[ \\right]     |',
      '| Variance / Cov     | Var Cov  | \\mathrm{Var}( )  \\mathrm{Cov}( , ) |',
      '| Probability        | Pr       | P\\left( \\right)             |',
      '| Conditional        | cond     | P\\left( \\mid \\right)        |',
      '| Distributed as     | sim      | \\sim                        |',
      '| iid                | iid      | \\overset{iid}{\\sim}         |',
      '| Independent        | perp     | \\perp                       |',
      '| Normal             | norm     | \\mathcal{N}( , )            |',
      '| argmax / argmin    | argmax   | \\underset{}{\\arg\\max}       |',
      '| conv. prob / dist  | convp convd | \\xrightarrow{p}  \\xrightarrow{d} |',
      '|--------------------+----------+-----------------------------|',
      '| * Calculus *       |          |                             |',
      '| Partial (fraction) | part     | \\frac{\\partial}{\\partial x} |',
      '| Bare partial       | pd       | \\partial                    |',
      '| Gradient           | grad     | \\nabla                      |',
      '| Sum / Prod / Int   | sum prod int | \\sum  \\prod  \\int       |',
      '| Limit              | lim      | \\lim_{ \\to }                |',
      '| Vector norm / abs  | vnorm abs | \\lVert \\rVert  \\lvert \\rvert |',
      '|--------------------+----------+-----------------------------|',
      '| * Fonts (wrappers) |          |                             |',
      '| Loss / Big-O       | cal      | \\mathcal{L}  \\mathcal{O}     |',
      '| Dataset / Hypoth.  | cal      | \\mathcal{D}  \\mathcal{H}     |',
      '| Bold vector/matrix | bf       | \\mathbf{x}  \\mathbf{A}       |',
      '| Upright operator   | rm       | \\mathrm{Var}                |',
      '| Blackboard         | bb       | \\mathbb{P}  \\mathbb{1}       |',
      '|--------------------+----------+-----------------------------|',
      '| * Relations *      |          |                             |',
      '| Proportional       | prop     | \\propto                     |',
      '| defined as         | := deq   | \\coloneqq  \\triangleq       |',
      '| approx / not-equal | ~= !=    | \\approx  \\neq               |',
      '| leq / geq          | <= >=    | \\leq  \\geq                  |',
      '| composition        | comp     | \\circ                       |',
      '| oplus/otimes/odot  | oplus otimes odot | \\oplus \\otimes \\odot |',
    }
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
