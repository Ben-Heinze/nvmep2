-- Tabbed "help" popup (Awesome-WM hotkeys style) for the note-writing setup.
-- Openable anywhere with <Space>? : a floating window with major tabs (Neovim,
-- LaTeX, Snippets, Glyphs, Logic/Relations, Matrices/Vectors, Statistics), each
-- split into subsections. Search with `/` (native, current tab) or Telescope
-- (<C-f>, fuzzy over every symbol). <CR> on a symbol row inserts its LaTeX at
-- the cursor of the window you opened from; <CR> on a snippet row (kind='snip')
-- fires the real LuaSnip snippet, tab-stops and all.
--
-- Self-contained on purpose: nvim-dev bakes a store snapshot of the config that
-- sits first on the runtimepath, so a lua/user/ module would be shadowed. All the
-- data + logic lives in this single plugin file (new basename => sourced live).

if vim.g.did_load_help_popup_plugin then
  return
end
vim.g.did_load_help_popup_plugin = true

local api = vim.api

-- Every trig/keybind below is verified against snippets_math.lua,
-- snippets_org.lua, note-highlight.lua, ftplugin/org.lua and keymaps.lua.
-- A row is { trigger, latex/output, description }. `kind`:
--   'auto' math autosnippet (fires in a math zone), 'snip' a snippet (type the
--   trigger + <C-n>, or <CR> here to expand it), 'key' a keybinding. Defaults to
--   'auto'. `kind` drives what <CR> does: 'snip' expands, everything else inserts.
local tabs = {
  {
    name = 'Neovim',
    sections = {
      {
        title = 'Completion / snippets',
        kind = 'key',
        rows = {
          { '<C-n>', '', 'expand snippet / next completion item' },
          { '<Space>?', '', 'open this help popup (anywhere)' },
        },
      },
      {
        title = 'Notes: colour (visual mode)',
        kind = 'key',
        rows = {
          { '<Space>nr', '', 'highlight selection red' },
          { '<Space>no', '', 'highlight selection orange' },
          { '<Space>ny', '', 'highlight selection yellow' },
          { '<Space>ng', '', 'highlight selection green' },
          { '<Space>nc', '', 'highlight selection cyan' },
          { '<Space>nb', '', 'highlight selection blue' },
          { '<Space>np', '', 'highlight selection purple' },
          { '<Space>nx', '', 'clear highlight on selection' },
        },
      },
      {
        title = 'Org / export',
        kind = 'key',
        rows = {
          { '<Space>oe', '', 'export org buffer to PDF & view (zathura)' },
        },
      },
      {
        title = 'Editing / lists',
        kind = 'key',
        rows = {
          { '<C-c>', '', 'toggle quickfix list' },
          { '[d / ]d', '', 'previous / next diagnostic' },
          { '<Space>st', '', 'toggle spell check' },
          { '<Space>ss', '', 'spell: suggest replacements' },
        },
      },
    },
  },
  {
    name = 'LaTeX',
    sections = {
      {
        title = 'Math zones',
        rows = {
          { 'mk', '$ $', 'inline math (opens a zone)' },
          { 'dk', '\\[  \\]', 'display math (opens a zone)' },
          { 'mm', '$ $', 'inline math (org snippet)' },
          { 'dm', '\\[  \\]', 'display math (org snippet)' },
        },
      },
      {
        title = 'Fractions / scripts / roots',
        rows = {
          { '//', '\\frac{}{}', 'fraction' },
          { '^^', '^{}', 'superscript' },
          { '__', '_{}', 'subscript' },
          { 'sq', '\\sqrt{}', 'square root' },
          { 'nrt', '\\sqrt[]{}', 'nth root' },
          { 'x1', 'x_{1}', 'auto-subscript letter+digit' },
        },
      },
      {
        title = 'Big operators',
        rows = {
          { 'sum', '\\sum_{}^{}', 'summation' },
          { 'prod', '\\prod_{}^{}', 'product' },
          { 'int', '\\int_{}^{} \\, d', 'integral' },
          { 'lim', '\\lim_{ \\to }', 'limit' },
          { 'nsum', '\\sum_{i=1}^{n}', 'sum i=1..n' },
          { 'nprod', '\\prod_{i=1}^{n}', 'product i=1..n' },
        },
      },
      {
        title = 'Derivatives',
        rows = {
          { 'dd', '\\frac{d}{dx}', 'derivative' },
          { 'part', '\\frac{\\partial}{\\partial x}', 'partial derivative (fraction)' },
          { 'pd', '\\partial', 'bare partial' },
          { 'grad', '\\nabla', 'gradient / nabla' },
        },
      },
      {
        title = 'Accents / wrappers',
        rows = {
          { 'bar', '\\bar{}', 'bar accent' },
          { 'hat', '\\hat{}', 'hat accent' },
          { 'vec', '\\vec{}', 'vector arrow' },
          { 'tt', '\\text{}', 'upright text in math' },
          { 'text', '\\text{}', 'upright text in math (alias of tt)' },
        },
      },
      {
        title = 'Greek (prefix ;)',
        rows = {
          { ';a ;b ;g', '\\alpha \\beta \\gamma', 'lowercase greek' },
          { ';th ;l ;m', '\\theta \\lambda \\mu', 'more greek' },
          { ';p ;s ;o', '\\pi \\sigma \\omega', 'more greek' },
          { ';G ;D ;S', '\\Gamma \\Delta \\Sigma', 'capital greek' },
        },
      },
    },
  },
  {
    name = 'Snippets',
    sections = {
      {
        title = 'Note scaffold (org)',
        kind = 'snip',
        rows = {
          { 'title', '#+TITLE: ⟨note title⟩', 'new-note header (title/author/date/macros)' },
          { 'src', '#+begin_src ⟨lang⟩ ⟨code⟩ #+end_src', 'code block (pick language)' },
          { 'nsrc', '#+NAME: ⟨name⟩ #+begin_src ⟨lang⟩ ⟨code⟩ #+end_src', 'named source block' },
          { 'ex', '#+begin_example ⟨text⟩ #+end_example', 'example block' },
          { 'quote', '#+begin_quote ⟨text⟩ #+end_quote', 'quote block' },
        },
      },
      {
        title = 'Structure (org)',
        kind = 'snip',
        rows = {
          { 'h1 h2 h3', '* / ** / ***', 'headings' },
          { 'link', '[[⟨target⟩][⟨link text⟩]]', 'hyperlink' },
          { 'img', '[[file:⟨path⟩][⟨caption⟩]]', 'file / image link' },
          { 'tbl', '| ⟨header⟩ | ⟨header⟩ |', 'starter table (TAB realigns)' },
          { 'date', '(today)', 'insert today’s date' },
        },
      },
    },
  },
  {
    name = 'Graphs',
    sections = {
      {
        title = 'TikZ graphs (org/tex — type trigger, expand with <C-n>)',
        kind = 'snip',
        rows = {
          { 'graph', '\\begin{tikzpicture} ⟨nodes & edges⟩ \\end{tikzpicture}', 'blank auto-laid-out graph scaffold' },
          { 'gex', '\\begin{tikzpicture} ⟨3 nodes, weighted arrows⟩ \\end{tikzpicture}', 'ready-made example graph (renders as-is)' },
          { 'gnode', '⟨id⟩ [as={⟨name⟩ \\\\ ⟨value⟩}]', 'node: name / value stacked in a circle' },
          { 'gedge', '⟨from⟩ -- ⟨to⟩;', 'edge (cycle -- / -> / <-> with <C-n>)' },
          { 'gwedge', '⟨from⟩ --["⟨weight⟩"] ⟨to⟩;', 'weighted / labelled edge' },
        },
      },
    },
  },
  {
    name = 'Letters',
    sections = {
      {
        title = 'Greek — lowercase (prefix ;)',
        rows = {
          { ';a', '\\alpha', 'α  alpha' },
          { ';b', '\\beta', 'β  beta' },
          { ';g', '\\gamma', 'γ  gamma' },
          { ';d', '\\delta', 'δ  delta' },
          { ';e', '\\epsilon', 'ε  epsilon' },
          { ';z', '\\zeta', 'ζ  zeta' },
          { ';h', '\\eta', 'η  eta' },
          { ';th', '\\theta', 'θ  theta' },
          { ';k', '\\kappa', 'κ  kappa' },
          { ';l', '\\lambda', 'λ  lambda' },
          { ';m', '\\mu', 'μ  mu' },
          { ';n', '\\nu', 'ν  nu' },
          { ';x', '\\xi', 'ξ  xi' },
          { ';p', '\\pi', 'π  pi' },
          { ';r', '\\rho', 'ρ  rho' },
          { ';s', '\\sigma', 'σ  sigma' },
          { ';ta', '\\tau', 'τ  tau' },
          { ';ph', '\\phi', 'φ  phi' },
          { ';ch', '\\chi', 'χ  chi' },
          { ';ps', '\\psi', 'ψ  psi' },
          { ';o', '\\omega', 'ω  omega' },
          { '--', '\\iota', 'ι  iota' },
          { '--', '\\upsilon', 'υ  upsilon' },
        },
      },
      {
        title = 'Greek — uppercase (prefix ;)',
        rows = {
          { ';G', '\\Gamma', 'Γ  Gamma' },
          { ';D', '\\Delta', 'Δ  Delta' },
          { ';Th', '\\Theta', 'Θ  Theta' },
          { ';L', '\\Lambda', 'Λ  Lambda' },
          { ';X', '\\Xi', 'Ξ  Xi' },
          { ';P', '\\Pi', 'Π  Pi' },
          { ';S', '\\Sigma', 'Σ  Sigma' },
          { ';Ph', '\\Phi', 'Φ  Phi' },
          { ';Ps', '\\Psi', 'Ψ  Psi' },
          { ';O', '\\Omega', 'Ω  Omega' },
          { '--', '\\Upsilon', 'Υ  Upsilon' },
        },
      },
      {
        title = 'Greek — variant forms',
        rows = {
          { '--', '\\varepsilon', 'ε  var epsilon' },
          { '--', '\\vartheta', 'ϑ  var theta' },
          { '--', '\\varphi', 'ϕ  var phi' },
          { '--', '\\varrho', 'ϱ  var rho' },
          { '--', '\\varsigma', 'ς  final sigma' },
          { '--', '\\varpi', 'ϖ  var pi' },
          { '--', '\\varkappa', 'ϰ  var kappa' },
        },
      },
      {
        title = 'Letter styles (type letter inside {})',
        rows = {
          { 'cal', '\\mathcal{}', '𝓛  calligraphic (loss, big-O, data, hyp)' },
          { 'bb', '\\mathbb{}', '𝔼  blackboard (P, indicator 1)' },
          { 'bf', '\\mathbf{}', '𝐱  bold (vectors / matrices)' },
          { 'rm', '\\mathrm{}', 'Var  upright operator' },
          { '--', '\\mathfrak{}', '𝔄  fraktur (sigma-algebras)' },
          { '--', '\\boldsymbol{}', '𝛃  bold greek / symbols' },
          { '--', '\\hat{}', 'x̂  hat / estimator' },
          { '--', '\\tilde{}', 'x̃  tilde' },
          { '--', '\\bar{}', 'x̄  bar / mean' },
        },
      },
      {
        title = 'Blackboard sets',
        rows = {
          { 'RR', '\\mathbb{R}', 'ℝ  reals' },
          { 'ZZ', '\\mathbb{Z}', 'ℤ  integers' },
          { 'NN', '\\mathbb{N}', 'ℕ  naturals' },
          { 'QQ', '\\mathbb{Q}', 'ℚ  rationals' },
          { 'CC', '\\mathbb{C}', 'ℂ  complex' },
        },
      },
      {
        title = 'Symbols & named constants',
        rows = {
          { 'pd', '\\partial', '∂  partial derivative' },
          { 'grad', '\\nabla', '∇  nabla / gradient' },
          { 'inf', '\\infty', '∞  infinity' },
          { '--', '\\ell', 'ℓ  script ell (length)' },
          { '--', '\\hbar', 'ℏ  reduced Planck' },
          { '--', '\\Re', 'ℜ  real part' },
          { '--', '\\Im', 'ℑ  imaginary part' },
          { '--', '\\aleph', 'ℵ  aleph (cardinality)' },
          { '--', '\\wp', '℘  Weierstrass p' },
          { 'empty', '\\emptyset', '∅  empty set' },
          { '--', '\\angle', '∠  angle' },
          { '--', '\\top', '⊤  top / true' },
          { '--', '\\bot', '⊥  bottom / false' },
          { '--', '\\prime', '′  prime' },
          { '--', '\\star', '⋆  star' },
          { '--', '\\dagger', '†  dagger / adjoint' },
          { '--', '\\pm', '±  plus-minus' },
          { '--', '\\mp', '∓  minus-plus' },
          { 'cdot', '\\cdot', '⋅  dot product' },
          { 'xx', '\\times', '×  times / cross' },
          { 'comp', '\\circ', '∘  composition' },
          { 'prop', '\\propto', '∝  proportional' },
        },
      },
      {
        title = 'Dots',
        rows = {
          { '--', '\\ldots', '…  low dots' },
          { '--', '\\cdots', '⋯  centered dots' },
          { '--', '\\vdots', '⋮  vertical dots' },
          { '--', '\\ddots', '⋱  diagonal dots' },
        },
      },
      {
        title = 'Arrows',
        rows = {
          { '->', '\\to', '→  to / maps' },
          { '--', '\\gets', '←  gets' },
          { '--', '\\mapsto', '↦  maps to' },
          { '=>', '\\implies', '⇒  implies' },
          { 'iff', '\\iff', '⇔  if and only if' },
          { '--', '\\uparrow', '↑  up' },
          { '--', '\\downarrow', '↓  down' },
        },
      },
    },
  },
  {
    name = 'Logic/Rel',
    sections = {
      {
        title = 'Relations',
        rows = {
          { '->', '\\to', 'to / maps' },
          { '=>', '\\implies', 'implies' },
          { 'iff', '\\iff', 'if and only if' },
          { ':=', '\\coloneqq', 'defined as (:=)' },
          { 'deq', '\\triangleq', 'defined as (triangle)' },
          { 'prop', '\\propto', 'proportional to' },
          { '~=', '\\approx', 'approximately' },
          { '!=', '\\neq', 'not equal' },
          { '<=', '\\leq', 'less-or-equal' },
          { '>=', '\\geq', 'greater-or-equal' },
          { 'comp', '\\circ', 'composition' },
        },
      },
      {
        title = 'Logic',
        rows = {
          { 'land', '\\land', 'logical and' },
          { 'lor', '\\lor', 'logical or' },
          { 'neg', '\\neg', 'logical not' },
          { 'AA', '\\forall', 'for all' },
          { 'EE', '\\exists', 'there exists' },
        },
      },
      {
        title = 'Sets',
        rows = {
          { 'uu', '\\cup', 'union' },
          { 'nn', '\\cap', 'intersection' },
          { 'bigcup', '\\bigcup_{}^{}', 'indexed union' },
          { 'bigcap', '\\bigcap_{}^{}', 'indexed intersection' },
          { 'smin', '\\setminus', 'set minus' },
          { 'subs', '\\subseteq', 'subset-or-equal' },
          { 'sups', '\\supseteq', 'superset-or-equal' },
          { 'in', '\\in', 'element of' },
          { 'notin', '\\notin', 'not element of' },
          { 'empty', '\\emptyset', 'empty set' },
          { 'set', '\\{  \\}', 'set literal' },
        },
      },
    },
  },
  {
    name = 'Matrix/Vec',
    sections = {
      {
        title = 'Environments',
        rows = {
          { 'bmat', '\\begin{bmatrix} ⟨entries⟩ \\end{bmatrix}', 'matrix (square brackets)' },
          { 'pmat', '\\begin{pmatrix} ⟨entries⟩ \\end{pmatrix}', 'matrix (parens)' },
          { 'cases', '\\begin{cases} ⟨rows⟩ \\end{cases}', 'piecewise cases' },
          { 'ali', '\\begin{align*} ⟨equations⟩ \\end{align*}', 'aligned equations' },
          { 'beg', '\\begin{⟨env⟩} ⟨body⟩ \\end{⟨env⟩}', 'generic environment' },
        },
      },
      {
        title = 'Vectors (NxM: & = next col, \\\\ = new row)',
        rows = {
          { 'cvec', '\\begin{bmatrix} a \\\\ b \\end{bmatrix}', 'column vector template' },
          { 'vec', '\\vec{}', 'vector arrow' },
          { 'bmat', 'a & b \\\\ c & d', 'fill NxM: & cols, \\\\ rows' },
        },
      },
      {
        title = 'Norms / brackets',
        rows = {
          { 'vnorm', '\\lVert  \\rVert', 'vector norm' },
          { 'abs', '\\lvert  \\rvert', 'absolute value' },
          { 'floor', '\\lfloor  \\rfloor', 'floor' },
          { 'ceil', '\\lceil  \\rceil', 'ceiling' },
        },
      },
    },
  },
  {
    name = 'Stats',
    sections = {
      {
        title = 'Moments / estimators',
        rows = {
          { 'Ev', '\\mathbb{E}\\left[  \\right]', 'expectation' },
          { 'Var', '\\mathrm{Var}\\left(  \\right)', 'variance' },
          { 'Cov', '\\mathrm{Cov}\\left( ,  \\right)', 'covariance' },
          { 'Cor', '\\mathrm{Corr}\\left( ,  \\right)', 'correlation' },
        },
      },
      {
        title = 'Probability',
        rows = {
          { 'Pr', 'P\\left(  \\right)', 'probability' },
          { 'cond', 'P\\left(  \\mid  \\right)', 'conditional probability' },
          { 'Ind', '\\mathbb{1}_{} = \\begin{cases} 1 & \\\\ 0 & \\text{otherwise} \\end{cases}', 'indicator (piecewise 1/0)' },
          { 'sim', '\\sim', 'distributed as' },
          { 'iid', '\\overset{iid}{\\sim}', 'iid' },
          { 'perp', '\\perp', 'independent' },
        },
      },
      {
        title = 'Distributions',
        rows = {
          { 'norm', '\\mathcal{N}( , )', 'Normal' },
          { 'Pois', '\\mathrm{Poisson}()', 'Poisson' },
          { 'Bin', '\\mathrm{Binomial}( , )', 'Binomial' },
          { 'Unif', '\\mathrm{Uniform}( , )', 'Uniform' },
          { 'Bern', '\\mathrm{Bernoulli}()', 'Bernoulli' },
          { 'Expo', '\\mathrm{Exponential}()', 'Exponential' },
        },
      },
      {
        title = 'Optimisation / convergence',
        rows = {
          { 'argmax', '\\underset{}{\\arg\\max}', 'argmax' },
          { 'argmin', '\\underset{}{\\arg\\min}', 'argmin' },
          { 'convp', '\\xrightarrow{p}', 'converges in probability' },
          { 'convd', '\\xrightarrow{d}', 'converges in distribution' },
          { 'binom', '\\binom{}{}', 'binomial coefficient' },
        },
      },
    },
  },
}

