if vim.g.did_load_math_balance_plugin then
  return
end
vim.g.did_load_math_balance_plugin = true

-- Delimiter-balance linter for math note buffers (org + tex).
--
-- Scans the whole buffer and reports UNMATCHED or MISMATCHED math delimiters as
-- `vim.diagnostic` warnings: `$`, `$$`, `\(`/`\)`, `\[`/`\]`, and math environments
-- (`\begin{align}…\end{align}` etc.). These bugs are otherwise invisible while
-- editing -- the in-editor snacks preview and the autosnippet `in_mathzone()`
-- scanner both self-heal at paragraph boundaries, so a stray `$` silently breaks
-- only the PDF/HTML export. This surfaces them at the offending delimiter; navigate
-- with the existing `[d`/`]d`, and they show in the statusline diagnostic counts.
--
-- Deliberately NOT checked: parenthesis balance inside math. `\left(`/`\right)`,
-- intervals like `(0,1]`, and multi-line groupings make that far too noisy.
--
-- Modelled on plugin/org-src-block-bg.lua (guard -> namespace -> whole-buffer
-- render -> augroup -> per-buffer debounced autocmds -> FileType + catch-up loop).
-- The tokenizer mirrors `in_mathzone()` in lua/user/snippets_math.lua, but scans
-- the whole buffer with a position-tracking stack (so we can point at the exact
-- opener/closer) instead of the boolean toggles used there.

local api = vim.api
local WARN = vim.diagnostic.severity.WARN

local ns = api.nvim_create_namespace('math_balance')

