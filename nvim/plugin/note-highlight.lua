if vim.g.did_load_note_highlight_plugin then
  return
end
vim.g.did_load_note_highlight_plugin = true

-- Rainbow text highlighting for org notes.
--
-- A visual selection is wrapped in an org macro call `{{{hl(<color>,text)}}}`
-- (see the `hl` macro seeded by the `title` snippet in
-- `lua/user/snippets_org.lua`). That macro exports, via Emacs `org-publish`, to
-- `<span class="hl-<color>">text</span>` -- coloured on the website by the
-- `.hl-<color>` rules in `~/projects/yappopotamus/static/style.css`.
--
-- On screen the macro boilerplate is concealed and the inner text is coloured
-- with extmarks (org buffers are highlighted by treesitter, which overrides
-- plain `:syntax`; a high extmark priority renders on top). Everything here is
-- scoped to org buffers only.

local api = vim.api
local fn = vim.fn

-- Palette. `fg` mirrors the `.hl-<name>` classes in yappopotamus/static/style.css
-- so the editor is WYSIWYG with the exported site -- keep the two in sync.
local colors = {
  red = { hl = 'NoteHiRed', fg = '#f7768e' },
  orange = { hl = 'NoteHiOrange', fg = '#ff9e64' },
  yellow = { hl = 'NoteHiYellow', fg = '#e0af68' },
  green = { hl = 'NoteHiGreen', fg = '#9ece6a' },
  cyan = { hl = 'NoteHiCyan', fg = '#7dcfff' },
  blue = { hl = 'NoteHiBlue', fg = '#7aa2f7' },
  purple = { hl = 'NoteHiPurple', fg = '#bb9af7' },
}

-- Which <Space>n<key> inserts which colour.
local keys = {
  red = 'r',
  orange = 'o',
  yellow = 'y',
  green = 'g',
  cyan = 'c',
  blue = 'b',
  purple = 'p',
}

local ns = api.nvim_create_namespace('note_highlight')

local function define_highlights()
  for _, spec in pairs(colors) do
    api.nvim_set_hl(0, spec.hl, { fg = spec.fg, bold = true })
  end
end

define_highlights()

-- Repaint every `{{{hl(...)}}}` in the buffer: colour the inner text, conceal
-- the surrounding macro boilerplate.
local function render(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for lnum, line in ipairs(lines) do
    local row = lnum - 1
    local from = 1
    while true do
      -- `{ } ( )` in Lua patterns: `(` `)` are captures, so escape the literal
      -- parens with `%`; the braces are literal.
      local s, e, name, text = line:find('{{{hl%((%w+),(.-)%)}}}', from)
      if not s then
        break
      end
      from = e + 1
      local spec = colors[name]
      if spec then
        local prefix = '{{{hl(' .. name .. ','
        local text_start = (s - 1) + #prefix -- 0-indexed byte col of inner text
        local text_end = text_start + #text -- exclusive; also start of `)}}}`
        api.nvim_buf_set_extmark(bufnr, ns, row, text_start, {
          end_row = row,
          end_col = text_end,
          hl_group = spec.hl,
          priority = 200, -- above treesitter's default 100
        })
        api.nvim_buf_set_extmark(bufnr, ns, row, s - 1, {
          end_row = row,
          end_col = text_start,
          conceal = '',
        })
        api.nvim_buf_set_extmark(bufnr, ns, row, text_end, {
          end_row = row,
          end_col = e,
          conceal = '',
        })
      end
    end
  end
end

-- Move '< and '> to reflect the current selection (they are only set on leaving
-- visual mode; which-key usually exits first, but Esc here makes it robust).
local function ensure_marks()
  if fn.mode():match('[vV\22]') then
    vim.cmd('normal! \27')
  end
end

local function wrap_selection(name)
  local bufnr = api.nvim_get_current_buf()
  ensure_marks()

  local s = fn.getpos("'<")
  local e = fn.getpos("'>")
  local srow, scol = s[2] - 1, s[3] - 1
  local erow = e[2] - 1
  local eline = api.nvim_buf_get_lines(bufnr, erow, erow + 1, true)[1] or ''

  -- Exclusive end byte col: '> is the first byte of the (inclusive) last char,
  -- so advance past that whole (possibly multibyte) char. Clamp for linewise /
  -- past-end-of-line selections where '> col is v:maxcol.
  local end_excl
  if #eline == 0 then
    end_excl = 0
  else
    local ecol = math.min(e[3], #eline)
    local last_char = fn.strpart(eline, ecol - 1, 1, 1)
    end_excl = (ecol - 1) + #last_char
  end

  local text = table.concat(api.nvim_buf_get_text(bufnr, srow, scol, erow, end_excl, {}), '\n')
  -- Org macro args split on commas -> escape any in the selection.
  local escaped = text:gsub(',', '\\,')
  local wrapped = '{{{hl(' .. name .. ',' .. escaped .. ')}}}'
  api.nvim_buf_set_text(bufnr, srow, scol, erow, end_excl, vim.split(wrapped, '\n'))
  render(bufnr)
end

-- Strip the macro wrapper on the selected lines, keeping the inner text.
local function clear_selection()
  local bufnr = api.nvim_get_current_buf()
  ensure_marks()

  local srow = fn.getpos("'<")[2]
  local erow = fn.getpos("'>")[2]
  for lnum = srow, erow do
    local line = fn.getline(lnum)
    local new = line:gsub('{{{hl%(%w+,(.-)%)}}}', function(inner)
      return (inner:gsub('\\,', ','))
    end)
    if new ~= line then
      fn.setline(lnum, new)
    end
  end
  render(bufnr)
end

local group = api.nvim_create_augroup('note_highlight', { clear = true })

local function setup_buffer(bufnr)
  if vim.b[bufnr].note_highlight_setup then
    return
  end
  vim.b[bufnr].note_highlight_setup = true

  for name, key in pairs(keys) do
    vim.keymap.set('x', '<Space>n' .. key, function()
      wrap_selection(name)
    end, { buffer = bufnr, silent = true, desc = 'highlight ' .. name })
  end
  vim.keymap.set(
    'x',
    '<Space>nx',
    clear_selection,
    { buffer = bufnr, silent = true, desc = 'clear highlight' }
  )

  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add {
      { '<Space>n', group = 'Notes', buffer = bufnr, icon = { icon = '', color = 'purple' } },
    }
  end

  local rerender = function()
    render(bufnr)
  end
  api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
    group = group,
    buffer = bufnr,
    callback = rerender,
  })
  local timer
  api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      if timer then
        timer:stop()
      end
      timer = vim.defer_fn(rerender, 150)
    end,
  })
end

api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'org',
  callback = function(ev)
    setup_buffer(ev.buf)
    render(ev.buf)
  end,
})

api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = define_highlights,
})

-- Catch org buffers already loaded when this file is sourced.
for _, buf in ipairs(api.nvim_list_bufs()) do
  if api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'org' then
    setup_buffer(buf)
    render(buf)
  end
end
