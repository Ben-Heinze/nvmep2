---@mod user.org_babel
---
---@brief [[
---Minimal org-babel-equivalent for nvim-orgmode: run the `#+begin_src` block
---under the cursor and write its output back into the document as a
---`#+RESULTS:` block (Emacs `: `-prefixed fixed-width lines).
---
---Pure-Lua, async (`vim.system`), no save required. Interpreters/compilers are
---resolved from `$PATH` (provide R/JDK via direnv per project). Languages are
---data-driven in `M.languages`, so adding one is a few lines.
---
---Entry point: `require('user.org_babel').execute_src_block_at_cursor()`.
---@brief ]]

local M = {}

-- Language runner specs. Each spec has an `ext` (temp-file extension) and
-- either:
--   * `cmd(file) -> argv`                      for interpreted languages, or
--   * `compile(file, exe) -> argv` + `run(file, exe) -> argv`  for compiled ones.
-- `bin` lists the executables that must be on PATH (first found wins for `cc`).
-- `filename` forces a specific temp filename when the toolchain cares about it.
M.languages = {
  python = {
    bin = { 'python3' },
    ext = 'py',
    cmd = function(file)
      return { 'python3', file }
    end,
  },
  r = {
    bin = { 'Rscript' },
    ext = 'R',
    cmd = function(file)
      return { 'Rscript', file }
    end,
  },
  cpp = {
    bin = { 'g++', 'clang++' },
    ext = 'cpp',
    compile = function(file, exe)
      local cc = vim.fn.executable('g++') == 1 and 'g++' or 'clang++'
      return { cc, '-std=c++20', file, '-o', exe }
    end,
    run = function(_, exe)
      return { exe }
    end,
  },
  java = {
    bin = { 'java' },
    ext = 'java',
    -- Single-file source-code mode (JEP 330, JDK 11+). The filename need not
    -- match the public class, so we always use Main.java.
    filename = 'Main.java',
    cmd = function(file)
      return { 'java', file }
    end,
  },
}

-- Map the language string written in `#+begin_src <lang>` to a spec key.
M.aliases = {
  ['c++'] = 'cpp',
  cxx = 'cpp',
  ['R'] = 'r',
  rscript = 'r',
  py = 'python',
  python3 = 'python',
}

---Resolve a `#+begin_src` language token to a spec, honouring aliases.
---@param lang string
---@return string? key, table? spec
local function resolve_language(lang)
  local key = lang:lower()
  key = M.aliases[lang] or M.aliases[key] or key
  return M.languages[key] and key or nil, M.languages[key]
end

---Locate the src block under the cursor via treesitter, with a line-scan
---fallback for partially-parsed buffers.
---@param bufnr integer
---@return table? block  { lang, code, begin_row, end_row, header } (0-indexed rows)
local function find_src_block(bufnr)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
  if ok and node then
    while node and node:type() ~= 'block' do
      node = node:parent()
    end
    if node then
      local name = node:field('name')[1]
      if name and vim.treesitter.get_node_text(name, bufnr):lower() == 'src' then
        local param = node:field('parameter')[1]
        local contents = node:field('contents')[1]
        local begin_row = select(1, node:range())
        -- End row is the line holding `#+end_src`.
        local end_row = nil
        for i = 0, node:child_count() - 1 do
          local child = node:child(i)
          if child and child:type():match('^#%+end_') then
            end_row = select(1, child:range())
          end
        end
        if not end_row then
          local br, _, er, ec = node:range()
          end_row = ec == 0 and er - 1 or er
          begin_row = br
        end
        return {
          lang = param and vim.treesitter.get_node_text(param, bufnr) or '',
          code = contents and vim.treesitter.get_node_text(contents, bufnr) or '',
          begin_row = begin_row,
          end_row = end_row,
          header = vim.api.nvim_buf_get_lines(bufnr, begin_row, begin_row + 1, false)[1] or '',
        }
      end
    end
  end

  -- Fallback: scan outward from the cursor for begin/end fences.
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cur = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
  local begin_row
  for i = cur, 0, -1 do
    local l = lines[i + 1] or ''
    if l:match('^%s*#%+[eE][nN][dD]_[sS][rR][cC]') and i < cur then
      return nil -- cursor sits below a closed block, not inside one
    end
    if l:match('^%s*#%+[bB][eE][gG][iI][nN]_[sS][rR][cC]%s+%S+') then
      begin_row = i
      break
    end
  end
  if not begin_row then
    return nil
  end
  local end_row
  for i = begin_row + 1, #lines - 1 do
    if (lines[i + 1] or ''):match('^%s*#%+[eE][nN][dD]_[sS][rR][cC]') then
      end_row = i
      break
    end
  end
  if not end_row then
    return nil
  end
  return {
    lang = lines[begin_row + 1]:match('#%+[bB][eE][gG][iI][nN]_[sS][rR][cC]%s+(%S+)') or '',
    code = table.concat(vim.list_slice(lines, begin_row + 2, end_row), '\n'),
    begin_row = begin_row,
    end_row = end_row,
    header = lines[begin_row + 1],
  }