-- LaTeX environments whose interior is math (mirrors snippets_math.lua's list).
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

-- Compute the diagnostic list for a set of lines. `ft` gates filetype-specific
-- skips (org directives/drawers/blocks vs. tex `%` comments).
local function compute(lines, ft)
  local is_org = ft == 'org'
  local diags = {}
  -- Stack of open delimiters, innermost last. Each: { kind, tok, desc, row, col }.
  -- `tok` is the literal opener text (for the message + underline length).
  local stack = {}
  local in_block -- name of an open verbatim `#+begin_<name>` block (org), or nil

  local function push(kind, tok, desc, row, col)
    stack[#stack + 1] = { kind = kind, tok = tok, desc = desc, row = row, col = col }
  end

  local function add(row, col, len, msg)
    diags[#diags + 1] = {
      lnum = row,
      col = col,
      end_lnum = row,
      end_col = col + len,
      severity = WARN,
      source = 'math-balance',
      message = msg,
    }
  end

  -- A math delimiter never legitimately spans a blank line or an org heading
  -- (a blank line inside `\[ \]`/`align` is invalid LaTeX). At those boundaries,
  -- report whatever is still open (localizes the error) and reset, so one stray
  -- `$` doesn't cascade mismatches through the rest of the document.
  local function flush()
    for _, e in ipairs(stack) do
      add(e.row, e.col, #e.tok, "Unclosed '" .. e.tok .. "' (" .. e.desc .. ')')
    end
    stack = {}
  end

  -- Close the innermost open delimiter with `want`; report stray/mismatched.
  local function close(want, tok, desc, row, col)
    local top = stack[#stack]
    if top and top.kind == want then
      stack[#stack] = nil
    elseif top then
      add(row, col, #tok, "'" .. tok .. "' closes '" .. top.tok .. "' (" .. top.desc .. ')')
      stack[#stack] = nil -- best-effort recovery: assume it closed the innermost
    else
      add(row, col, #tok, "Unmatched '" .. tok .. "' (no open " .. desc .. ')')
    end
  end

  -- Tokenize one line, advancing the shared stack. Early-returns for lines that
  -- must be skipped (org directives/blocks/drawers) or that reset at a boundary.
  local function scan_line(row, line)
    if is_org then
      if in_block then
        if line:lower():match('^%s*#%+end_' .. in_block) then
          in_block = nil
        end
        return
      end
      local b = line:lower():match('^%s*#%+begin_(%a+)')
      if b then
        if b == 'src' or b == 'example' or b == 'export' then
          in_block = b -- skip verbatim/code/export bodies (may contain literal `$`)
        end
        return
      end
      -- Skip org directives (`#+MACRO:` etc. -- the `title` snippet's macro line
      -- literally contains `$1`/`$2`), comments, and property drawers / fixed-width.
      if line:match('^%s*#%+') or line:match('^%s*#%s') or line:match('^%s*#$') or line:match('^%s*:') then
        return
      end
      if line:match('^%s*$') or line:match('^%*+%s') then
        flush()
        return
      end
    elseif line:match('^%s*$') then
      flush()
      return
    end

    local idx, n = 1, #line
    while idx <= n do
      local ch = line:sub(idx, idx)
      local two = line:sub(idx, idx + 1)
      if ch == '\\' then
        if two == '\\(' then
          push('paren', '\\(', 'inline math \\( \\)', row, idx - 1)
          idx = idx + 2
        elseif two == '\\[' then
          push('bracket', '\\[', 'display math \\[ \\]', row, idx - 1)
          idx = idx + 2
        elseif two == '\\)' then
          close('paren', '\\)', '\\(', row, idx - 1)
          idx = idx + 2
        elseif two == '\\]' then
          close('bracket', '\\]', '\\[', row, idx - 1)
          idx = idx + 2
        else
          local benv = line:match('^\\begin{(%a+)%*?}', idx)
          local eenv = benv == nil and line:match('^\\end{(%a+)%*?}', idx) or nil
          if benv then
            if MATH_ENVS[benv] then
              push('env:' .. benv, '\\begin{' .. benv .. '}', 'environment', row, idx - 1)
            end
            idx = (line:find('}', idx, true) or idx) + 1
          elseif eenv then
            if MATH_ENVS[eenv] then
              close('env:' .. eenv, '\\end{' .. eenv .. '}', '\\begin{' .. eenv .. '}', row, idx - 1)
            end
            idx = (line:find('}', idx, true) or idx) + 1
          else
            idx = idx + 2 -- other escape (\\, \$, \{, \alpha, …): consume both bytes
          end
        end
      elseif not is_org and ch == '%' then
        break -- tex line comment: ignore the rest of the line
      elseif two == '$$' then
        if stack[#stack] and stack[#stack].kind == 'display' then
          stack[#stack] = nil
        else
          push('display', '$$', 'display math $$', row, idx - 1)
        end
        idx = idx + 2
      elseif ch == '$' then
        if stack[#stack] and stack[#stack].kind == 'inline' then
          stack[#stack] = nil
        else
          push('inline', '$', 'inline math $ $', row, idx - 1)
        end
        idx = idx + 1
      else
        idx = idx + 1
      end
    end
  end

  for li, line in ipairs(lines) do
    scan_line(li - 1, line)
  end
  flush() -- end of buffer: anything still open is unclosed
  return diags
end

local function render(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  local ft = vim.bo[bufnr].filetype
  if ft ~= 'org' and ft ~= 'tex' then
    return
  end
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  vim.diagnostic.set(ns, bufnr, compute(lines, ft))
end

local group = api.nvim_create_augroup('math_balance', { clear = true })

local function setup_buffer(bufnr)
  if vim.b[bufnr].math_balance_setup then
    return
  end
  vim.b[bufnr].math_balance_setup = true

  local rerender = function()
    render(bufnr)
  end
  -- Immediate on save / leaving insert; debounced on normal-mode edits. (Global
  -- `update_in_insert = false` already defers the visual refresh to InsertLeave,
  -- so hooking TextChangedI would be redundant.)
  api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
    group = group,
    buffer = bufnr,
    callback = rerender,
  })
  local timer
  api.nvim_create_autocmd('TextChanged', {
    group = group,
    buffer = bufnr,
    callback = function()
      if timer then
        timer:stop()
      end
      timer = vim.defer_fn(rerender, 200)
    end,
  })
end

api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = { 'org', 'tex' },
  callback = function(ev)
    setup_buffer(ev.buf)
    render(ev.buf)
  end,
})

-- Catch org/tex buffers already loaded when this file is sourced.
for _, buf in ipairs(api.nvim_list_bufs()) do
  local ft = api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype
  if ft == 'org' or ft == 'tex' then
    setup_buffer(buf)
    render(buf)
  end
end
