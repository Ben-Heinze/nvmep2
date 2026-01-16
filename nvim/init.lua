vim.loader.enable()

local cmd = vim.cmd
local opt = vim.o

-- {{{ opts

opt.clipboard = 'unnamedplus'
opt.foldmethod = 'marker'

vim.opt.fillchars = {
  stl = '━',
  stlnc = '━',
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- vim.opt.statusline = ''
-- vim.opt.statusline = ' %= %l/%3L' -- Example status line
vim.opt.statusline = '%=' -- Example status line

vim.opt.showtabline = 2

-- <leader> key. Defaults to `\`. Some people prefer space.
-- The default leader is '\'. Some people prefer <space>. Uncomment this if you do, too.
-- vim.g.mapleader = ' '
-- vim.g.maplocalleader = ' '

-- See :h <option> to see what the options do

-- Search down into subfolders
opt.path = vim.o.path .. '**'

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.lazyredraw = true
opt.showmatch = true -- Highlight matching parentheses, etc
opt.incsearch = true
opt.hlsearch = true

opt.spell = true
opt.spelllang = 'en'

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.foldenable = true
opt.history = 2000
opt.nrformats = 'bin,hex' -- 'octal'
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
-- opt.cmdheight = 0
-- vim.api.nvim_create_autocmd('RecordingEnter', {
--   callback = function()
--     vim.opt.cmdheight = 1
--   end,
-- })
-- vim.api.nvim_create_autocmd('RecordingLeave', {
--   allback = function()
--     vim.opt.cmdheight = 0
--   end,
-- })

-- opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
opt.colorcolumn = '100'

-- }}} opts

-- plugin opts

-- TODO: move to plugin config file
vim.g.nuake_position = 'bottom'
vim.g.nuake_per_tab = 1

-- {{{ Configure Neovim diagnostic messages

local function prefix_diagnostic(prefix, diagnostic)
  return string.format(prefix .. ' %s', diagnostic.message)
end

vim.diagnostic.config {
  virtual_text = {
    prefix = '',
    format = function(diagnostic)
      local severity = diagnostic.severity
      if severity == vim.diagnostic.severity.ERROR then
        return prefix_diagnostic('󰅚', diagnostic)
      end
      if severity == vim.diagnostic.severity.WARN then
        return prefix_diagnostic('⚠', diagnostic)
      end
      if severity == vim.diagnostic.severity.INFO then
        return prefix_diagnostic('ⓘ', diagnostic)
      end
      if severity == vim.diagnostic.severity.HINT then
        return prefix_diagnostic('󰌶', diagnostic)
      end
      return prefix_diagnostic('■', diagnostic)
    end,
  },
  signs = {
    text = {
      -- Requires Nerd fonts
      [vim.diagnostic.severity.ERROR] = '󰅚',
      [vim.diagnostic.severity.WARN] = '⚠',
      [vim.diagnostic.severity.INFO] = 'ⓘ',
      [vim.diagnostic.severity.HINT] = '󰌶',
    },
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'if_many',
    header = '',
    prefix = '',
  },
}

-- }}} Configure Neovim diagnostic messages

-- {{{ Native plugins

cmd.filetype('plugin', 'indent', 'on')
cmd.packadd('cfilter') -- Allows filtering the quickfix list with :cfdo

-- }}} Native plugins

-- {{{ let sqlite.lua (which some plugins depend on) know where to find sqlite

vim.g.sqlite_clib_path = require('luv').os_getenv('LIBSQLITE')

-- }}} let sqlite.lua (which some plugins depend on) know where to find sqlite

-- {{{ Plugin Free Key mappings

local function mymap(mode, key, value)
  vim.keymap.set(mode, key, value, { silent = true, remap = true })
end

---@diagnostic disable-next-line: unused-function, unused-local
local function toggle_quickfix()
  if vim.fn.empty(vim.fn.getqflist()) == 1 then
    print('Quickfix list is empty!')
    return
  end
  local quickfix_open = false
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    local wininfo = vim.fn.getwininfo(win)[1]
    if wininfo.loclist == 0 and wininfo.quickfix == 1 then
      quickfix_open = true
      break
    end
  end
  if quickfix_open then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
  end
end

---@diagnostic disable-next-line: lowercase-global
show_line_diagnostics = function()
  local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] })
  if line_diagnostics then
    vim.diagnostic.open_float(0, { severity_limit = 'Error' })
  end
end

-- mymap('n', '<Space>cc', '<CMD>CToggle<CR>')
-- mymap('n', '<A-S-return>', '<CMD>silent make<CR>')
-- mymap('n', 'I', '<CMD>lua vim.diagnostic.show_line_diagnostics()<CR>')

mymap('n', '<A-S-Tab>', '<CMD>bp<CR>')
mymap('n', '<A-Tab>', '<CMD>bn<CR>')
mymap('n', '<Space><return>', '<CMD>Nuake<CR>')
mymap('n', '<Space>bn', '<CMD>bn<CR>')
mymap('n', '<Space>bp', '<CMD>bp<CR>')
mymap('n', '<Space>cc', '<CMD>CodeCompanionChat<CR>')
mymap('n', '<Space>co', '<CMD>CToggle<CR>')
mymap('n', '<Space>ht', '<CMD>Tutor<CR>')
mymap('n', '<Space>mm', '<CMD>silent make<CR>')
mymap('n', '<Space>oc', '<CMD>OpenConfig<CR>')
mymap('n', '<Space>tn', '<CMD>lua toggle_number()<CR>')
mymap('n', '<Space>tt', '<CMD>lua toggle_todo()<CR>')
mymap('n', 'I', '<CMD>lua show_line_diagnostics()<CR>')

local border = {
  { '╭', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '╮', 'FloatBorder' },
  { '│', 'FloatBorder' },
  { '╯', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '╰', 'FloatBorder' },
  { '│', 'FloatBorder' },
}
local hover_active = false -- State to track if hover is active
local function toggle_hover()
  if hover_active then
    vim.lsp.buf.clear_references() -- This clears the hover window
    hover_active = false
  else
    local opts = {
      border = border,
      focusable = true,
      focus = true,
      style = 'minimal',
      height = 30,
      width = 120,
      title_pos = 'left',
      relative = 'cursor',
      anchor_bias = 'above',
    }
    vim.lsp.buf.hover(opts)
    hover_active = true
  end
end
-- mymap('n', 'K', toggle_hover)

mymap('n', 'K', vim.lsp.buf.hover)

-- local hover_active = false -- State to track if hover is active
-- local float_win_id = nil -- Window ID for the hover window
-- local original_win_id = nil -- Store original window ID for context switch
--
-- -- Custom border for LSP hover
-- local border = {
--   { '╭', 'FloatBorder' },
--   { '─', 'FloatBorder' },
--   { '╮', 'FloatBorder' },
--   { '│', 'FloatBorder' },
--   { '╯', 'FloatBorder' },
--   { '─', 'FloatBorder' },
--   { '╰', 'FloatBorder' },
--   { '│', 'FloatBorder' },
-- }
--
-- -- Function to show/hide hover information with a custom border
-- local function toggle_hover()
--   if hover_active and float_win_id then
--     -- If hover is active, close it and reset the state
--     pcall(vim.api.nvim_win_close, float_win_id, true) -- Close the hover window safely
--     hover_active = false
--     float_win_id = nil
--     -- Return focus to the original window
--     if original_win_id then
--       vim.api.nvim_set_current_win(original_win_id)
--     end
--   else
--     -- Store the original window ID
--     original_win_id = vim.api.nvim_get_current_win()
--
--     -- If hover is not active, get hover information
--     vim.lsp.buf_request(0, 'textDocument/hover', vim.lsp.util.make_position_params(), function(err, result)
--       if err or not result or not result.contents then
--         return
--       end
--
--       -- Format the contents for open_floating_preview
--       local contents = {}
--
--       if type(result.contents) == 'table' then
--         for _, item in ipairs(result.contents) do
--           if type(item) == 'string' then
--             table.insert(contents, item)
--           elseif item.value then
--             table.insert(contents, item.value) -- Use the value field if available
--           end
--         end
--       elseif type(result.contents) == 'string' then
--         table.insert(contents, result.contents)
--       end
--
--       -- Open the hover window with the formatted content
--       float_win_id = vim.lsp.util.open_floating_preview(contents, 'markdown', {
--         border = border,
--         focusable = true,
--         style = 'minimal',
--         relative = 'cursor',
--         height = 10,
--         width = 30,
--       })
--       hover_active = true
--
--       -- Focus on the hover window
--       vim.api.nvim_set_current_win(float_win_id)
--     end)
--   end
-- end
--
-- -- Map the key to the toggle hover function
-- mymap('n', 'K', toggle_hover)

mymap('n', ']e', '<CMD>lua vim.diagnostic.goto_next()<CR>')
mymap('n', 'g:', '<CMD>term<CR>')
mymap('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>')
mymap('n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>')
mymap('n', 'gi', '<CMD>lua vim.lsp.buf.implementation()<CR>')

-- Window right
mymap('n', '<A-l>', '<CMD>wincmd l<CR>')
mymap('t', '<A-l>', '<CMD>wincmd l<CR>')
mymap('n', '<Space>wl', '<CMD>wincmd l<CR>')
--mymap('t', '<Space>wl', '<CMD>wincmd l<CR>')

-- Window left
mymap('n', '<A-h>', '<CMD>wincmd h<CR>')
mymap('t', '<A-h>', '<CMD>wincmd h<CR>')
mymap('n', '<Space>wh', '<CMD>wincmd h<CR>')
-- mymap('t', '<Space>wh', '<CMD>wincmd h<CR>')

-- Window down
mymap('n', '<A-j>', '<CMD>wincmd j<CR>')
mymap('t', '<A-j>', '<CMD>wincmd j<CR>')
mymap('n', '<Space>wj', '<CMD>wincmd j<CR>')
-- mymap('t', '<Space>wj', '<CMD>wincmd j<CR>')

-- Window up
mymap('n', '<A-k>', '<CMD>wincmd k<CR>')
mymap('t', '<A-k>', '<CMD>wincmd k<CR>')
mymap('n', '<Space>wk', '<CMD>wincmd k<CR>')
-- mymap('t', '<Space>wk', '<CMD>wincmd k<CR>')

-- Split pane horizontal
mymap('n', '<A-s>', '<CMD>split<CR>')
mymap('n', '<Space>ws', '<CMD>split<CR>')
mymap('t', '<A-s>', '<CMD>split<CR>')

-- Split pane vertical
mymap('n', '<A-v>', '<CMD>vsplit<CR>')
mymap('n', '<Space>wv', '<CMD>vsplit<CR>')
mymap('t', '<A-v>', '<CMD>vsplit<CR>')

-- Delete pane
mymap('n', '<A-d>', '<CMD>close<CR>')
mymap('n', '<Space>wd', '<CMD>close<CR>')
mymap('t', '<A-d>', '<CMD>close<CR>')

-- Seems to mess up terminal mode too much (What about A-1, A-2, etc?)
-- mymap('t', '1', ':tabn1<CR>')
-- mymap('t', '2', ':tabn2<CR>')
-- mymap('t', '3', ':tabn3<CR>')
-- mymap('t', '4', ':tabn4<CR>')
-- mymap('t', '5', ':tabn5<CR>')
-- mymap('t', '6', ':tabn6<CR>')
-- mymap('t', '7', ':tabn7<CR>')
-- mymap('t', '8', ':tabn8<CR>')
-- mymap('t', '9', ':tabn9<CR>')

-- Project Shell
mymap('n', '<Space>ps', '<CMD>sp<CR> <CMD>wincmd j<CR> <CMD>terminal<CR> a')
-- mymap('t', '<Space>ps', '<CMD>sp<CR> <CMD>wincmd j<CR> <CMD>terminal<CR> a')
mymap('n', '<C-t>', '<CMD>tabnew<CR>')

mymap('n', '<A-1>', ':tabn1<CR>')
mymap('n', '<A-2>', ':tabn2<CR>')
mymap('n', '<A-3>', ':tabn3<CR>')
mymap('n', '<A-4>', ':tabn4<CR>')
mymap('n', '<A-5>', ':tabn5<CR>')
mymap('n', '<A-6>', ':tabn6<CR>')
mymap('n', '<A-7>', ':tabn7<CR>')
mymap('n', '<A-8>', ':tabn8<CR>')
mymap('n', '<A-9>', ':tabn9<CR>')

-- mymap('n', '1', ':tabn1<CR>')
-- mymap('n', '2', ':tabn2<CR>')
-- mymap('n', '3', ':tabn3<CR>')
-- mymap('n', '4', ':tabn4<CR>')
-- mymap('n', '5', ':tabn5<CR>')
-- mymap('n', '6', ':tabn6<CR>')
-- mymap('n', '7', ':tabn7<CR>')
-- mymap('n', '8', ':tabn8<CR>')
-- mymap('n', '9', ':tabn9<CR>')
-- mymap('n', '<Space>qq', '<CMD>wa<CR><CMD>qa!<CR>')
mymap('n', '<Space>rr', '<CMD>luafile $MYVIMRC<CR><CMD>ReloadFTPlugins<CR><CMD>echo "Reloaded config"<CR>')
mymap('n', '<Space>tgc', '<CMD>Telescope git_commits<CR>')
-- These only work in gvim.... :(
mymap('n', '<C-tab>', '<CMD>tabnext<CR>')
mymap('n', '<C-S-tab>', '<CMD>tabprevious<CR>')

mymap('n', '<Space>uo', '<CMD>lua vim.ui.open(vim.fn.expand("%"))<CR>')

-- }}} Base Key mappings

-- {{{ Plugin mappings

-- {{{ nvimtree
mymap('n', '<Space>ff', '<CMD>NvimTreeToggle<CR>')
-- }}} nvimtree

-- {{{ smart split resize bindings

mymap('n', '<A-S-h>', "<CMD>lua require('smart-splits').resize_left()<CR>")
mymap('t', '<A-S-h>', "<CMD>lua require('smart-splits').resize_left()<CR>")

mymap('n', '<A-S-k>', "<CMD>lua require('smart-splits').resize_up()<CR>")
mymap('t', '<A-S-k>', "<CMD>lua require('smart-splits').resize_up()<CR>")
mymap(
  'n',
  '<A-S-->',
  "<CMD>lua require('smart-splits').resize_up()<CR><CMD>lua require('smart-splits').resize_left()<CR>"
)
mymap(
  'n',
  '<A-S-=>',
  "<CMD>lua require('smart-splits').resize_down()<CR><CMD>lua require('smart-splits').resize_right()<CR>"
)

mymap('n', '<A-S-j>', "<CMD>lua require('smart-splits').resize_down()<CR>")
mymap('t', '<A-S-j>', "<CMD>lua require('smart-splits').resize_down()<CR>")
mymap('n', '<A-S-l>', "<CMD>lua require('smart-splits').resize_right()<CR>")
mymap('t', '<A-S-l>', "<CMD>lua require('smart-splits').resize_right()<CR>")

mymap('n', '<A-C-h>', "<CMD>lua require('smart-splits').swap_buf_left()<CR>")
mymap('t', '<A-C-h>', "<CMD>lua require('smart-splits').swap_buf_left()<CR>")
mymap('n', '<A-C-l>', "<CMD>lua require('smart-splits').swap_buf_right()<CR>")
mymap('t', '<A-C-l>', "<CMD>lua require('smart-splits').swap_buf_right()<CR>")
mymap('n', '<A-C-j>', "<CMD>lua require('smart-splits').swap_buf_down()<CR>")
mymap('t', '<A-C-j>', "<CMD>lua require('smart-splits').swap_buf_down()<CR>")
mymap('n', '<A-C-k>', "<CMD>lua require('smart-splits').swap_buf_up()<CR>")
mymap('t', '<A-C-k>', "<CMD>lua require('smart-splits').swap_buf_up()<CR>")

-- }}} smart split resize bindings

-- {{{ Telescope mappings

mymap('n', '<Space>yy', ':Telescope luasnip<CR>')
mymap('n', '<Space>bb', '<CMD>Telescope buffers<CR>')
mymap('n', '<Space>hh', '<CMD>Telescope help_tags<CR>')
mymap('n', '<A-x>', '<CMD>Telescope commands<CR>')
mymap('n', '/', '<CMD>Telescope current_buffer_fuzzy_find theme=ivy<CR>')
mymap('n', '<Space>pf', '<CMD>Telescope find_files<CR>')
mymap('n', '<Space>pr', '<CMD>Telescope live_grep<CR>')
mymap('n', '<Space>po', '<CMD>Telescope project<CR>')

-- }}} Telescope mappings

-- {{{ Slime

vim.g.slime_target = 'neovim'

wrapped_slime = function()
  vim.cmd('sleep 10m')
  vim.cmd('normal! gv')
  vim.cmd('sleep 10m')
  vim.cmd("'<,'>SlimeSend") -- Send to Slime
  vim.cmd('sleep 10m')
end

mymap('n', '<A-return>', '<CMD>SlimeSend<CR><CR>')
-- mymap('v', '<A-return>', "<CMD>'<,'>SlimeSend<CR><CR>")
mymap('v', '<A-return>', '<CMD>lua wrapped_slime()<CR><CR>')

-- }}} Slime

-- {{{ Other.nvim
mymap('n', '<Space>oo', '<CMD>Other<CR>')
-- }}} Other.nvim

-- }}} Plugin mappings

-- {{{ Statusline active/not_active behavior

-- vim.cmd('highlight StatusLineNC guifg=#888888 guibg=#DFDFF1')     --  guibg=#000000'Inactive buffer colors
vim.cmd('highlight StatusLine guifg=#FF33FF guibg=#00FFFFBB') -- Active buffer colors
vim.cmd('highlight StatusLineNC guifg=#888888 guibg=#88888888') --  guibg=#000000'Inactive buffer colors
vim.cmd('highlight StatusLineActive guifg=#FF33FF guibg=#003366') -- Different color for active buffer
vim.cmd('highlight WinSeparatorActive guifg=#FF33FF') -- Color for active window separator
vim.cmd('highlight WinSeparatorNC guifg=#444444') -- Color for inactive window separators

-- Function to update all status lines and separators
function UpdateAll()
  local current_win = vim.api.nvim_get_current_win()

  vim.cmd('highlight StatusLine guifg=#FF33FF guibg=#00FFFFBB') -- Active buffer colors
  vim.cmd('highlight StatusLineNC guifg=#888888 guibg=#88888888') --  guibg=#000000'Inactive buffer colors
  vim.cmd('highlight StatusLineActive guifg=#FF33FF guibg=#003366') -- Different color for active buffer
  vim.cmd('highlight WinSeparatorActive guifg=#FF33FF') -- Color for active window separator
  vim.cmd('highlight WinSeparatorNC guifg=#444444') -- Color for inactive window separators

  -- Update status line colors
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- local width = vim.fn.winwidth(win)
    -- local status_line = string.rep("─", width)
    -- Update the status line based on window focus
    if win == current_win then
      -- vim.api.nvim_set_option_value('statusline', '%#StatusLineActive#' .. status_line, { win = win })
      vim.api.nvim_set_option_value('winhighlight', 'WinSeparator:WinSeparatorActive', { win = win })
    else
      -- vim.api.nvim_set_option_value('statusline', '%#StatusLineNC#' .. status_line, { win = win })
      vim.api.nvim_set_option_value('winhighlight', 'WinSeparator:WinSeparatorNC', { win = win })
    end
  end
end

-- Autocommand to refresh status lines and separators on resize
vim.api.nvim_create_autocmd('VimResized', { callback = UpdateAll })
-- Autocommand to update status lines and separators on window focus changes
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, { callback = UpdateAll })
vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, { callback = UpdateAll })

-- Initial setup to set status lines and separators for all windows
UpdateAll()

vim.cmd('highlight EndOfBuffer guifg=#881188') -- Customize color as needed

-- }}} Statusline active/not_active behavior

-- {{{ inbox

mymap('n', '<Space><Space>', ':JustSelect<CR>')
vim.api.nvim_create_user_command('RunJust', function()
  local file = vim.fn.expand('%:p')
  local filename = vim.fn.fnamemodify(file, ':t')
  local example_name = filename:gsub('^prefix_cpp_', ''):gsub('%.cpp$', '')
  local args = string.format('run example %s_cpp', example_name)

  -- Run the command asynchronously
  vim.cmd('AsyncRun just ' .. args)

  -- Check if copen is already open
  if vim.fn.getqflist({ winid = 0 }).winid == 0 then
    -- Store the current window id
    local current_window = vim.fn.win_getid()
    vim.cmd('copen') -- Open quickfix window

    -- Function to go back to original window after entering quickfix
    vim.cmd('autocmd! BufLeave quickfix lua vim.fn.win_gotoid(' .. current_window .. ')')
  end
end, {})

-- Associate .Rmd files with markdown filetype
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.Rmd', '*.rmd' },
  callback = function()
    vim.opt.filetype = 'markdown'
  end,
})

mymap('n', '<Space>sp', '<CMD>split<CR>')

-- }}} inbox
