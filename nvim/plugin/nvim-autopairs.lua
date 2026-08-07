if vim.g.did_load_autopairs_plugin then
  return
end
vim.g.did_load_autopairs_plugin = true

local npairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')

npairs.setup {
  check_ts = true, -- treesitter-aware: don't pair inside strings/comments
  fast_wrap = {}, -- default <M-e> to wrap the next object in a pair
  -- Leave <CR> entirely to nvim-cmp (completion.lua). This file is sourced
  -- AFTER completion.lua, so a <CR> map here would clobber cmp's Enter-confirm.
  map_cr = false,
}

-- Auto-pair `$...$` in prose/math filetypes so entering inline math is one key.
npairs.add_rules {
  Rule('$', '$', { 'tex', 'org', 'markdown' }),
}

-- Insert the closing pair after nvim-cmp confirms a function/method completion.
local cmp_status, cmp = pcall(require, 'cmp')
if cmp_status then
  cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
end
