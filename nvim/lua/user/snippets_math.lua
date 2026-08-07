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
  local text = table.concat(lines, '\n')
  -- Drop escaped backslashes and escaped dollars so they don't toggle state.
  text = text:gsub('\\\\', ''):gsub('\\%$', '')

  local inline, display, depth = false, false, 0
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
  ms('//', fmta('\\frac{<>}{<>}', { i(1), i(2) }), false),
  ms('^^', fmta('^{<>}', { i(1) }), false),
  ms('__', fmta('_{<>}', { i(1) }), false),
  ms('sq', fmta('\\sqrt{<>}', { i(1) })),
  ms('nrt', fmta('\\sqrt[<>]{<>}', { i(1), i(2) })),

  -- Big operators
  ms('sum', fmta('\\sum_{<>}^{<>} <>', { i(1), i(2), i(3) })),
  ms('prod', fmta('\\prod_{<>}^{<>} <>', { i(1), i(2), i(3) })),
  ms('int', fmta('\\int_{<>}^{<>} <> \\, d<>', { i(1), i(2), i(3), i(4) })),
  ms('lim', fmta('\\lim_{<> \\to <>} <>', { i(1, 'n'), i(2, '\\infty'), i(3) })),

  -- Derivatives
  ms('dd', fmta('\\frac{d<>}{d<>}', { i(1), i(2, 'x') })),
  ms('part', fmta('\\frac{\\partial <>}{\\partial <>}', { i(1), i(2, 'x') })),

  -- Accents / wrappers
  ms('bar', fmta('\\bar{<>}', { i(1) })),
  ms('hat', fmta('\\hat{<>}', { i(1) })),
  ms('vec', fmta('\\vec{<>}', { i(1) })),
  ms('tt', fmta('\\text{<>}', { i(1) })),

  -- Relations / symbols
  ms('->', t('\\to '), false),
  ms('!=', t('\\neq '), false),
  ms('>=', t('\\geq '), false),
  ms('<=', t('\\leq '), false),
  ms('~=', t('\\approx '), false),
  ms('+-', t('\\pm '), false),
  ms('=>', t('\\implies '), false),
  ms('inf', t('\\infty')),
  ms('cdot', t('\\cdot ')),
  ms('xx', t('\\times '), false),
  ms('nn', t('\\cap ')),
  ms('uu', t('\\cup ')),
  ms('in', t('\\in ')),
  ms('notin', t('\\notin ')),
  ms('AA', t('\\forall '), false),
  ms('EE', t('\\exists '), false),

  -- Environments
  ms(
    'beg',
    fmta(
      [[
\begin{<>}
  <>
\end{<>}]],
      { i(1), i(2), rep(1) }
    )
  ),
  ms(
    'ali',
    fmta(
      [[
\begin{align*}
  <>
\end{align*}]],
      { i(1) }
    )
  ),
  ms(
    'cases',
    fmta(
      [[
\begin{cases}
  <>
\end{cases}]],
      { i(1) }
    )
  ),
  ms(
    'bmat',
    fmta(
      [[
\begin{bmatrix}
  <>
\end{bmatrix}]],
      { i(1) }
    )
  ),
  ms(
    'pmat',
    fmta(
      [[
\begin{pmatrix}
  <>
\end{pmatrix}]],
      { i(1) }
    )
  ),
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
  table.insert(snips, ms(';' .. key, t('\\' .. name .. ' '), false))
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
  table.insert(snips, ms(';' .. key, t('\\' .. name .. ' '), false))
end

ls.add_snippets('tex', snips, { key = 'math' })

return { in_mathzone = in_mathzone }