-- ---------------------------------------------------------------------------
-- Highlight groups
-- ---------------------------------------------------------------------------
local function define_hl()
  api.nvim_set_hl(0, 'HelpPopupTitle', { link = 'Title', default = true })
  api.nvim_set_hl(0, 'HelpPopupTabActive', { fg = '#1a1b26', bg = '#7aa2f7', bold = true, default = true })
  api.nvim_set_hl(0, 'HelpPopupTabInactive', { fg = '#565f89', default = true })
  api.nvim_set_hl(0, 'HelpPopupSection', { fg = '#bb9af7', bold = true, default = true })
  api.nvim_set_hl(0, 'HelpPopupTrig', { fg = '#9ece6a', bold = true, default = true })
  api.nvim_set_hl(0, 'HelpPopupOut', { fg = '#e0af68', default = true })
  api.nvim_set_hl(0, 'HelpPopupDesc', { fg = '#a9b1d6', default = true })
  api.nvim_set_hl(0, 'HelpPopupHint', { fg = '#565f89', italic = true, default = true })
end
define_hl()
api.nvim_create_autocmd('ColorScheme', { callback = define_hl })

local ns = api.nvim_create_namespace('help_popup')

-- Popup state (single instance).
local state = {
  buf = nil,
  win = nil,
  tab = 1,
  origin_win = nil,
  -- line -> row data, for cursor-based insert; also flat list for Telescope.
  line_row = {},
}

