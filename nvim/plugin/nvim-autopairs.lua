if vim.g.did_load_autopairs_plugin then
  return
end
vim.g.did_load_autopairs_plugin = true

local npairs = require('nvim-autopairs')

npairs.setup {
  check_ts = true, -- treesitter-aware: don't pair inside strings/comments
  fast_wrap = {}, -- default <M-e> to wrap the next object in a pair
  -- Leave <CR> entirely to nvim-cmp (completion.lua). This file is sourced
  -- AFTER completion.lua, so a <CR> map here would clobber cmp's Enter-confirm.
  map_cr = false,
}

-- In note buffers (LaTeX/org/markdown), auto-closing brackets get in the way of
-- writing math, so disable auto-pairing of `(`, `[`, `{` there while keeping it
-- in code buffers. `$` is likewise left un-paired -- we simply never register a
-- `$` rule. `cond.not_filetypes` returns false in these filetypes (blocking the
-- pair) and nil elsewhere (so normal behaviour is untouched everywhere else).
local cond = require('nvim-autopairs.conds')
local NOTE_FT = { 'tex', 'org', 'markdown' }
for _, open in ipairs { '(', '[', '{' } do
  for _, rule in ipairs(npairs.get_rules(open)) do
    rule:with_pair(cond.not_filetypes(NOTE_FT))
  end
end

-- Insert the closing pair after nvim-cmp confirms a function/method completion.
local cmp_status, cmp = pcall(require, 'cmp')
if cmp_status then
  cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
end
