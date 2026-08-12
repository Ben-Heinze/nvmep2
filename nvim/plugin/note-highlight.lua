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
  red = { hl = 'NoteHiRed', fg = '#FF0000' },
  orange = { hl = 'NoteHiOrange', fg = '#FF7F00' },
  yellow = { hl = 'NoteHiYellow', fg = '#FFFF00' },
  green = { hl = 'NoteHiGreen', fg = '#00FF00' },
  cyan = { hl = 'NoteHiCyan', fg = '#00FFFF' },
  blue = { hl = 'NoteHiBlue', fg = '#0000FF' },
  purple = { hl = 'NoteHiPurple', fg = '#8B00FF' },
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
-- the surrounding macro boilerplate. A macro may span multiple lines: `gq`/
-- reflow can put a newline inside the highlighted phrase (never in the opener
-- `{{{hl(name,` or closer `)}}}`, which contain no spaces), and org export
-- collapses that newline to a space, so it stays valid. The extmark colouring
-- the inner text spans lines too.
local function render(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local n = #lines
  local row, col = 0, 1 -- col is a 1-indexed search offset into lines[row + 1]
  while row < n do
    local line = lines[row + 1]
    if col > #line then
      row, col = row + 1, 1
    else
      -- `(` `)` are Lua-pattern captures, so escape the literal `(`; braces are
      -- literal. Captures the colour name; `os_`..`oe` is the opener span.
      local os_, oe, name = line:find('{{{hl%((%w+),', col)
      if not os_ then
        row, col = row + 1, 1
      elseif not colors[name] then
        col = oe + 1
      else
        -- Find the closer `)}}}`, searching this line then following ones.
        local crow, cstart, cend
        local sr, sc = row, oe + 1
        while sr < n do
          local hit = lines[sr + 1]:find(')}}}', sc, true)
          if hit then
            crow, cstart, cend = sr, hit, hit + 3
            break
          end
          sr, sc = sr + 1, 1
        end
        if not crow then
          row = n -- unterminated macro; stop
        else
          -- crow/cstart/cend are set together; cast so the checker treats them
          -- as non-nil integers.
          local er = crow --[[@as integer]]
          local cs = cstart --[[@as integer]]
          local ce = cend --[[@as integer]]
          -- Inner text: from just after the opener to just before the closer
          -- (may cross lines). `oe` (1-indexed last opener byte) == 0-indexed
          -- start of the inner text.
          api.nvim_buf_set_extmark(bufnr, ns, row, oe, {
            end_row = er,
            end_col = cs - 1,
            hl_group = colors[name].hl,
            priority = 200, -- above treesitter's default 100
          })
          api.nvim_buf_set_extmark(bufnr, ns, row, os_ - 1, {
            end_row = row,
            end_col = oe,
            conceal = '',
          })
          api.nvim_buf_set_extmark(bufnr, ns, er, cs - 1, {
            end_row = er,
            end_col = ce,
            conceal = '',
          })
          row, col = er, ce + 1
        end
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

-- Split a raw string into a list of visible characters, each tagged with its
-- current colour and its 1-indexed byte span in the buffer line. `is_inner`
-- means the raw text came from inside a macro, where `\,` is an escaped comma
-- (one visible char spanning two bytes).
local function push_chars(list, raw, base, color, is_inner)
  local i = 1
  while i <= #raw do
    local b = raw:byte(i)
    if is_inner and b == 92 and raw:byte(i + 1) == 44 then -- `\` then `,`
      list[#list + 1] = { ch = ',', bs = base + i - 1, be = base + i, color = color }
      i = i + 2
    else
      local len = 1
      if b >= 0xF0 then
        len = 4
      elseif b >= 0xE0 then
        len = 3
      elseif b >= 0xC0 then
        len = 2
      end
      list[#list + 1] =
        { ch = raw:sub(i, i + len - 1), bs = base + i - 1, be = base + i + len - 2, color = color }
      i = i + len
    end
  end
end

-- Parse a line into per-character colour info (see push_chars).
local function parse_line(line)
  local list = {}
  local i = 1
  while i <= #line do
    local s, e, name, text = line:find('{{{hl%((%w+),(.-)%)}}}', i)
    if s and colors[name] then
      if s > i then
        push_chars(list, line:sub(i, s - 1), i, nil, false)
      end
      local inner_base = s + #('{{{hl(' .. name .. ',')
      push_chars(list, text, inner_base, name, true)
      i = e + 1
    else
      if i <= #line then
        push_chars(list, line:sub(i), i, nil, false)
      end
      break
    end
  end
  return list
end

-- Rebuild a line from per-character colour info, merging adjacent same-colour
-- runs into one macro (or plain text). Never nests.
local function serialize(list)
  local out = {}
  local i, n = 1, #list
  while i <= n do
    local col = list[i].color
    local buf = {}
    while i <= n and list[i].color == col do
      buf[#buf + 1] = list[i].ch
      i = i + 1
    end
    local str = table.concat(buf)
    if col == nil then
      out[#out + 1] = str
    else
      out[#out + 1] = '{{{hl(' .. col .. ',' .. str:gsub(',', '\\,') .. ')}}}'
    end
  end
  return table.concat(out)
end

-- Apply `newcolor` to the byte range [scol .. end_excl) (0-indexed) of one line,
-- re-splitting any existing highlight the selection overlaps rather than nesting.
local function recolor_line(line, scol, end_excl, newcolor)
  local list = parse_line(line)
  for _, item in ipairs(list) do
    if item.bs >= scol + 1 and item.be <= end_excl then
      item.color = newcolor
    end
  end
  return serialize(list)
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

  if srow == erow then
    -- Single line: parse/recolor/reserialize so a highlight inside an existing
    -- one splits it instead of producing (broken) nested macros.
    local line = api.nvim_buf_get_lines(bufnr, srow, srow + 1, true)[1]
    api.nvim_buf_set_lines(bufnr, srow, srow + 1, true, { recolor_line(line, scol, end_excl, name) })
  else
    -- Multiline selection: plain wrap (inline highlights are single-line; this
    -- path is rare and not re-split).
    local text = table.concat(api.nvim_buf_get_text(bufnr, srow, scol, erow, end_excl, {}), '\n')
    local escaped = text:gsub(',', '\\,')
    local wrapped = '{{{hl(' .. name .. ',' .. escaped .. ')}}}'
    api.nvim_buf_set_text(bufnr, srow, scol, erow, end_excl, vim.split(wrapped, '\n'))
  end
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
