-- LaTeX math autosnippets, registered for the `tex` filetype and shared with
-- `org` via `ls.filetype_extend('org', { 'tex' })` (see plugin/luasnip.lua).
--
-- Every snippet here is an *autosnippet* (expands the moment its trigger is
-- typed) gated by `in_mathzone()`, so triggers never fire in prose -- only
-- inside `$...$`, `$$...$$`, `\(...\)`, `\[...\]`, or a math environment.

local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

-- LaTeX environments whose interior counts as a math zone.
local MATH_ENVS = {
  equation = true,
  align = true,
  alignat = true,
  gather = true,
  multline = true,
  flalign = true,
  math = true,
  displaymath = true,
  array = true,
  cases = true,
  matrix = true,
  pmatrix = true,
  bmatrix = true,
  Bmatrix = true,
  vmatrix = true,
  Vmatrix = true,
  smallmatrix = true,
  split = true,
  aligned = true,
  gathered = true,
}

-- Returns true when the cursor sits inside a LaTeX math context. Works for both
-- `tex` and `org` by scanning the buffer text above the cursor and tracking the
-- open/close state of `$`, `$$`, `\(`, `\[` and math environments. Bounded to
-- the last 500 lines (math practically never spans further) so the per-keystroke
-- cost stays small.
local function in_mathzone()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local start = math.max(0, row - 500)
  local lines = vim.api.nvim_buf_get_lines(0, start, row, false)
  if #lines == 0 then
    return false
  end
  lines[#lines] = lines[#lines]:sub(1, col)

  local inline, display, depth = false, false, 0
  for _, line in ipairs(lines) do
    -- A blank line or an org heading ends any open inline/display span in
    -- ordinary prose. Without this, one stray *unpaired* `$` earlier in the
    -- buffer (e.g. prose mentioning the `$` character itself, like `~$~`)
    -- flips `inline` on with no matching partner to flip it back off, so
    -- every word for the rest of the buffer misreads as math. Resetting at
    -- paragraph boundaries contains that damage to a single paragraph.
    if line:match('^%s*$') or line:match('^%*+%s') then
      inline, display = false, false
    end

    -- Drop escaped backslashes and escaped dollars so they don't toggle state.
    local text = line:gsub('\\\\', ''):gsub('\\%$', '')

    local idx, n = 1, #text
    while idx <= n do
      local two = text:sub(idx, idx + 1)
      if two == '$$' then
        display = not display
        idx = idx + 2
      elseif two == '\\(' or two == '\\[' then
        display = true
        idx = idx + 2
      elseif two == '\\)' or two == '\\]' then
        display = false
        idx = idx + 2
      elseif text:sub(idx, idx) == '$' then
        inline = not inline
        idx = idx + 1
      else
        local benv = text:match('^\\begin{(%a+)%*?}', idx)
        local eenv = benv == nil and text:match('^\\end{(%a+)%*?}', idx) or nil
        if benv and MATH_ENVS[benv] then
          depth = depth + 1
          idx = (text:find('}', idx, true) or idx) + 1
        elseif eenv and MATH_ENVS[eenv] then
          depth = math.max(0, depth - 1)
          idx = (text:find('}', idx, true) or idx) + 1
        else
          idx = idx + 1
        end
      end
    end
  end
  return inline or display or depth > 0
end

-- Autosnippet constrained to math context. `wordy` (default true) keeps a word
-- boundary before the trigger; pass false for symbolic triggers like `//`.
local function ms(trig, nodes, wordy)
  return s({
    trig = trig,
    snippetType = 'autosnippet',
    wordTrig = wordy ~= false,
    condition = in_mathzone,
    show_condition = in_mathzone,
  }, nodes)
end

local snips = {
  -- Fractions, roots, scripts
  ms('//', fmta('\\frac{<>}{<>}', { i(1, 'num'), i(2, 'den') }), false),
  ms('frac', fmta('\\frac{<>}{<>}', { i(1, 'num'), i(2, 'den') })), -- word-trigger alias of //
  ms('^^', fmta('^{<>}', { i(1, 'exp') }), false),
  ms('__', fmta('_{<>}', { i(1, 'idx') }), false),
  ms('sq', fmta('\\sqrt{<>}', { i(1, 'x') })),
  ms('nrt', fmta('\\sqrt[<>]{<>}', { i(1, 'n'), i(2, 'x') })),

  -- Big operators
  ms('sum', fmta('\\sum_{<>}^{<>} <>', { i(1, 'i=1'), i(2, 'n'), i(3, 'a_i') })),
  ms('prod', fmta('\\prod_{<>}^{<>} <>', { i(1, 'i=1'), i(2, 'n'), i(3, 'a_i') })),
  ms('int', fmta('\\int_{<>}^{<>} <> \\, d<>', { i(1, 'a'), i(2, 'b'), i(3, 'f(x)'), i(4, 'x') })),
  ms('lim', fmta('\\lim_{<> \\to <>} <>', { i(1, 'n'), i(2, '\\infty'), i(3, 'a_n') })),

  -- Log-like functions (bare operators, so `\log_2`, `\exp(x)` compose freely)
  ms('log', t('\\log')),
  ms('exp', t('\\exp')),
  ms('min', t('\\min')), -- \min_{x} composes via the `_` autosnippet
  ms('max', t('\\max')),

  -- Derivatives
  ms('dd', fmta('\\frac{d<>}{d<>}', { i(1, 'y'), i(2, 'x') })),
  ms('part', fmta('\\frac{\\partial <>}{\\partial <>}', { i(1, 'f'), i(2, 'x') })),

  -- Accents / wrappers
  ms('bar', fmta('\\bar{<>}', { i(1, 'x') })),
  ms('hat', fmta('\\hat{<>}', { i(1, 'x') })),
  ms('vec', fmta('\\vec{<>}', { i(1, 'v') })),
  ms('tt', fmta('\\text{<>}', { i(1, 'text') })),
  ms('text', fmta('\\text{<>}', { i(1, 'text') })),
  -- Over-/under-set: place text above, below, or both around a base symbol.
  -- Order is {annotation}{base}, so tabstop 1 is the text, 2 the base.
  ms('over', fmta('\\overset{<>}{<>}', { i(1, 'above'), i(2, 'x') })),
  ms('under', fmta('\\underset{<>}{<>}', { i(1, 'below'), i(2, 'x') })),
  ms('ounder', fmta('\\overset{<>}{\\underset{<>}{<>}}', { i(1, 'above'), i(2, 'below'), i(3, 'x') })), -- text above AND below

  -- Font wrappers (type the letter inside)
  ms('cal', fmta('\\mathcal{<>}', { i(1, 'L') })), -- \mathcal{L} loss, \mathcal{O} big-O, \mathcal{D} data, \mathcal{H} hypothesis
  ms('bf', fmta('\\mathbf{<>}', { i(1, 'x') })), -- bold vectors / matrices
  ms('rm', fmta('\\mathrm{<>}', { i(1, 'op') })), -- upright multi-letter operators
  ms('bb', fmta('\\mathbb{<>}', { i(1, 'R') })), -- e.g. \mathbb{P}, indicator \mathbb{1}

  -- Vector calculus (bare \partial; `part` stays the fraction form)
  ms('pd', t('\\partial')),
  ms('grad', t('\\nabla')),
  ms('vnorm', fmta('\\lVert <> \\rVert', { i(1, 'v') })), -- `norm` is the Normal distribution
  ms('abs', fmta('\\lvert <> \\rvert', { i(1, 'x') })),
  ms('floor', fmta('\\lfloor <> \\rfloor', { i(1, 'x') })),
  ms('ceil', fmta('\\lceil <> \\rceil', { i(1, 'x') })),
  -- Auto-sized curly braces (type `lbrace`/`rbrace` to place each side).
  ms('lbrace', t('\\left\\{')),
  ms('rbrace', t('\\right\\}')),
  -- Auto-sized parentheses / brackets: wrap the tabstop in \left( \right).
  ms('lr(', fmta('\\left( <> \\right)', { i(1, 'x') }), false),
  ms('lr[', fmta('\\left[ <> \\right]', { i(1, 'x') }), false),

  -- Relations / symbols
  ms('->', t('\\to'), false),
  ms('!=', t('\\neq'), false),
  ms('>=', t('\\geq'), false),
  ms('<=', t('\\leq'), false),
  ms('~=', t('\\approx'), false),
  ms('equiv', t('\\equiv')),
  ms('+-', t('\\pm'), false),
  ms('=>', t('\\implies'), false),
  ms(':=', t('\\coloneqq'), false),
  ms('iff', t('\\iff')),
  ms('prop', t('\\propto')),
  ms('deq', t('\\triangleq')),
  ms('inf', t('\\infty')),
  ms('cdot', t('\\cdot')),
  ms('xx', t('\\times'), false),
  ms('...', t('\\ldots'), false),

  -- Sets / logic (uu = \cup, nn = \cap already; here the rest)
  ms('nn', t('\\cap')),
  ms('uu', t('\\cup')),
  ms('bigcup', fmta('\\bigcup_{<>}^{<>}', { i(1, 'i=1'), i(2, 'n') })),
  ms('bigcap', fmta('\\bigcap_{<>}^{<>}', { i(1, 'i=1'), i(2, 'n') })),
  ms('smin', t('\\setminus')),
  ms('subs', t('\\subseteq')),
  ms('sups', t('\\supseteq')),
  ms('empty', t('\\emptyset')),
  ms('set', fmta('\\{ <> \\}', { i(1, 'x') })),
  ms('oplus', t('\\oplus')),
  ms('otimes', t('\\otimes')),
  ms('odot', t('\\odot')),
  ms('land', t('\\land')),
  ms('lor', t('\\lor')),
  ms('neg', t('\\neg')),
  ms('in', t('\\in')),
  ms('notin', t('\\notin')),
  ms('AA', t('\\forall'), false),
  ms('EE', t('\\exists'), false),

  -- Environments
  ms(
    'beg',
    fmta(
      [[
\begin{<>}
  <>
\end{<>}]],
      { i(1, 'env'), i(2, 'body'), rep(1) }
    )
  ),
  ms(
    'ali',
    fmta(
      [[
\begin{align*}
  <>
\end{align*}]],
      { i(1, 'a &= b') }
    )
  ),
  -- Multi-line equation aligned on the `=` sign. `&` marks the alignment column
  -- and `\\` ends a row, so the second line's `=` sits under the first. Add more
  -- `&= <> \\` lines as needed.
  ms(
    'aeq',
    fmta(
      [[
\begin{align*}
  <> &= <> \\
  &= <>
\end{align*}]],
      { i(1, 'a'), i(2, 'b'), i(3, 'c') }
    )
  ),
  ms(
    'cases',
    fmta(
      [[
\begin{cases}
  <>
\end{cases}]],
      { i(1, 'value & condition') }
    )
  ),
  ms(
    'bmat',
    fmta(
      [[
\begin{bmatrix}
  <>
\end{bmatrix}]],
      { i(1, 'a & b') }
    )
  ),
  ms(
    'pmat',
    fmta(
      [[
\begin{pmatrix}
  <>
\end{pmatrix}]],
      { i(1, 'a & b') }
    )
  ),
  -- Column vector: \\-separated tabstops (add more rows as needed).
  ms(
    'cvec',
    fmta(
      [[
\begin{bmatrix}
  <> \\
  <>
\end{bmatrix}]],
      { i(1, 'a'), i(2, 'b') }
    )
  ),

  -- Statistics: moments & estimators
  ms('Ev', fmta('\\mathbb{E}\\left[ <> \\right]', { i(1, 'X') })),
  ms('Var', fmta('\\mathrm{Var}\\left( <> \\right)', { i(1, 'X') })),
  ms('Cov', fmta('\\mathrm{Cov}\\left( <>, <> \\right)', { i(1, 'X'), i(2, 'Y') })),
  ms('Cor', fmta('\\mathrm{Corr}\\left( <>, <> \\right)', { i(1, 'X'), i(2, 'Y') })),
  ms('xbar', t('\\bar{x}')),
  ms('bhat', t('\\hat{\\beta}')),
  ms('thhat', t('\\hat{\\theta}')),
  ms('phat', t('\\hat{p}')),

  -- Statistics: distributions (capitalised triggers avoid clashing with words)
  ms('norm', fmta('\\mathcal{N}\\left( <>, <> \\right)', { i(1, '\\mu'), i(2, '\\sigma^2') })),
  ms('nrm', fmta('\\left\\lVert <> \\right\\rVert', { i(1, 'x') })),
  ms('Pois', fmta('\\mathrm{Poisson}(<>)', { i(1, '\\lambda') })),
  ms('Bin', fmta('\\mathrm{Binomial}(<>, <>)', { i(1, 'n'), i(2, 'p') })),
  ms('Unif', fmta('\\mathrm{Uniform}(<>, <>)', { i(1, 'a'), i(2, 'b') })),
  ms('Bern', fmta('\\mathrm{Bernoulli}(<>)', { i(1, 'p') })),
  ms('Gam', fmta('\\mathrm{Gamma}(<>, <>)', { i(1, '\\alpha'), i(2, '\\beta') })),
  ms('Expo', fmta('\\mathrm{Exponential}(<>)', { i(1, '\\lambda') })),
  ms('Beta', fmta('\\mathrm{Beta}(<>, <>)', { i(1, '\\alpha'), i(2, '\\beta') })),
  ms('Geom', fmta('\\mathrm{Geometric}(<>)', { i(1, 'p') })),

  -- Statistics: probability & relations
  ms('Pr', fmta('P\\left( <> \\right)', { i(1, 'A') })),
  ms('cond', fmta('P\\left( <> \\mid <> \\right)', { i(1, 'A'), i(2, 'B') })),
  -- Indicator piecewise body: 1 if the condition holds, else 0. Deliberately
  -- omits the `\mathbb{1}_{} = ` head so the caller writes their own indicator
  -- symbol/subscript. Capitalised trigger (like Pr/Var) so it never fires
  -- inside words like "independent"/"individual" typed in \text{}.
  ms('Ind', fmta('\\begin{cases} 1 & <> \\\\ 0 & \\text{otherwise} \\end{cases}', { i(1, 'condition') })),
  ms('given', t('\\mid')),
  ms('mid', t('\\mid')),
  ms('sim', t('\\sim')),
  ms('iid', t('\\overset{\\text{iid}}{\\sim}')),
  ms('perp', t('\\perp')),
  ms('iperp', t('\\perp\\!\\!\\!\\perp')),

  -- Statistics: sums, optimisation, convergence
  ms('nsum', t('\\sum_{i=1}^{n}')),
  ms('nprod', t('\\prod_{i=1}^{n}')),
  ms('argmax', fmta('\\underset{<>}{\\arg\\max}\\;', { i(1, '\\theta') })),
  ms('argmin', fmta('\\underset{<>}{\\arg\\min}\\;', { i(1, '\\theta') })),
  ms('convp', t('\\xrightarrow{p}')),
  ms('convd', t('\\xrightarrow{d}')),
  ms('binom', fmta('\\binom{<>}{<>}', { i(1, 'n'), i(2, 'k') })),

  -- Blackboard sets (case-distinct from nn/uu/AA/EE)
  ms('RR', t('\\mathbb{R}')),
  ms('ZZ', t('\\mathbb{Z}')),
  ms('NN', t('\\mathbb{N}')),
  ms('QQ', t('\\mathbb{Q}')),
  ms('CC', t('\\mathbb{C}')),

  -- Named subscripts: `xn`/`xi`/`xj` -> `x_{n}`/`x_{i}`/`x_{j}` (letter subscripts
  -- the digit auto-subscript below can't reach). wordTrig (the `ms` default) so
  -- they never fire inside words like `\sin`, `\max`, or `\exists`.
  ms('xn', t('x_{n}')),
  ms('xi', t('x_{i}')),
  ms('xj', t('x_{j}')),

  -- Auto-subscript: `x1` -> `x_{1}`, `b0` -> `b_{0}` (math only).
  s(
    {
      trig = '([%a])(%d)',
      regTrig = true,
      wordTrig = false,
      snippetType = 'autosnippet',
      condition = in_mathzone,
      show_condition = in_mathzone,
    },
    f(function(_, snip)
      return snip.captures[1] .. '_{' .. snip.captures[2] .. '}'
    end)
  ),

  -- Fast math-entry (NOT gated -- these OPEN a math zone).
  s({ trig = 'mk', snippetType = 'autosnippet' }, fmta('$<>$', { i(1) })),
  s({ trig = 'dk', snippetType = 'autosnippet' }, fmta('\\[\n  <>\n\\]', { i(1) })),
}

-- Greek letters via a `;` prefix (e.g. `;a` -> `\alpha`), which avoids
-- colliding with ordinary words.
local greek = {
  a = 'alpha',
  b = 'beta',
  g = 'gamma',
  d = 'delta',
  e = 'epsilon',
  z = 'zeta',
  h = 'eta',
  th = 'theta',
  k = 'kappa',
  l = 'lambda',
  m = 'mu',
  n = 'nu',
  x = 'xi',
  p = 'pi',
  r = 'rho',
  s = 'sigma',
  ta = 'tau',
  ph = 'phi',
  ch = 'chi',
  ps = 'psi',
  o = 'omega',
}
for key, name in pairs(greek) do
  table.insert(snips, ms(';' .. key, t('\\' .. name), false))
end

-- A few capital Greek letters.
local greek_upper = {
  G = 'Gamma',
  D = 'Delta',
  Th = 'Theta',
  L = 'Lambda',
  X = 'Xi',
  P = 'Pi',
  S = 'Sigma',
  Ph = 'Phi',
  Ps = 'Psi',
  O = 'Omega',
}
for key, name in pairs(greek_upper) do
  table.insert(snips, ms(';' .. key, t('\\' .. name), false))
end

ls.add_snippets('tex', snips, { key = 'math' })

return { in_mathzone = in_mathzone }
