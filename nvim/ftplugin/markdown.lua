local utils = require('user.utils')
local null_ls = require('null-ls')
local helpers = require('null-ls.helpers')

local markdownlint = {
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { 'markdown' },
  -- null_ls.generator creates an async source
  -- that spawns the command with the given arguments and options
  generator = null_ls.generator {
    -- command = markdownlint_path,
    command = 'markdownlint-cli2',
    args = { '--stdin' },
    to_stdin = true,
    from_stderr = true,
    -- choose an output format (raw, json, or line)
    format = 'line',
    check_exit_code = function(code, stderr)
      local success = code <= 1

      if not success then
        -- can be noisy for things that run often (e.g. diagnostics), but can
        -- be useful for things that run on demand (e.g. formatting)
        print(stderr)
      end

      return success
    end,
    -- use helpers to parse the output from string matchers,
    -- or parse it manually with a function
    on_output = helpers.diagnostics.from_patterns {
      {
        pattern = [[:(%d+):(%d+) [%w-/]+ (.*)]],
        groups = { 'row', 'col', 'message' },
      },
      {
        pattern = [[:(%d+) [%w-/]+ (.*)]],
        groups = { 'row', 'message' },
      },
    },
  },
}

-- Check if markdownlint-cli2 is available
local function is_markdownlint_installed()
  return os.execute('command -v markdownlint-cli2 > /dev/null 2>&1') == 0
end

vim.defer_fn(function()
  -- print('This runs after a 2-second delay!')
  if is_markdownlint_installed() then
    -- vim.print('Registering markdownlint with null-ls')
    null_ls.register(markdownlint)
  end
end, 1000)

local function is_executable(cmd)
  local handle = io.popen('command -v ' .. cmd .. ' 2>/dev/null')
  if not handle then
    return false
  end
  local result = handle:read('*a')
  handle:close()
  return result ~= ''
end

-- if is_executable('R') then
--   require('otter').activate { 'r' }
-- end
-- if is_executable('python3') or is_executable('python') then
--   require('otter').activate { 'python' }
-- end
-- if is_executable('bash') then
--   require('otter').activate { 'bash' }
-- end

-- require('otter').activate { 'r', 'python', 'bash' }
