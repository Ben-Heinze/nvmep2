if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true

local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

-- Copilot maps <Tab> in insert mode by default, which steals the Smart-Tab
-- (snippet jump / completion) mapping below. Stop it grabbing <Tab> and move
-- "accept suggestion" to <C-l>. Must be set before copilot maps its keys.
vim.g.copilot_no_tab_map = true
vim.keymap.set('i', '<C-l>', 'copilot#Accept("")', {
  expr = true,
  replace_keycodes = false,
  silent = true,
  desc = 'Copilot: accept suggestion',
})

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

---@param source string|table
local function complete_with_source(source)
  if type(source) == 'string' then
    cmp.complete { config = { sources = { { name = source } } } }
  elseif type(source) == 'table' then
    cmp.complete { config = { sources = { source } } }
  end
end

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
    -- autocomplete = false,
  },
  formatting = {
    format = lspkind.cmp_format {
      mode = 'symbol_text',
      with_text = true,
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

      menu = {
        buffer = '[BUF]',
        nvim_lsp = '[LSP]',
        nvim_lsp_signature_help = '[LSP]',
        nvim_lsp_document_symbol = '[LSP]',
        nvim_lua = '[API]',
        path = '[PATH]',
        luasnip = '[SNIP]',
        latex_symbols = '[TeX]',
      },
    },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(-4)
      else
        complete_with_source('buffer')
      end
    end, { 'i', 'c', 's' }),
    ['<C-f>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(4)
      else
        complete_with_source('path')
      end
    end, { 'i', 'c', 's' }),
    -- <C-n>/<C-p> navigate the completion menu (down/up). When the menu is
    -- closed, <C-n> opens it. Snippet jumping lives on <Tab>/<S-Tab>, not here.
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    -- toggle completion
    ['<C-e>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete()
      end
    end, { 'i', 'c', 's' }),
    ['<C-y>'] = cmp.mapping.confirm {
      select = true,
    },
    -- <Tab> / <S-Tab> ONLY move between snippet tab-stops (e.g. the two {} in
    -- \frac{}{}). They deliberately never touch the completion menu: accept a
    -- completion with <C-y>, navigate the menu with <C-n>/<C-p>. Outside a
    -- snippet they fall back to a literal <Tab>/<S-Tab>.
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    -- Enter confirms an *explicitly selected* entry; otherwise it falls through
    -- (newline, and lets nvim-autopairs' own <CR> handling run).
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() and cmp.get_selected_entry() then
        cmp.confirm { select = false }
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = cmp.config.sources {
    -- The insertion order influences the priority of the sources
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'nvim_lsp_signature_help', keyword_length = 3 },
    { name = 'luasnip', keyword_length = 1 },
    { name = 'buffer' },
    { name = 'path' },
  },
  enabled = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match('org%-roam%-select$') ~= nil then
      return false
    end
    return vim.bo[0].buftype ~= 'prompt'
  end,
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}

cmp.setup.filetype('lua', {
  sources = cmp.config.sources {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'path' },
  },
})

-- Note/math filetypes: add a fuzzy LaTeX-command source (cmp-latex-symbols).
-- It triggers after a backslash (its keyword pattern is `\...`), so typing
-- `\al` fuzzy-lists `\alpha`, `\aleph`, ... ; <CR> inserts the pick.
-- `strategy = 2` (= "latex") inserts the `\command` form, which renders in org/tex.
-- (The no-backslash fast path for common symbols is the luasnip triggers.)
cmp.setup.filetype({ 'org', 'tex', 'markdown' }, {
  sources = cmp.config.sources {
    { name = 'luasnip', keyword_length = 1 },
    { name = 'latex_symbols', keyword_length = 2, option = { strategy = 2 } },
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'nvim_lsp_signature_help', keyword_length = 3 },
    { name = 'buffer' },
    { name = 'path' },
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'nvim_lsp_document_symbol', keyword_length = 3 },
    { name = 'buffer' },
    { name = 'cmdline_history' },
  },
  view = {
    entries = { name = 'wildmenu', separator = '|' },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources {
    { name = 'cmdline' },
    { name = 'cmdline_history' },
    { name = 'path' },
  },
})

-- <C-n>: navigate the menu down when it's open, otherwise open it. (This
-- explicit map would otherwise shadow the <C-n> entry in cmp's mapping table,
-- so it carries the same select-next behaviour.)
vim.keymap.set({ 'i', 'c', 's' }, '<C-n>', function()
  if cmp.visible() then
    cmp.select_next_item()
  else
    cmp.complete()
  end
end, { noremap = false, desc = '[cmp] menu down / open' })
vim.keymap.set({ 'i', 'c', 's' }, '<C-f>', function()
  complete_with_source('path')
end, { noremap = false, desc = '[cmp] path' })
vim.keymap.set({ 'i', 'c', 's' }, '<C-o>', function()
  complete_with_source('nvim_lsp')
end, { noremap = false, desc = '[cmp] lsp' })
vim.keymap.set({ 'c' }, '<C-h>', function()
  complete_with_source('cmdline_history')
end, { noremap = false, desc = '[cmp] cmdline history' })
vim.keymap.set({ 'c' }, '<C-c>', function()
  complete_with_source('cmdline')
end, { noremap = false, desc = '[cmp] cmdline' })