-- Flatten every row across tabs (for Telescope search).
local function all_rows()
  local out = {}
  for _, tab in ipairs(tabs) do
    for _, sec in ipairs(tab.sections) do
      for _, r in ipairs(sec.rows) do
        out[#out + 1] = {
          tab = tab.name,
          section = sec.title,
          trig = r[1],
          out = r[2],
          desc = r[3],
        }
      end
    end
  end
  return out
end

-- Insert a row's LaTeX at the origin window's cursor, in insert mode. Places the
-- cursor inside the first empty {} or () if present.
local function insert_output(latex)
  if not latex or latex == '' then
    return
  end
  local win = state.origin_win
  if not win or not api.nvim_win_is_valid(win) then
    return
  end
  api.nvim_set_current_win(win)
  local row, col = unpack(api.nvim_win_get_cursor(win))
  local line = api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''
  local before, after = line:sub(1, col), line:sub(col + 1)
  local new = before .. latex .. after
  api.nvim_buf_set_lines(0, row - 1, row, false, { new })
  -- Prefer landing the cursor inside the first empty {} or ().
  local rel = latex:find('{}', 1, true) or latex:find('()', 1, true)
  local target = col + (rel and rel or #latex)
  api.nvim_win_set_cursor(0, { row, target })
  api.nvim_feedkeys(api.nvim_replace_termcodes('<Esc>a', true, false, true), 'n', false)
end

-- For `kind='snip'` rows, fire the *actual* LuaSnip snippet (with its tab-stops)
-- at the origin window's cursor, instead of pasting the preview text. The trigger
-- is looked up across the origin buffer's filetypes -- so an org buffer also sees
-- the shared `tex` snippets (filetype_extend) and any friendly-snippets/snipmate
-- collections. `snip_expand` inserts the body at the cursor directly (no typed
-- trigger, so no cursor-clamping games) and jumps into the first field. Returns
-- true if a matching snippet was expanded.
local function expand_snippet(trig)
  local win = state.origin_win
  if not win or not api.nvim_win_is_valid(win) then
    return false
  end
  local ok, ls = pcall(require, 'luasnip')
  if not ok then
    return false
  end
  api.nvim_set_current_win(win)
  -- A row may display several triggers (e.g. 'h1 h2 h3'); use the first.
  local want = trig:match('^%S+') or trig
  for _, ft in ipairs(ls.get_snippet_filetypes()) do
    for _, kind in ipairs { 'snippets', 'autosnippets' } do
      for _, snip in ipairs(ls.get_snippets(ft, { type = kind })) do
        if snip.trigger == want then
          ls.snip_expand(snip)
          return true
        end
      end
    end
  end
  return false
end

-- ---------------------------------------------------------------------------
-- Rendering
-- ---------------------------------------------------------------------------
local function close()
  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

local function render()
  local buf = state.buf
  if not buf or not api.nvim_buf_is_valid(buf) then
    return
  end
  local width = api.nvim_win_get_width(state.win)

  local lines = {}
  local hls = {} -- { line0, col0, col1, group }
  state.line_row = {}

  -- Tab bar.
  local bar_parts = {}
  local col = 0
  local bar_spans = {}
  for idx, tab in ipairs(tabs) do
    local label = string.format(' %d:%s ', idx, tab.name)
    bar_parts[#bar_parts + 1] = label
    bar_spans[#bar_spans + 1] = { col, col + #label, idx == state.tab }
    col = col + #label
  end
  lines[1] = table.concat(bar_parts)
  for _, sp in ipairs(bar_spans) do
    hls[#hls + 1] = { 0, sp[1], sp[2], sp[3] and 'HelpPopupTabActive' or 'HelpPopupTabInactive' }
  end
  lines[2] = string.rep('─', width)

  -- Active tab content. Column layout: [indent][trigger][gap][output][gap][· desc].
  -- Trigger and output columns are padded to the widest entry in THIS tab so
  -- everything lines up. trig/out are ASCII (byte width == display width); the
  -- description is last and leads with the glyph, so its multibyte width never
  -- shifts the aligned columns.
  local INDENT, GAP = 4, 2
  local tab = tabs[state.tab]
  local trig_w, out_w = 0, 0
  for _, sec in ipairs(tab.sections) do
    for _, r in ipairs(sec.rows) do
      trig_w = math.max(trig_w, #r[1])
      out_w = math.max(out_w, #r[2])
    end
  end
  out_w = math.min(out_w, 42)

  for _, sec in ipairs(tab.sections) do
    lines[#lines + 1] = ''
    local ln = #lines - 1
    local title = '  ' .. sec.title
    lines[#lines] = title
    hls[#hls + 1] = { ln, 0, #title, 'HelpPopupSection' }
    for _, r in ipairs(sec.rows) do
      local trig, out, desc = r[1], r[2], r[3]
      local start_trig = INDENT
      local pad1 = string.rep(' ', trig_w - #trig + GAP)
      local start_out = start_trig + #trig + #pad1
      local pad2 = string.rep(' ', math.max(GAP, out_w - #out + GAP))
      local start_desc = start_out + #out + #pad2
      local full = string.rep(' ', INDENT) .. trig .. pad1 .. out .. pad2 .. '· ' .. desc
      lines[#lines + 1] = full
      local l0 = #lines - 1
      hls[#hls + 1] = { l0, start_trig, start_trig + #trig, 'HelpPopupTrig' }
      if out ~= '' then
        hls[#hls + 1] = { l0, start_out, start_out + #out, 'HelpPopupOut' }
      end
      hls[#hls + 1] = { l0, start_desc, #full, 'HelpPopupDesc' }
      state.line_row[l0 + 1] = { trig = trig, out = out, desc = desc, kind = sec.kind or 'auto' }
    end
  end

  lines[#lines + 1] = ''
  local hint = '  [1-9]/h l  tabs   ·   /  search   ·   <C-f>  fuzzy   ·   <CR>  insert/expand   ·   q  close'
  lines[#lines + 1] = hint
  local hint_ln = #lines - 1

  api.nvim_set_option_value('modifiable', true, { buf = buf })
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_set_option_value('modifiable', false, { buf = buf })

  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, h in ipairs(hls) do
    api.nvim_buf_set_extmark(buf, ns, h[1], h[2], { end_col = h[3], hl_group = h[4] })
  end
  api.nvim_buf_set_extmark(buf, ns, hint_ln, 0, { end_col = #hint, hl_group = 'HelpPopupHint' })
end

local function set_tab(idx)
  if idx < 1 then
    idx = #tabs
  elseif idx > #tabs then
    idx = 1
  end
  state.tab = idx
  render()
  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_set_cursor(state.win, { 3, 0 })
  end
end

-- Telescope fuzzy search over every row; <CR> inserts the LaTeX.
local function telescope_search()
  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    vim.notify('telescope not available', vim.log.levels.WARN)
    return
  end
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local rows = all_rows()
  close()
  pickers
    .new({}, {
      prompt_title = 'Symbols / snippets',
      finder = finders.new_table {
        results = rows,
        entry_maker = function(e)
          local display = string.format('%-11s %-28s %s  (%s · %s)', e.trig, e.out, e.desc, e.tab, e.section)
          return {
            value = e,
            display = display,
            ordinal = e.trig .. ' ' .. e.out .. ' ' .. e.desc .. ' ' .. e.tab .. ' ' .. e.section,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry and entry.value then
            insert_output(entry.value.out)
          end
        end)
        return true
      end,
    })
    :find()
end

local function open()
  if state.win and api.nvim_win_is_valid(state.win) then
    close()
    return
  end
  state.origin_win = api.nvim_get_current_win()

  local total_w = api.nvim_get_option_value('columns', {})
  local total_h = api.nvim_get_option_value('lines', {})
  local width = math.min(100, total_w - 6)
  local height = math.min(40, total_h - 6)

  local buf = api.nvim_create_buf(false, true)
  state.buf = buf
  api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  api.nvim_set_option_value('filetype', 'helppopup', { buf = buf })

  state.win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((total_h - height) / 2 - 1),
    col = math.floor((total_w - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Help — snippets & symbols ',
    title_pos = 'center',
  })
  api.nvim_set_option_value('cursorline', true, { win = state.win })
  api.nvim_set_option_value('wrap', false, { win = state.win })

  local function map(lhs, fn)
    vim.keymap.set('n', lhs, fn, { buffer = buf, nowait = true, silent = true })
  end
  map('q', close)
  map('<Esc>', close)
  map('l', function() set_tab(state.tab + 1) end)
  map('<Tab>', function() set_tab(state.tab + 1) end)
  map('h', function() set_tab(state.tab - 1) end)
  map('<S-Tab>', function() set_tab(state.tab - 1) end)
  for i = 1, math.min(9, #tabs) do
    map(tostring(i), function() set_tab(i) end)
  end
  map('<C-f>', telescope_search)
  map('<CR>', function()
    local lnum = api.nvim_win_get_cursor(state.win)[1]
    local row = state.line_row[lnum]
    close()
    if not row then
      return
    end
    -- Snippet rows fire the real snippet (fields and all); symbol rows insert
    -- their LaTeX literally. If no matching snippet is found, fall back to the
    -- literal insert so the row still does something.
    if row.kind == 'snip' and expand_snippet(row.trig) then
      return
    end
    insert_output(row.out)
  end)

  set_tab(state.tab)
end

vim.keymap.set('n', '<Space>?', open, { silent = true, desc = 'Help: snippets & symbols popup' })

local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add { { '<Space>?', open, desc = 'Help popup', icon = { icon = '', color = 'purple' } } }
end

-- Exposed for headless testing.
_G.HelpPopup = {
  open = open,
  close = close,
  set_tab = set_tab,
  all_rows = all_rows,
  insert_output = insert_output,
  state = state,
  tabs = tabs,
}
