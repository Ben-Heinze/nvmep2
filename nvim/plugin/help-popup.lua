-- Tabbed "help" popup (Awesome-WM hotkeys style) for the note-writing setup.
-- Openable anywhere with <Space>? : a floating window with major tabs (Neovim,
-- LaTeX, Snippets, Glyphs, Logic/Relations, Matrices/Vectors, Statistics), each
-- split into subsections. Search with `/` (native, current tab) or Telescope
-- (<C-f>, fuzzy over every symbol). Selecting a row inserts its LaTeX at the
-- cursor of the window you opened from.
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
--   'auto' math autosnippet (fires in a math zone), 'snip' org snippet
--   (expand with <C-n>), 'key' a keybinding. Defaults to 'auto'.
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
          { 'title', '#+TITLE: …', 'new-note header (title/author/date/macros)' },
          { 'src', '#+begin_src', 'code block (pick language)' },
          { 'nsrc', '#+NAME: … #+begin_src', 'named source block' },
          { 'ex', '#+begin_example', 'example block' },
          { 'quote', '#+begin_quote', 'quote block' },
        },
      },
      {
        title = 'Structure (org)',
        kind = 'snip',
        rows = {
          { 'h1 h2 h3', '* / ** / ***', 'headings' },
          { 'link', '[[target][desc]]', 'hyperlink' },
          { 'img', '[[file:…][caption]]', 'file / image link' },
          { 'tbl', '| h | h | …', 'starter table (TAB realigns)' },
          { 'date', '(today)', 'insert today’s date' },
        },
      },
      {
        title = 'Cheatsheets (org)',
        kind = 'snip',
        rows = {
          { 'cheat', 'help table', 'paste getting-started table' },
          { 'symbols', 'symbol table', 'paste CS/stats symbol table' },
        },
      },
    },
  },
  {
    name = 'Glyphs',
    sections = {
      {
        title = 'Font wrappers (type letter inside)',
        rows = {
          { 'cal', '\\mathcal{}', 'calligraphic: loss L, big-O O, data D, hyp H' },
          { 'bf', '\\mathbf{}', 'bold vectors / matrices' },
          { 'rm', '\\mathrm{}', 'upright operator' },
          { 'bb', '\\mathbb{}', 'blackboard: \\mathbb{P}, indicator \\mathbb{1}' },
        },
      },
      {
        title = 'Blackboard sets',
        rows = {
          { 'RR', '\\mathbb{R}', 'reals' },
          { 'ZZ', '\\mathbb{Z}', 'integers' },
          { 'NN', '\\mathbb{N}', 'naturals' },
          { 'QQ', '\\mathbb{Q}', 'rationals' },
          { 'CC', '\\mathbb{C}', 'complex' },
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
          { 'bmat', '\\begin{bmatrix} \\end{bmatrix}', 'matrix (square brackets)' },
          { 'pmat', '\\begin{pmatrix} \\end{pmatrix}', 'matrix (parens)' },
          { 'cases', '\\begin{cases} \\end{cases}', 'piecewise cases' },
          { 'ali', '\\begin{align*} \\end{align*}', 'aligned equations' },
          { 'beg', '\\begin{} \\end{}', 'generic environment' },
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

  -- Active tab content.
  local tab = tabs[state.tab]
  local trig_w = 12
  for _, sec in ipairs(tab.sections) do
    lines[#lines + 1] = ''
    local ln = #lines - 1
    local title = '  ' .. sec.title
    lines[#lines] = title
    hls[#hls + 1] = { ln, 0, #title, 'HelpPopupSection' }
    for _, r in ipairs(sec.rows) do
      local trig, out, desc = r[1], r[2], r[3]
      local pad = string.rep(' ', math.max(1, trig_w - #trig))
      local text = string.format('    %s%s%s', trig, pad, out)
      local outstart = 4 + #trig + #pad
      -- Keep the description on the same line, spaced out.
      local gap = string.rep(' ', 2)
      local full = text .. gap .. '· ' .. desc
      lines[#lines + 1] = full
      local l0 = #lines - 1
      hls[#hls + 1] = { l0, 4, 4 + #trig, 'HelpPopupTrig' }
      if out ~= '' then
        hls[#hls + 1] = { l0, outstart, outstart + #out, 'HelpPopupOut' }
      end
      hls[#hls + 1] = { l0, #text + #gap, #full, 'HelpPopupDesc' }
      state.line_row[l0 + 1] = { trig = trig, out = out, desc = desc }
    end
  end

  lines[#lines + 1] = ''
  local hint = '  [1-9]/h l  tabs   ·   /  search   ·   <C-f>  fuzzy   ·   <CR>  insert   ·   q  close'
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
  local width = math.min(92, total_w - 8)
  local height = math.min(34, total_h - 6)

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
    if row then
      insert_output(row.out)
    end
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