end

---Parse `:key value` header args off the `#+begin_src` line.
---@param header string
---@return table
local function parse_header(header)
  local args = {}
  for key, val in header:gmatch(':(%w+)%s+([^:]*)') do
    args[key] = vim.trim(val)
  end
  return args
end

---Build the `#+RESULTS:` lines for a chunk of program output.
---@param output string
---@return string[]
local function build_results(output)
  local lines = { '#+RESULTS:' }
  output = output:gsub('\n$', '')
  if output == '' then
    table.insert(lines, ': ')
  else
    for _, line in ipairs(vim.split(output, '\n', { plain = true })) do
      table.insert(lines, ': ' .. line)
    end
  end
  return lines
end

---Replace (or insert) the `#+RESULTS:` block that follows `end_row`.
---@param bufnr integer
---@param end_row integer  0-indexed row of `#+end_src`
---@param result_lines string[]
local function set_results(bufnr, end_row, result_lines)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local anchor = end_row + 1 -- 0-indexed row directly after #+end_src

  -- Skip blank lines to find an existing results header.
  local i = anchor
  while lines[i + 1] and lines[i + 1]:match('^%s*$') do
    i = i + 1
  end

  local start_row, end_row_excl
  if lines[i + 1] and lines[i + 1]:lower():match('^%s*#%+results:') then
    start_row = i
    local j = i + 1
    while lines[j + 1] do
      local l = lines[j + 1]
      if l:match('^%s*: ') or l:match('^%s*:$') then
        j = j + 1
      elseif l:lower():match('^%s*#%+begin_example') then
        -- consume an example drawer if a previous run wrote one
        j = j + 1
        while lines[j + 1] and not lines[j + 1]:lower():match('^%s*#%+end_example') do
          j = j + 1
        end
        j = lines[j + 1] and j + 1 or j
      else
        break
      end
    end
    end_row_excl = j
  else
    -- No existing results: insert directly after #+end_src (Emacs style).
    start_row = anchor
    end_row_excl = anchor
  end

  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row_excl, false, result_lines)
end

---Run a resolved spec asynchronously and deliver combined output to `on_done`.
local function run_spec(spec, block, on_done)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, 'p')
  local file = dir .. '/' .. (spec.filename or ('code.' .. spec.ext))
  local exe = dir .. '/a.out'
  local fh = io.open(file, 'w')
  if not fh then
    on_done('could not write temp file ' .. file)
    vim.fn.delete(dir, 'rf')
    return
  end
  fh:write(block.code, '\n')
  fh:close()

  local function cleanup()
    -- on_exit runs in a fast event context; defer filesystem cleanup.
    vim.schedule(function()
      vim.fn.delete(dir, 'rf')
    end)
  end

  local function combine(res)
    local body = res.stdout or ''
    if res.code ~= 0 then
      body = body .. (res.stderr or '')
    end
    if vim.trim(body) == '' then
      body = res.stderr or body
    end
    if vim.trim(body) == '' and res.code ~= 0 then
      body = 'process exited with code ' .. res.code
    end
    return body
  end

  if spec.compile then
    vim.system(spec.compile(file, exe), { text = true }, function(cres)
      if cres.code ~= 0 then
        on_done(combine(cres))
        cleanup()
        return
      end
      vim.system(spec.run(file, exe), { text = true }, function(rres)
        on_done(combine(rres))
        cleanup()
      end)
    end)
  else
    vim.system(spec.cmd(file), { text = true }, function(res)
      on_done(combine(res))
      cleanup()
    end)
  end
end

---Execute the `#+begin_src` block under the cursor and write `#+RESULTS:`.
function M.execute_src_block_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local block = find_src_block(bufnr)
  if not block then
    vim.notify('org-babel: cursor is not inside a src block', vim.log.levels.WARN)
    return
  end

  local key, spec = resolve_language(block.lang)
  if not spec then
    vim.notify(('org-babel: no runner for language %q'):format(block.lang), vim.log.levels.WARN)
    return
  end

  local header = parse_header(block.header)
  if header.results == 'silent' then
    -- Run for side effects but do not touch the buffer.
    if vim.fn.executable(spec.bin[1]) == 1 then
      run_spec(spec, block, function() end)
    end
    return
  end

  -- Guard: required tool present?
  local have = false
  for _, bin in ipairs(spec.bin) do
    if vim.fn.executable(bin) == 1 then
      have = true
      break
    end
  end
  if not have then
    set_results(bufnr, block.end_row, build_results(table.concat(spec.bin, '/') .. ' not found on PATH'))
    return
  end

  -- Immediate placeholder, replaced when the async job finishes.
  set_results(bufnr, block.end_row, { '#+RESULTS:', ': running…' })

  run_spec(spec, block, function(output)
    vim.schedule(function()
      -- Results live below #+end_src, so the block's own rows don't shift; the
      -- placeholder we just wrote is found and replaced relative to end_row.
      set_results(bufnr, block.end_row, build_results(output))
      vim.notify('org-babel: ' .. key .. ' done', vim.log.levels.INFO)
    end)
  end)
end

return M
