if vim.g.did_load_org_src_block_bg_plugin then
  return
end
vim.g.did_load_org_src_block_bg_plugin = true

-- Shade the background of `#+begin_src … #+end_src` blocks in org buffers so
-- they're visually distinct from surrounding prose. nvim-orgmode's treesitter
-- query only tags the block delimiters/params (`@org.block`), not the body as
-- a whole, so there's no query-based way to get a background on the block --
-- this scans the buffer for src-block spans and paints them with extmarks
-- instead (same technique as `note-highlight.lua`'s macro colouring).
--
-- The highlight is linked to `CursorLine` rather than a hardcoded colour: that
-- group is already themed as "background, one shade off Normal" by every
-- colorscheme, so the block shade tracks whatever colorscheme is active
-- (tokyonight-night's `bg_highlight`, currently) with no colour picked here.

local api = vim.api

local ns = api.nvim_create_namespace('org_src_block_bg')

local function define_highlight()
  api.nvim_set_hl(0, 'OrgSrcBlockBg', { link = 'CursorLine' })
end

define_highlight()

-- Repaint every `#+begin_src … #+end_src` span in the buffer.
local function render(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local begin_row
  for i, line in ipairs(lines) do
    local row = i - 1
    local lower = line:lower()
    if not begin_row then
      if lower:match('^%s*#%+begin_src%s') or lower:match('^%s*#%+begin_src$') then
        begin_row = row
      end
    elseif lower:match('^%s*#%+end_src%s*$') then
      api.nvim_buf_set_extmark(bufnr, ns, begin_row, 0, {
        end_row = row + 1,
        end_col = 0,
        hl_group = 'OrgSrcBlockBg',
        hl_eol = true,
        priority = 90, -- below treesitter's default 100; only sets `bg` so it doesn't matter much
      })
      begin_row = nil
    end
  end
end

local group = api.nvim_create_augroup('org_src_block_bg', { clear = true })

local function setup_buffer(bufnr)
  if vim.b[bufnr].org_src_block_bg_setup then
    return
  end
  vim.b[bufnr].org_src_block_bg_setup = true

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
  callback = define_highlight,
})

-- Catch org buffers already loaded when this file is sourced.
for _, buf in ipairs(api.nvim_list_bufs()) do
  if api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'org' then
    setup_buffer(buf)
    render(buf)
  end
end
