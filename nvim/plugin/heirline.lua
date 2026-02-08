-- https://github.com/rebelot/heirline.nvim

-- local mycolors = require 'user.misenplacecolors.colors'

-- {{{ utilities

local ju = {}
local utils = require('heirline.utils')
-- utilities = {}

ju.has_wal = function()
  if vim.fn.executable('wal') == 1 then
    return true
  else
    return false
  end
end

--- Check if a file or directory exists in this path
ju.exists = function(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
end

--- Check if a directory exists in this path
ju.isdir = function(path)
  -- "/" works on both Unix and Windows
  return ju.exists(path .. '/')
end

ju.start_fortran_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/fortran-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/fortran-scratchpad/scratchpad.f90')
  end
  vim.cmd('sp')
  vim.cmd('BuildMe')
  vim.cmd('wincmd k')
  -- vim.cmd 'sp'
  -- vim.cmd 'terminal cmake . -B ./build/ & ./build/make & ./build/scratchpad'
  -- vim.cmd 'wincmd k'
end

ju.start_r_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/r-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/r-scratchpad/scratchpad.r')
  end
  vim.cmd('sp')
  vim.cmd('terminal R')
  vim.cmd('wincmd k')
end

ju.start_python_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/python-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/python-scratchpad/scratchpad.py')
  end
  vim.cmd('sp')
  vim.cmd('terminal python')
  vim.cmd('wincmd k')
end

ju.start_haskell_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/haskell-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/haskell-scratchpad/scratchpad.hs')
  end
  vim.cmd('sp')
  vim.cmd('terminal ghc --interactive')
  vim.cmd('wincmd k')
end

ju.start_c_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/c-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/c-scratchpad/examples/scratchpad.c')
  end
  vim.cmd('sp')
  vim.cmd('BuildMe')
  vim.cmd('wincmd k')
end

ju.start_cpp_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/cpp-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/cpp-scratchpad/examples/scratchpad.cpp')
  end
  vim.cmd('sp')
  vim.cmd('BuildMe')
  vim.cmd('wincmd k')
end

ju.start_bash_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/bash-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/bash-scratchpad/scratchpad.sh')
  end
  vim.cmd('sp')
  vim.cmd('terminal')
  vim.cmd('wincmd k')
end

ju.start_java_scratchpad = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/java-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/java-scratchpad/examples/src/main/java/templatejava/examples/ScratchPad.java')
  end
  vim.cmd('sp')
  vim.cmd('BuildMe')
  vim.cmd('wincmd k')
end

ju.run_java_main = function()
  vim.cmd('wincmd o')
  if ju.isdir('/home/jordan/scratchpads/java-scratchpad/') then
    vim.cmd('e /home/jordan/scratchpads/java-scratchpad/examples/src/main/java/templatejava/examples/ScratchPad.java')
  end
  vim.cmd('sp')
  vim.cmd('BuildMe')
  vim.cmd('wincmd k')
end

-- ju.start_r_project()

ju.dump = function(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. ju.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

ju.get_active_buffer_in_tab = function(tab_number)
  -- Set the specified tabpage as the current tab
  vim.cmd('tabnext ' .. tab_number)

  -- Get the current window in the specified tab
  local current_win = vim.api.nvim_get_current_win()

  -- Get the active buffer handle from the current window
  local active_buffer = vim.api.nvim_win_get_buf(current_win)

  return active_buffer
end

ju.move_current_tab_to_next_position = function()
  local current_tabpage = vim.fn.tabpagenr()

  if current_tabpage > 1 then
    local current_win = vim.api.nvim_tabpage_get_win(current_tabpage)
    local total_tabpages = vim.fn.tabpagenr('$')

    -- Check if the current tabpage is not the last one
    if current_tabpage < total_tabpages then
      local next_tabpage = current_tabpage + 1

      -- Move the current tab to the next position
      vim.cmd('tabmove ' .. next_tabpage)
    else
      print('Current tab is already in the last position.')
    end
  else
    print('Current tab is already in the first position.')
  end
end

-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
ju.file_exists = function(file)
  local f = io.open(file, 'rb')
  if f then
    f:close()
  end
  return f ~= nil
end

-- local lfs = require 'lfs'
-- local function file_exists(filename)
--   local attributes, _ = lfs.attributes(filename)
--   if attributes then
--     return true
--   else
--     return false
--   end
-- end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
ju.lines_from = function(file)
  if not ju.file_exists(file) then
    return {}
  end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

ju.waldark_toggle = function()
  io.popen('waldark')
end

ju.waldark_dark = function()
  io.popen('waldark --dark')
end

ju.waldark_light = function()
  io.popen('waldark --light')
end

-- Function to get a list of fold levels and their start and end lines
ju.get_fold_list = function()
  local fold_levels = {}
  local current_fold = {}
  local line_number = 1

  while true do
    local fold_info = vim.fn.nvim_foldlevel(line_number)

    if fold_info == -1 then
      break
    end

    if fold_info > current_fold.level then
      table.insert(current_fold, line_number)
    elseif fold_info < current_fold.level then
      current_fold.end_line = line_number - 1
      table.insert(fold_levels, current_fold)
      current_fold = {}
      table.insert(current_fold, line_number)
    end

    current_fold.level = fold_info
    line_number = line_number + 1
  end

  -- Add the last fold (if any)
  if current_fold.level ~= nil then
    current_fold.end_line = line_number - 1
    table.insert(fold_levels, current_fold)
  end

  return fold_levels
end

ju.toggle_neogit = function()
  local bufname = 'NeogitStatus'
  local buf_exists = vim.fn.bufexists(vim.fn.bufnr(bufname))
  if buf_exists == 1 then
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
      local buf_nr = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.fn.bufname(buf_nr)
      if buf_name == bufname then
        vim.api.nvim_set_current_win(win)
        vim.cmd('q')
        return
      end
    end
  else
    vim.cmd('Neogit kind=vsplit')
  end
end

ju.toggle_todo = function()
  local bufname = 'Trouble'
  local buf_exists = vim.fn.bufexists(vim.fn.bufnr(bufname))
  if buf_exists == 1 then
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
      local buf_nr = vim.api.nvim_win_get_buf(win)
      local buf_name = vim.fn.bufname(buf_nr)
      if buf_name == bufname then
        print('Trouble buffer exists!')
        vim.api.nvim_set_current_win(win)
        vim.cmd('q')
        return
      end
    end
  else
    vim.cmd('Trouble todo')
  end
end

-- }}} utilities

-- {{{ Colors
---@class PaletteColors
local mycolors = {

  -- Whites
  pastelSnow = '#fff7f7', -- #fff7f7 Pantone 182C

  -- Reds
  trackAndField = '#d71010', -- Pantone 186C

  -- Greens
  pastelOliveCreed = '#e5edc4', -- #e5edc4 Pantone 2309C
  energos = '#cded49', -- #cded49 Pantone 380C
  jazzercise = '#bde225', --#bde225 Pantone 2290C
  indiaGreen = '#1c890a', -- Pantone 2424C
  appleIiLime = '#28d10c', -- Pantone

  -- Greys
  pigIron = '#484747',

  -- Blacks
  midnightBlack = '#000000', -- Pantone Black 3c
  underworld = '#1f211c', -- Pantone Black 3c
  velvetBlack = '#1d1818', -- Pantone Neutral Black C

  -- Yellows
  sizzlingSunrise = '#fedb00', -- Pantone 108C

  -- Blues
  pastelFirstSnow = '#e2ebf7', -- #e2ebf7 Pantone 2707C
  vibrantMint = '#02fce3',
  bluePartyParrot = '#7b7eff', -- Pantone 292C
  palatinateBlue = '#3845df', -- Pantone 2727C

  -- Oranges
  lightSalmon = '#ffa47b', -- #ffa47b Pantone 7410C
  phillipineOrange = '#ff7300',

  -- Browns
  moussaka = '#6f3014', -- Pantone 732C
  donJuan = '#594e4e', -- Pantone 411C
  matterhorn = '#574e4e', -- Pantone 411C
  chinotto = '#564949', -- Pantone 438C
  rhodoniteBrown = '#4c4141', -- Pantone 438C
  smokedBlackCoffee = '#3e3333', -- Pantone 439C
  chocolatePlum = '#3c2e2e', -- #3c2e2e Pantone 440C

  -- Pinks
  munchOnMelon = '#f23f72', -- Pantone 191C
  crumblyLipstick = '#ef6abf', -- Pantone 224C

  -- Purples
  plasmaTrail = '#cd95fa', -- Pantone 2717 C
  crashPink = '#cd88fd', -- #cd88fd Pantone 2717C
  piscesVividAmethyst = '#a753ec', -- Pantone 265C
  veronica = '#9715ff', -- Pantone 2592C
  eineKleineNachtmusik = '#4f1f91', -- Pantone 267C
  middleRedPurple = '#230839', -- Pantone 2627 C
}

-- }}} Colors

-- 󰫈󰨔󰧞󰧟󰦥󰝦󰝥󰝴󰜏󰚀󰗮󰕮󰕰󰕴󰕳
-- 󰧞󰧟󰦥󰝦󰝥
--                󰄯 󰄰 󰄱 󰎍 󰏝 󰑊 󰐾
local Tabpage = {
  provider = function(self)
    if not self.is_active then
      return '%' .. self.tabnr .. 'T ' .. '%T'
    else
      return '%' .. self.tabnr .. 'T ' .. '%T'
    end
  end,

  -- provider = function(self)
  --   if not self.is_active then
  --     return "%" .. self.tabnr .. "T " .. " " .. " %T"
  --   else
  --     return "%" .. self.tabnr .. "T " .. " " .. " %T"
  --   end
  -- end,

  -- provider = function(self)
  --     if not self.is_active then
  --         return " "
  --     else
  --         return " "
  --     end
  -- end,

  -- on_click = {
  --   callback = function(self)
  --     vim.cmd('tabn ' .. self.tabpage)
  --   end,
  --   name = 'Tabpage',
  -- },

  hl = function(self)
    return 'TabLine'
    -- if not self.is_active then
    --     return "TabLine"
    -- else
    --     return "TabLineSel"
    -- end
  end,
}

local TabpageClose = {
  provider = ' x ', -- what format is this?
  on_click = {
    callback = function()
      vim.cmd('tabc')
    end,
    name = 'TabpageClose',
  },
  hl = 'TabLine',
}

local TabpageNew = {
  provider = ' + ', -- what format is this?
  on_click = {
    callback = function()
      vim.cmd('tabnew')
    end,
    name = 'TabpageNew',
  },
  hl = 'TabLine',
}

local TabPages = {
  -- only show this component if there's 2 or more tabpages
  -- condition = function()
  --     return #vim.api.nvim_list_tabpages() >= 2
  -- end,
  { provider = '' }, -- %=
  utils.make_tablist(Tabpage),
  TabpageNew,
  TabpageClose,
}

local function get_window_with_cursor_in_tab(tabpage_number)
  local current_tabpage = vim.fn.tabpagenr()
  local original_tabpage = current_tabpage
  local windows = vim.fn.gettabwininfo(tabpage_number)
  local current_window = -1
  for _, win in ipairs(windows) do
    if win.winnr == vim.fn.winnr() then
      current_window = win.winnr
      break
    end
  end
  vim.fn.settabwin(original_tabpage)
  return current_window
end

function get_buffer_with_cursor_in_tab(tabpage_number)
  local original_tabpage = vim.fn.tabpagenr()
  local tab_count = vim.fn.tabpagenr('$')

  if tabpage_number < 1 or tabpage_number > tab_count then
    return -1
  end

  local winnr_before = vim.fn.winnr()
  vim.cmd('tabnext ' .. tabpage_number)
  local winnr_after = vim.fn.winnr()

  if winnr_before == winnr_after then
    vim.cmd('tabnext ' .. original_tabpage)
    return -1
  end

  local current_buffer = vim.fn.bufnr('#')

  vim.cmd('tabnext ' .. original_tabpage)
  return current_buffer
end

local function filepath_to_filename(filepath)
  if filepath == nil then
    return nil
  end
  local separator = package.config:sub(1, 1) -- Get the platform-specific directory separator
  local parts = {}

  for part in string.gmatch(filepath, '[^' .. separator .. ']+') do
    table.insert(parts, part)
  end

  return parts[#parts] -- Return the last part (the filename)
end

local function get_active_buffer_in_tabpage(tabpage_handle)
  -- Get the current window handle in the specified tabpage
  local current_win = vim.fn.win_getid(tabpage_handle)

  if current_win == -1 then
    -- Tab not found or tab is empty
    return nil
  end

  -- Get the buffer handle associated with the current window
  local active_buffer = vim.fn.winbufnr(current_win)

  return active_buffer
end

local function bufs_in_tab(tabpage)
  tabpage = tabpage or 0
  local buf_set = {}
  -- local win = get_window_with_cursor_in_tab(tabpage)
  -- -- local success, win = pcall(get_window_with_cursor_in_tab, tabpage)
  -- -- if success then
  --   local bufnr = get_buffer_with_cursor_in_tab(tabpage)
  --   -- local bufnr = vim.api.nvim_win_get_buf(win)
  --   buf_set[bufnr] = true
  --   return buf_set
  -- -- else
  -- --   return { 1 }
  -- -- end

  local success, wins = pcall(vim.api.nvim_tabpage_list_wins, tabpage)
  -- local success, wins = pcall(vim.fn.tabpagewinnr, tabpage)
  -- if success then
  --   return vim.api.nvim_win_get_buf(wins)

  -- if success then
  --     local bufnr = get_active_buffer_in_tabpage(tabpage)
  --     buf_set[bufnr] = true
  --     return buf_set
  if success then
    for _, winid in ipairs(wins) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      buf_set[bufnr] = true
    end
    return buf_set
  else
    return { 1 }
  end
end

-- local function get_active_buffer_in_tab(tab_number)
--   -- Set the specified tabpage as the current tab
--   local current_tab = vim.fn.tabpagenr()
--   vim.cmd('tabnext ' .. tab_number)
--
--   -- Get the current window in the specified tab
--   local current_win = vim.api.nvim_get_current_win()
--
--   -- Get the active buffer handle from the current window
--   local active_buffer = vim.api.nvim_win_get_buf(current_win)
--
--   vim.cmd('tabnext ' .. current_tab)
--   return active_buffer
-- end

local function get_active_buffer_in_tab(tab_number)
  -- Get the current window handle in the specified tab
  local current_win = vim.fn.tabpagewinnr(tab_number)

  if current_win == -1 then
    -- Tab not found or tab is empty
    return nil
  end

  -- Get the buffer handle associated with the current window
  local active_buffer = vim.fn.winbufnr(current_win)

  return active_buffer
end

function get_first_key(table)
  for key, _ in pairs(table) do
    return key
  end
end

local conditions = require('heirline.conditions')
local utils = require('heirline.utils')

-- {{{ Colors
local colors = {
  -- pylogo_bg = utils.get_highlight("PyLogo").bg,
  -- pylogo_fg = utils.get_highlight("PyLogo").fg,
  js_logo_bg = utils.get_highlight('JSLogo').bg,
  js_logo_fg = utils.get_highlight('JSLogo').fg,
  pylogo_bg = utils.get_highlight('PyLogo').bg,
  pylogo_fg = utils.get_highlight('PyLogo').fg,
  shell_logo_bg = utils.get_highlight('ShellLogo').bg,
  shell_logo_fg = utils.get_highlight('ShellLogo').fg,
  -- bright_bg = utils.get_highlight("Folded").bg,
  button_bg = utils.get_highlight('Folded').bg,
  lightdark_fg = utils.get_highlight('Normal').fg,
  lightdark_bg = utils.get_highlight('StatusLine').bg,
  statusline_bg = utils.get_highlight('StatusLine').bg,
  -- bright_fg = utils.get_highlight("Folded").fg,
  -- button_bg = utils.get_highlight("TabLineSel").fg,
  bright_bg = utils.get_highlight('NonText').fg,
  bright_fg = utils.get_highlight('NonText').fg,
  red = utils.get_highlight('DiagnosticError').fg,
  dark_red = utils.get_highlight('DiffDelete').bg,
  green = utils.get_highlight('String').fg,
  blue = utils.get_highlight('Function').fg,
  gray = utils.get_highlight('NonText').fg,
  orange = utils.get_highlight('Constant').fg,
  purple = utils.get_highlight('Statement').fg,
  cyan = utils.get_highlight('Special').fg,
  diag_warn = utils.get_highlight('DiagnosticWarn').fg,
  diag_error = utils.get_highlight('DiagnosticError').fg,
  diag_hint = utils.get_highlight('DiagnosticHint').fg,
  diag_info = utils.get_highlight('DiagnosticInfo').fg,
  git_del = utils.get_highlight('diffDeleted').fg,
  git_add = utils.get_highlight('diffAdded').fg,
  git_change = utils.get_highlight('diffChanged').fg,
}

local function setup_colors()
  return {
    -- bright_bg = utils.get_highlight("Folded").bg,
    -- bright_fg = utils.get_highlight("Folded").fg,
    bright_bg = utils.get_highlight('NonText').fg,
    bright_fg = utils.get_highlight('NonText').fg,
    red = utils.get_highlight('DiagnosticError').fg,
    dark_red = utils.get_highlight('DiffDelete').bg,
    green = utils.get_highlight('String').fg,
    blue = utils.get_highlight('Function').fg,
    gray = utils.get_highlight('NonText').fg,
    orange = utils.get_highlight('Constant').fg,
    purple = utils.get_highlight('Statement').fg,
    cyan = utils.get_highlight('Special').fg,
    diag_warn = utils.get_highlight('DiagnosticWarn').fg,
    diag_error = utils.get_highlight('DiagnosticError').fg,
    diag_hint = utils.get_highlight('DiagnosticHint').fg,
    diag_info = utils.get_highlight('DiagnosticInfo').fg,
    git_del = utils.get_highlight('diffDeleted').fg,
    git_add = utils.get_highlight('diffAdded').fg,
    git_change = utils.get_highlight('diffChanged').fg,
  }
end

-- }}} Colors

-- {{{ Autos

vim.api.nvim_create_augroup('Heirline', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    utils.on_colorscheme(setup_colors)
  end,
  group = 'Heirline',
})

-- }}} Autos

--- {{{ Components

-- {{{ Bufferline

local TablineBufnr = {
  provider = function(self)
    return tostring(self.bufnr) .. '. '
  end,
  hl = 'Comment',
}

-- -- we redefine the filename component, as we probably only want the tail and not the relative path
local TablineFileName = {
  provider = function(self)
    -- self.filename will be defined later, just keep looking at the example!
    local filename = self.filename
    filename = filename == '' and '[No Name]' or vim.fn.fnamemodify(filename, ':t')
    return filename
  end,
  hl = function(self)
    return { bold = self.is_active or self.is_visible, italic = true }
  end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
local TablineFileFlags = {
  {
    condition = function(self)
      return vim.api.nvim_buf_get_option(self.bufnr, 'modified')
    end,
    provider = '[+]',
    hl = { fg = 'green' },
  },
  {
    condition = function(self)
      return not vim.api.nvim_buf_get_option(self.bufnr, 'modifiable')
        or vim.api.nvim_buf_get_option(self.bufnr, 'readonly')
    end,
    provider = function(self)
      if vim.api.nvim_buf_get_option(self.bufnr, 'buftype') == 'terminal' then
        return '  '
      else
        return ''
      end
    end,
    hl = { fg = 'orange' },
  },
}

-- Here the filename block finally comes together
local TablineFileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
  end,
  hl = function(self)
    if self.is_active then
      return 'TabLineSel'
      -- why not?
      -- elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
      --     return { fg = "gray" }
    else
      return 'TabLine'
    end
  end,
  on_click = {
    callback = function(_, minwid, _, button)
      if button == 'm' then -- close on mouse middle click
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = 'heirline_tabline_buffer_callback',
  },
  TablineBufnr,
  FileIcon, -- turns out the version defined in #crash-course-part-ii-filename-and-friends can be reutilized as is here!
  TablineFileName,
  TablineFileFlags,
}

-- a nice "x" button to close the buffer
local TablineCloseButton = {
  condition = function(self)
    return not vim.api.nvim_buf_get_option(self.bufnr, 'modified')
  end,
  { provider = ' ' },
  {
    provider = '',
    hl = { fg = 'gray' },
    on_click = {
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
          vim.cmd.redrawtabline()
        end)
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = 'heirline_tabline_close_buffer_callback',
    },
  },
}

-- The final touch!
local TablineBufferBlock = utils.surround({ '', '' }, function(self)
  if self.is_active then
    return utils.get_highlight('TabLineSel').bg
  else
    return utils.get_highlight('TabLine').bg
  end
end, { TablineFileNameBlock, TablineCloseButton })

-- and here we go
local BufferLine = utils.make_buflist(
  TablineBufferBlock,
  { provider = '', hl = { fg = 'gray' } }, -- left truncation, optional (defaults to "<")
  { provider = '', hl = { fg = 'gray' } } -- right trunctation, also optional (defaults to ...... yep, ">")
  -- by the way, open a lot of buffers and try clicking them ;)
)

-- }}} Bufferline

-- {{{ Diagnostics

local Diagnostics = {

  on_click = {
    callback = function()
      vim.cmd('TroubleToggle')
    end,
    name = 'Trouble',
  },

  condition = conditions.has_diagnostics,
  static = {
    error_icon = '', -- vim.fn.sign_getdefined('DiagnosticSignError')[1].text,
    warn_icon = '', -- vim.fn.sign_getdefined('DiagnosticSignWarn')[1].text,
    info_icon = '', -- vim.fn.sign_getdefined('DiagnosticSignInfo')[1].text,
    hint_icon = '', -- vim.fn.sign_getdefined('DiagnosticSignHint')[1].text,
  },

  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,

  update = { 'DiagnosticChanged', 'BufEnter' },

  {
    provider = '![',
  },
  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      return self.errors > 0 and (self.error_icon .. self.errors .. ' ')
    end,
    hl = { fg = 'diag_error', bold = true },
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. ' ')
    end,
    hl = { fg = 'diag_warn', bold = true },
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. ' ')
    end,
    hl = { fg = 'diag_info', bold = true },
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = { fg = 'diag_hint', bold = true },
  },
  {
    provider = ']',
  },
}

-- }}} Diagnostics

-- {{{ FileType

local FileType = {
  provider = function()
    return string.upper(vim.bo.filetype)
  end,
  hl = { fg = utils.get_highlight('Type').fg, bold = true },
}

-- }}} FileType

-- {{{ FileNameBlock
local FileNameBlock = {

  -- let's first set up some attributes needed by this component and it's children
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
}
-- We can now define some children separately and add them later

-- local FileIcon = {

--   on_click = {
--     callback = function() vim.cmd("AerialToggle") end,
--     name = "Trouble",
--   },
--   init = function(self)
--     local filename = self.filename
--     local extension = vim.fn.fnamemodify(filename, ':e')
--     self.icon, self.icon_color =
--         require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
--   end,
--   provider = function(self)
--     return self.icon and (self.icon .. ' ')
--   end,
--   hl = function(self)
--     return { fg = self.icon_color }
--   end,
-- }

local FileName = {

  on_click = {
    callback = function()
      vim.cmd('NvimTreeToggle')
    end,
    name = 'NvimTreeToggle',
  },

  provider = function(self)
    -- first, trim the pattern relative to the current directory. For other
    -- options, see :h filename-modifers
    local filename = vim.fn.fnamemodify(self.filename, ':.')
    if filename == '' then
      return '[No Name]'
    end
    -- now, if the filename would occupy more than 1/4th of the available
    -- space, we trim the file path to its initials
    -- See Flexible Components section below for dynamic truncation
    if not conditions.width_percent_below(#filename, 0.25) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
  -- hl = { fg = utils.get_highlight('Directory').fg },
  hl = { fg = '#ff0f00', bold = true },
}

local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = '[+]',
    hl = { fg = 'green' },
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = '',
    hl = { fg = 'orange' },
  },
}

-- Now, let's say that we want the filename color to change if the buffer is
-- modified. Of course, we could do that directly using the FileName.hl field,
-- but we'll see how easy it is to alter existing components using a "modifier"
-- component

local FileNameModifer = {
  hl = function()
    if vim.bo.modified then
      -- use `force` because we need to override the child's hl foreground
      return { fg = 'cyan', bold = true, force = true }
    end
  end,
}

-- let's add the children to our FileNameBlock component
FileNameBlock = utils.insert(
  FileNameBlock,
  -- FileIcon,
  utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
  FileFlags,
  { provider = '%<' } -- this means that the statusline is cut here when there's not enough space
)

-- }}} FileNameBlock

-- {{{ Git
local Git = {

  on_click = {
    callback = function()
      require('neogit').open { kind = 'vsplit' }
    end, --
    name = 'neogit',
  },

  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,
  hl = { fg = 'orange', bold = true },

  { -- git branch name
    provider = function(self)
      return ' ' .. self.status_dict.head
    end,
    hl = { bold = true },
  },
  -- You could handle delimiters, icons and counts similar to Diagnostics
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = '(',
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ('+' .. count)
    end,
    hl = { fg = '#00dd00', bold = true },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ('-' .. count)
    end,
    hl = { fg = '#cc0000', bold = true },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ('~' .. count)
    end,
    hl = { fg = '#cccc00', bold = true },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = ')',
  },
}
-- }}} Git

-- {{{ HelpFileName
local HelpFileName = {
  condition = function()
    return vim.bo.filetype == 'help'
  end,
  provider = function()
    local filename = vim.api.nvim_buf_get_name(0)
    return vim.fn.fnamemodify(filename, ':t')
  end,
  hl = { fg = colors.blue },
}
-- }}} HelpFileName

-- {{{ LspActive

local LSPActive = {
  condition = conditions.lsp_attached,
  update = { 'LspAttach', 'LspDetach', 'BufEnter' },

  -- You can keep it simple,
  -- provider = " [LSP]",

  -- Or complicate things a bit and get the servers names
  provider = function()
    local names = {}
    for _, server in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
      table.insert(names, server.name)
    end
    return ' [' .. table.concat(names, ' ') .. ']'
  end,
  hl = { fg = '#404040', bold = true },
}

-- }}} LspActive

-- {{{ LSPMessages
-- I personally use it only to display progress messages!
-- See lsp-status/README.md for configuration options.

-- Note: check "j-hui/fidget.nvim" for a nice statusline-free alternative.
-- local LSPMessages = {
--   provider = require("lsp-status").status,
--   hl = { fg = "gray" },
-- }
-- }}} LSPMessages

-- {{{ Navic

-- Awesome plugin

-- The easy way.
-- local Navic = {
--   condition = function() return require("nvim-navic").is_available() end,
--   provider = function()
--     return require("nvim-navic").get_location({ highlight = true })
--   end,
--   update = 'CursorMoved'
-- }

-- -- Full nerd (with icon colors and clickable elements)!
-- -- works in multi window, but does not support flexible components (yet ...)
-- local Navic = {
--   condition = function() return require("nvim-navic").is_available() end,
--   static = {
--     -- create a type highlight map
--     type_hl = {
--       File = "Directory",
--       Module = "@include",
--       Namespace = "@namespace",
--       Package = "@include",
--       Class = "@structure",
--       Method = "@method",
--       Property = "@property",
--       Field = "@field",
--       Constructor = "@constructor",
--       Enum = "@field",
--       Interface = "@type",
--       Function = "@function",
--       Variable = "@variable",
--       Constant = "@constant",
--       String = "@string",
--       Number = "@number",
--       Boolean = "@boolean",
--       Array = "@field",
--       Object = "@type",
--       Key = "@keyword",
--       Null = "@comment",
--       EnumMember = "@field",
--       Struct = "@structure",
--       Event = "@keyword",
--       Operator = "@operator",
--       TypeParameter = "@type",
--     },
--     -- bit operation dark magic, see below...
--     enc = function(line, col, winnr)
--       return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
--     end,
--     -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
--     dec = function(c)
--       local line = bit.rshift(c, 16)
--       local col = bit.band(bit.rshift(c, 6), 1023)
--       local winnr = bit.band(c, 63)
--       return line, col, winnr
--     end
--   },
--   init = function(self)
--     local data = require("nvim-navic").get_data() or {}
--     local children = {}
--     -- create a child for each level
--     for i, d in ipairs(data) do
--       -- encode line and column numbers into a single integer
--       local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
--       local child = {
--         {
--           provider = d.icon,
--           hl = self.type_hl[d.type],
--         },
--         {
--           -- escape `%`s (elixir) and buggy default separators
--           provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ''),
--           -- highlight icon only or location name as well
--           -- hl = self.type_hl[d.type],

--           on_click = {
--             -- pass the encoded position through minwid
--             minwid = pos,
--             callback = function(_, minwid)
--               -- decode
--               local line, col, winnr = self.dec(minwid)
--               vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
--             end,
--             name = "heirline_navic",
--           },
--         },
--       }
--       -- add a separator only if needed
--       if #data > 1 and i < #data then
--         table.insert(child, {
--           provider = " > ",
--           hl = { fg = 'bright_fg' },
--         })
--       end
--       table.insert(children, child)
--     end
--     -- instantiate the new child, overwriting the previous one
--     self.child = self:new(children, 1)
--   end,
--   -- evaluate the children containing navic components
--   provider = function(self)
--     return self.child:eval()
--   end,
--   hl = { fg = "gray" },
--   update = 'CursorMoved'
-- }

-- }}} Navic

-- {{{ Ruler & ScrollBar

-- We're getting minimalists here!
local Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  -- provider = '%7(%l/%3L%):%2c %P',
  provider = '%l/%L',
}
-- I take no credits for this! :lion:
local ScrollBar = {
  static = {
    sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
    -- Another variant, because the more choice the better.
    -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = 'blue', bg = 'bright_bg' },
}

-- }}} Ruler & ScrollBar

-- {{{ Separator |
local Separator = {
  -- require('nvim-web-devicons').get_icon()
  provider = function()
    -- return "|"
    return '❘'
    -- return "⎞⎛"
    -- ⎞⎡⎛
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}
-- }}} Separator |

-- {{{ Separator |
local StatusLineSeparator = {
  -- require('nvim-web-devicons').get_icon()
  provider = function()
    -- return "|"
    return '❘'
    -- return "⎞⎛"
    -- ⎞⎡⎛
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}
-- }}} Separator |

-- {{{ Separator |

local CppSeparator = {
  condition = function()
    return vim.bo.filetype == 'cpp'
  end,
  provider = function()
    return '❘'
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}

local RSeparator = {
  condition = function()
    return vim.bo.filetype == 'r'
  end,
  provider = function()
    return '❘'
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}

-- }}} Separator |

-- {{{ Space
local Space = {
  -- require('nvim-web-devicons').get_icon()
  provider = function()
    return ' '
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}
-- }}} Space

-- {{{ Space
local StatusLineSpace = {
  -- require('nvim-web-devicons').get_icon()
  provider = function()
    return ' '
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}
-- }}} Space

-- {{{ Space
local StatusSpace = {
  -- require('nvim-web-devicons').get_icon()
  provider = function()
    return ' '
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}
-- }}} Space

-- {{{ Tabline offset
-- local TabLineOffset = {
--   condition = function(self)
--     local win = vim.api.nvim_tabpage_list_wins(0)[1]
--     local bufnr = vim.api.nvim_win_get_buf(win)
--     self.winid = win

--     if vim.bo[bufnr].filetype == "NvimTree" then
--       self.title = "NvimTree"
--       return true
--       -- elseif vim.bo[bufnr].filetype == "TagBar" then
--       --     ...
--     end
--   end,

--   provider = function(self)
--     local title = self.title
--     local width = vim.api.nvim_win_get_width(self.winid)
--     local pad = math.ceil((width - #title) / 2)
--     return string.rep(" ", pad) .. title .. string.rep(" ", pad)
--   end,

--   hl = function(self)
--     if vim.api.nvim_get_current_win() == self.winid then
--       return "TablineSel"
--     else
--       return "Tabline"
--     end
--   end,
-- }

-- }}} Tabline offset

-- {{{ Venv
-- local actived_venv = function()
--   local venv_name = require('venv-selector').get_active_venv()
--   if venv_name ~= nil then
--     if string.match(venv_name, 'conda') then
--       return string.gsub(venv_name, '/home/jordan/.conda/envs/', '(conda) ')
--     end
--     if string.match(venv_name, 'poetry') then
--       return string.gsub(venv_name, '.*/pypoetry/virtualenvs/', '(poetry) ')
--     end
--   else
--     return 'venv'
--   end
-- end

-- local venv = {
--   {
--     provider = function()
--       return '  [' .. actived_venv() .. '] '
--     end,
--   },
--   on_click = {
--     callback = function()
--       vim.cmd.VenvSelect()
--     end,
--     name = 'heirline_statusline_venv_selector',
--   },
-- }

-- }}} Venv

-- Vi Mode {{{

local ViMode = {
  -- get vim current mode, this information will be required by the provider
  -- and the highlight functions, so we compute it only once per component
  -- evaluation and store it as a component attribute
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()
  end,
  -- Now we define some dictionaries to map the output of mode() to the
  -- corresponding string and color. We can put these into `static` to compute
  -- them at initialisation time.
  static = {
    mode_names = { -- change the strings if you like it vvvvverbose!
      n = 'N',
      no = 'N?',
      nov = 'N?',
      noV = 'N?',
      ['no\22'] = 'N?',
      niI = 'Ni',
      niR = 'Nr',
      niV = 'Nv',
      nt = 'Nt',
      v = 'V',
      vs = 'Vs',
      V = 'V_',
      Vs = 'Vs',
      ['\22'] = '^V',
      ['\22s'] = '^V',
      s = 'S',
      S = 'S_',
      ['\19'] = '^S',
      i = 'I',
      ic = 'Ic',
      ix = 'Ix',
      R = 'R',
      Rc = 'Rc',
      Rx = 'Rx',
      Rv = 'Rv',
      Rvc = 'Rv',
      Rvx = 'Rv',
      c = 'C',
      cv = 'Ex',
      r = '...',
      rm = 'M',
      ['r?'] = '?',
      ['!'] = '!',
      t = 'T',
    },
    mode_colors = {
      n = 'red',
      i = 'green',
      v = 'cyan',
      V = 'cyan',
      ['\22'] = 'cyan',
      c = 'orange',
      s = 'purple',
      S = 'purple',
      ['\19'] = 'purple',
      R = 'orange',
      r = 'orange',
      ['!'] = 'red',
      t = 'red',
    },
  },
  -- We can now access the value of mode() that, by now, would have been
  -- computed by `init()` and use it to index our strings dictionary.
  -- note how `static` fields become just regular attributes once the
  -- component is instantiated.
  -- To be extra meticulous, we can also add some vim statusline syntax to
  -- control the padding and make sure our string is always at least 2
  -- characters long. Plus a nice Icon.
  provider = function(self)
    return '%2(' .. self.mode_names[self.mode] .. '%)'
  end,
  -- Same goes for the highlight. Now the foreground will change according to the current mode.
  hl = function(self)
    local mode = self.mode:sub(1, 1) -- get only the first mode character
    return { fg = self.mode_colors[mode], bold = true }
  end,
  -- Re-evaluate the component only on ModeChanged event!
  -- Also allows the statusline to be re-evaluated when entering operator-pending mode
  update = {
    'ModeChanged',
    pattern = '*:*',
    callback = vim.schedule_wrap(function()
      vim.cmd('redrawstatus')
    end),
  },
}

-- Vi Mode }}}

local Align = { provider = '%=' }

local actionHints = {
  provider = require('lsp-progress').progress, -- require("action-hints").statusline()
}

--- }}} Components

-- {{{ Buttons
-- 󰒪󰟔
-- 
-- │󱫫󱫤󱫡󱫐󱫠󱫪󱫬󱧡󱕱󱕜󱎯󱊡󱊢󱊣󱊤󱊥󱊦󱇪󱅥󰳤󰳦󰦐󰟔󰃤󰄵
-- ◍󰂒󰂓󰂛󰂜󰂞󰂠󰂟󰃛󰃞󰃟󰅏󰅎󱇪󱏵󱏴󱏶󱏷󱪼
-- 󰄲󰄵󰆚󰈞󰓥󰘧󰨰󰬯󰮗󰺛󱁍󱍢󱎎󱎴󱐌󱐋󱝁󱜿󱜙󱢺󱢴󱣓󱣒󱣻󱤎
-- 󰴭
-- 󰀦󰀨󰀩❘❘
-- 
-- 
-- 󰔦󰕃󰔦󰡟󰺛󰴭
-- 󰎦󰎧󰎩󰎪󰎬󰎭󰎮󰎪󰎰󰎱󰎳󰎵󰎶󰎸󰎹󰎻󰎼󰎾󰎡󰎣󰛦󰟟󰧑󰦌󰬯󰯻󰯺󰻕󰻖󱀇󱍢󱑷󱓞󱓟󱗃󱢴󱢊󱢋󱩡󱩲󱨚

-- {{{ AI BUtton 󰅏

local AIButton = {
  on_click = {
    callback = function()
      vim.cmd('CodeCompanionChat')
    end,
    name = 'AIButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󰅏' -- 
  end,
  hl = function()
    return { fg = mycolors.appleIiLime, underline = false }
  end,
}

-- }}} AIButton

-- {{{ aerial button 󰒪

local AerialToggleButton = {
  on_click = {
    callback = function()
      vim.cmd('AerialToggle')
    end,
    name = 'AerialToggleButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󰒪' -- 
  end,
  hl = function()
    return { fg = mycolors.appleIiLime, underline = false }
  end,
}

-- }}} aerial button

-- {{{ TelescopeButton 

local TelescopeButton = {
  on_click = {
    callback = function()
      vim.cmd('Telescope')
    end,
    name = 'TelescopeButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '' -- 
  end,
  hl = function()
    return { fg = mycolors.appleIiLime, underline = false }
  end,
}

-- }}} PlayButton 

-- {{{ FileSearchButton 󰈞

local FileSearchButton = {
  on_click = {
    callback = function()
      vim.cmd('Telescope find_files')
    end,
    name = 'FileSearchButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󰈞'
  end,
  hl = function()
    return { fg = mycolors.appleIiLime, underline = false }
  end,
}

-- }}} PlayButton 

-- {{{ PlayButtons 

-- {{{ cpp playbutton
local CppPlayButton = {
  -- { CppSeparator },
  -- require('nvim-web-devicons').get_icon()
  condition = function()
    return conditions.buffer_matches {
      filetype = { 'cpp', 'c' },
    }
  end,
  on_click = {
    callback = function()
      vim.cmd('RunJust')
    end,
    name = 'PlayButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.appleIiLime, underline = true }
  end,
}

-- }}} cpp playbutton

-- {{{ cpp playbutton
local RPlayButton = {
  -- { CppSeparator },
  -- require('nvim-web-devicons').get_icon()
  condition = function()
    return conditions.buffer_matches {
      filetype = { 'r', 'R' },
    }
  end,
  on_click = {
    callback = function()
      vim.cmd('AsyncRun Rscript %')
      -- Check if copen is already open
      if vim.fn.getqflist({ winid = 0 }).winid == 0 then
        -- Store the current window id
        local current_window = vim.fn.win_getid()
        vim.cmd('copen') -- Open quickfix window
        -- Function to go back to original window after entering quickfix
        vim.cmd('autocmd! BufLeave quickfix lua vim.fn.win_gotoid(' .. current_window .. ')')
      end
    end,
    name = 'RPlayButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.appleIiLime, underline = true }
  end,
}

-- }}} cpp playbutton

-- }}} PlayButtons 

-- {{{ JumpIntoButton 
local JumpIntoButton = {
  -- require('nvim-web-devicons').get_icon()

  condition = function()
    return conditions.buffer_matches {
      filetype = { 'cpp', 'c' },
    }
  end,
  on_click = {
    callback = function()
      -- vim.print('hello worldzzzz')
      vim.cmd('RunJust')
    end,
    name = 'JumpIntoButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.vibrantMint, underline = false }
  end,
}

-- }}} PlayButton 

-- {{{ JumpIntoButton 

local JumpOutOfButton = {

  condition = function()
    return conditions.buffer_matches {
      filetype = { 'cpp', 'c' },
    }
  end,

  on_click = {
    callback = function()
      vim.cmd('RunJust')
    end,
    name = 'JumpOutOfButton',
  },

  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,

  provider = function()
    return ''
  end,

  hl = function()
    return { fg = mycolors.vibrantMint, underline = false }
  end,
}

-- }}} PlayButton 

-- {{{ ContinueButton 

local ContinueButton = {
  condition = function()
    return conditions.buffer_matches {
      filetype = { 'cpp', 'c' },
    }
  end,

  on_click = {
    callback = function()
      vim.cmd('RunJust')
    end,
    name = 'ContinueButton',
  },

  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,

  provider = function()
    return ''
  end,

  hl = function()
    return { fg = mycolors.appleIiLime, underline = false }
  end,
}

-- }}} ContinueButton 

-- {{{ PauseButton 

local PauseButton = {

  condition = function()
    return conditions.buffer_matches {
      filetype = { 'cpp', 'c' },
    }
  end,

  on_click = {
    callback = function()
      vim.cmd('RunJust')
    end,
    name = 'PauseButton',
  },

  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,

  provider = function()
    return ''
  end,

  hl = function()
    return { fg = mycolors.trackAndField, underline = false }
  end,
}

-- }}} ContinueButton 

-- {{{ ResartButton 

local RestartButton = {

  condition = function()
    return conditions.buffer_matches {
      filetype = { 'cpp', 'c' },
    }
  end,

  on_click = {
    callback = function()
      vim.cmd('RunJust')
    end,
    name = 'RestartButton',
  },

  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,

  provider = function()
    return ''
  end,

  hl = function()
    return { fg = mycolors.sizzlingSunrise, underline = false }
  end,
}

-- }}} ContinueButton 

-- {{{ CloseButton 

local CloseButton = {
  on_click = {
    callback = function()
      vim.cmd('wincmd q')
    end,
    name = 'CloseButton',
  },

  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,

  provider = function()
    return ''
  end,

  hl = function()
    return { fg = mycolors.sizzlingSunrise, underline = true }
  end,
}

-- }}} ContinueButton 

-- 󰐕󰤃󱄅

-- {{{ Split 

local SplitButton = {
  on_click = {
    callback = function()
      vim.cmd('split')
    end,
    name = 'SplitButton',
  },

  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,

  provider = function()
    return ''
  end,

  hl = function()
    return { fg = mycolors.sizzlingSunrise, underline = true }
  end,
}

-- }}} ContinueButton 

-- {{{ VSplit 

local VSplitButton = {
  on_click = {
    callback = function()
      vim.cmd('vsplit')
    end,
    name = 'VSplitButton',
  },

  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,

  provider = function()
    return '󰤃'
  end,

  hl = function()
    return { fg = mycolors.sizzlingSunrise, underline = true }
  end,
}

-- }}} ContinueButton 

-- {{{ CPPButton 
local CPPButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_cpp_scratchpad()
    end,
    name = 'CPPButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    return { fg = mycolors.bluePartyParrot, underline = true }
  end,
}
-- }}} CPPButton 

-- {{{ CButton 
local CButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_c_scratchpad()
    end,
    name = 'CButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    return { fg = mycolors.bluePartyParrot, underline = true }
  end,
}
-- }}} CButton 

-- {{{ DebugButton 
local DebugButton = { -- 󰃤
  -- require('nvim-web-devicons').get_icon()
  condition = function()
    return conditions.buffer_matches {
      filetype = { 'cpp', 'c' },
    }
  end,
  on_click = {
    callback = function()
      require('dapui').toggle()
    end,
    name = 'dapui',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    -- return ""
    return ''
  end,
  hl = function()
    return { fg = mycolors.appleIiLime, underline = true }
  end,
}
-- }}} DebugButton 󰃤

-- {{{ FileTreeButton 
local FileTreeButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('NvimTreeToggle')
    end,
    name = 'FileTreeButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.bluePartyParrot, underline = true }
  end,
}
-- }}} FileTreeButton 

-- {{{ Fortran Button 󰯺
local FortranButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_fortran_scratchpad()
    end,
    name = 'FortranButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󰯺'
    -- 󰯺
  end,
  hl = function()
    -- return { fg = colors.bluePartyParrot, bg = colors.button_bg, underline = false, bold = true }
    return { fg = '#aa00ff', underline = true, bold = true }
  end,
}
-- }}} FortranButton 󰯺

-- {{{ GitButton 
local GitButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.toggle_neogit()
      -- vim.cmd 'Neogit kind=vsplit'
    end,
    name = 'git',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
    -- 󰊢
  end,
  hl = function()
    return { fg = mycolors.phillipineOrange, underline = true }
  end,
}
-- }}} GitButton 󰊢

-- {{{ GithubButton 
local GithubButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('e ~/.config/nvim/README.md')
    end,
    name = 'settingsbutton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- return ""
  end,
  hl = function()
    return { fg = mycolors.trackAndField, underline = true }
  end,
}
-- }}} GithubButton 

-- {{{ GoButton 
local GoButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_cpp_scratchpad()
    end,
    name = 'GoButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    -- return { fg = colors.bluePartyParrot, bg = colors.button_bg, underline = false, bold = true }
    return { fg = '#0100ff', underline = true, bold = true }
  end,
}
-- }}} CPPButton 

local DirenvStatus = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return require('direnv').statusline()
  end,
  hl = function()
    return { fg = mycolors.crashPink, underline = true }
  end,
}

-- {{{ HomeButton 
local HomeButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_haskell_scratchpad()
    end,
    name = 'HomeButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.crashPink, underline = true }
  end,
}
-- }}} HomeButton 

-- {{{ HaskellButton 
local HaskellButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_haskell_scratchpad()
    end,
    name = 'HaskellButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.crashPink, underline = true }
  end,
}
-- }}} HaskellButton 

-- {{{ JavaButton 
local JavaButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_java_scratchpad()
    end,
    name = 'JavaButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    return { fg = mycolors.phillipineOrange, underline = true }
  end,
}
-- }}} JavaButton 

-- {{{ JavascriptButton 
local JavascriptButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_cpp_scratchpad()
    end,
    name = 'GoButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    return { fg = '#bbbb33', underline = true }
  end,
}
-- }}} Javascript Button 

-- {{{ LightDarkButton 

local LightDarkButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('ToggleDarkMode')
    end,
    name = 'lightdarkbutton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = colors.lightdark_fg, underline = true }
  end,
}

-- }}} LightDarkButton 

-- {{{ LuaButton 
local LuaButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('Neotest summary')
    end,
    name = 'TestsButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    return { fg = mycolors.bluePartyParrot, underline = true }
  end,
}
-- }}} LuaButton 

-- {{{ NotificationButton 󰂞
local NotificationButton = { -- 󰂞
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('NvimTreeToggle')
    end,
    name = 'notification',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󰂞'
  end,
  hl = function()
    return { fg = mycolors.lightSalmon, underline = true }
  end,
}

-- }}} NotificationButton 󰂞

-- {{{ OCamlButton 
local OCamlButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_haskell_scratchpad()
    end,
    name = 'OCamlButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- ''
  end,
  hl = function()
    return { fg = mycolors.phillipineOrange, underline = true }
  end,
}
-- }}} HaskellButton 

-- {{{ PomodoroButtonOne 
local PomodoroButtonOne = { -- 
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('PomodoroStart')
    end,
    name = 'pomodorobutton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󱫠'
  end,
  hl = function()
    return { fg = mycolors.trackAndField, underline = true }
  end,
}
-- }}} PomodoroButtonOne 

-- {{{ PomodoroButtonTwo 
local PomodoroButtonTwo = { -- 
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('PomodoroStart')
    end,
    name = 'pomodorobutton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function(_)
    return '' .. require('pomodoro').statusline():sub(4)
  end,
  hl = function()
    return { fg = mycolors.trackAndField }
  end,
}
-- }}} PomodoroButtonTwo 

-- {{{ PythonButton 
local PythonButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_python_scratchpad()
    end,
    name = 'PythonButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = '#bbbb33', underline = true }
  end,
}
-- }}} FileTreeButton 

-- {{{ RButton 󰟔
local RButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_r_scratchpad()
    end,
    name = 'RButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󰟔'
  end,
  hl = function()
    return { fg = mycolors.bluePartyParrot, underline = true }
  end,
}
-- }}} RButton 󰟔

-- {{{ RustButton 
local RustButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('Neotest summary')
    end,
    name = 'TestsButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    return { fg = mycolors.trackAndField, underline = true }
  end,
}
-- }}} RustButton 

-- {{{ SettingsButton 
local SettingsButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('e ~/.config/nvim/README.md')
    end,
    name = 'settingsbutton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.trackAndField, underline = true }
  end,
}
-- }}} SettingsButton 

-- {{{ ShellButton  󰦮󰨊

local ShellButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_bash_scratchpad()
    end,
    name = 'BashButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = '#999999', underline = true }
  end,
}
-- }}} ShellButton 

-- {{{ SidebarButton 
local SidebarButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('AerialToggle')
    end,
    name = 'sidebarbutton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.donJuan }
  end,
}
-- }}} SidebarButton 

-- {{{ TestsButton 
local TestsButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('Neotest summary')
    end,
    name = 'TestsButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
  end,
  hl = function()
    return { fg = mycolors.munchOnMelon, underline = true }
  end,
}
-- }}} FileTreeButton 󰂓

-- {{{ TodoButton 󰄸
local TodoButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      vim.cmd('ToggleTODO')
    end,
    name = 'todo',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return '󰄸'
  end,
  hl = function()
    return { fg = mycolors.moussaka, underline = true }
  end,
}
-- }}} TodoButton 󰄸

-- {{{ ZigButton 
local ZigButton = {
  -- require('nvim-web-devicons').get_icon()
  on_click = {
    callback = function()
      ju.start_java_scratchpad()
    end,
    name = 'ZigButton',
  },
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function()
    return ''
    -- 
  end,
  hl = function()
    return { fg = mycolors.phillipineOrange, underline = true }
  end,
}
-- }}} ZigButton 

-- }}} Buttons

-- {{{ Statusline

local DefaultStatusline = {
  { Diagnostics },
  { StatusSpace },
  { Git },
  { Ruler },
  { StatusSpace },
  { FileNameBlock },
  { Align },

  { LSPActive },
  -- { venv },

  { NotificationButton },
  { StatusLineSpace },
  -- { PomodoroButtonOne },
  -- { PomodoroButtonTwo },
  { StatusLineSeparator },

  { StatusLineSpace },
  { StatusLineSeparator },
  { LightDarkButton },

  { StatusLineSpace },
  { StatusLineSeparator },
  { SettingsButton },

  { StatusLineSpace },
  { StatusLineSeparator },
  { SidebarButton },

  { StatusLineSpace },
  { StatusLineSeparator },

  -- { Ruler},
  -- { Space },
  -- { ScrollBar },
  -- { Space },
  -- { ViMode },
  -- { LSPMessages },
}

local InactiveStatusline = {
  condition = conditions.is_not_active,
  FileType,
  Space,
  FileName,
  Align,
}

local SpecialStatusline = {
  condition = function()
    return conditions.buffer_matches {
      buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
      filetype = { '^git.*', 'fugitive' },
    }
  end,

  FileType,
  Space,
  HelpFileName,
  Align,
}

local TerminalName = {
  -- we could add a condition to check that buftype == 'terminal'
  -- or we could do that later (see #conditional-statuslines below)
  provider = function()
    local tname, _ = vim.api.nvim_buf_get_name(0):gsub('.*:', '')
    return ' ' .. tname
  end,
  hl = { fg = 'blue', bold = true },
}

local TerminalStatusline = {
  condition = function()
    return conditions.buffer_matches { buftype = { 'terminal' } }
  end,
  hl = { bg = 'dark_red' },
  -- Quickly add a condition to the ViMode to only show it when buffer is active!
  { condition = conditions.is_active, ViMode, Space },
  FileType,
  Space,
  TerminalName,
  Align,
}

-- }}} Statusline

-- {{{ Build Lines
local StatusLines = {
  hl = function()
    if conditions.is_active() then
      return 'StatusLine'
    else
      return 'StatusLineNC'
    end
  end,
  -- the first statusline with no condition, or which condition returns true is used.
  -- think of it as a switch case with breaks to stop fallthrough.
  fallthrough = false,
  SpecialStatusline,
  TerminalStatusline,
  InactiveStatusline,
  DefaultStatusline,
}

local TabLine = {

  -- { Align },

  { Separator },
  { TabPages },
  { Separator },
  -- { BufferLine },

  { Align },
  { LSPActive },
  { Space },
  { Separator },
  { Space },
  { DirenvStatus },
  { Space },
  { Separator },
  { HomeButton },
  { Space },
  { Separator },
  { FileTreeButton },
  { Space },
  { Separator },
  { GitButton },
  { Space },
  { Separator },
  { GithubButton },
  { Space },
  { Separator },
  { TestsButton },
  { Space },
  -- { Separator },
  -- { DebugButton },
  -- { Space },
  { Separator },
  { TodoButton },
  { Space },

  -- { ViMode },

  -- { Space },
  -- { Separator },
  -- { ShellButton },

  -- { Space },
  -- { Separator },
  -- { CButton },

  -- { Space },
  -- { Separator },
  -- { CPPButton },

  -- { Space },
  -- { Separator },
  -- { GoButton },

  -- { Space },
  -- { Separator },
  -- { FortranButton },

  -- { Space },
  -- { Separator },
  -- { HaskellButton },

  -- { Space },
  -- { Separator },
  -- { JavaButton },

  -- { Space },
  -- { Separator },
  -- { JavascriptButton },

  -- { Space },
  -- { Separator },
  -- { LuaButton },

  -- { Space },
  -- { Separator },
  -- { OCamlButton },

  -- { Space },
  -- { Separator },
  -- { PythonButton },

  -- { Space },
  -- { Separator },
  -- { CButton },

  -- { Space },
  -- { Separator },
  -- { RButton },

  -- { Space },
  -- { Separator },
  -- { RustButton },

  -- { Space },
  -- { Separator },
  -- { ZigButton },

  -- { Space },
  -- { Separator },
}

-- local WinBar = { { require(lspsaga.symbol.winbar).get_bar() }, { {}, {} } }
local WinBar = {
  { FileNameBlock },
  { Diagnostics },
  { StatusSpace },
  { Git },
  { StatusSpace },

  {},

  { Align },

  { CppSeparator },
  { CppPlayButton },

  { RSeparator },
  { RPlayButton },

  -- { CppSeparator },
  { StatusSpace }, -- TODO: make CppStatusSpace
  { DebugButton },
  -- { StatusSpace },
  -- { StatusSpace },
  -- { ContinueButton },
  -- { StatusSpace },
  -- { JumpOutOfButton },
  -- { StatusSpace },
  -- { JumpIntoButton },
  -- { StatusSpace },
  -- { PauseButton },
  -- { StatusSpace },
  -- { RestartButton },

  { Separator },
  { AIButton }, -- conditions?
  { Separator }, -- conditions?
  -- { StatusSpace },
  { AerialToggleButton },
  { Separator },
  { TelescopeButton },
  { StatusSpace },
  { StatusSpace },
  { FileSearchButton },
  { Separator },
  { SplitButton },
  { StatusSpace },
  { VSplitButton },
  { StatusSpace },
  { CloseButton },
  { Separator },

  -- { Ruler },
  -- { ScrollBar },
  -- { actionHints },
}

local WinBarNC = {
  {},
  {},
  -- { require('lspsaga.symbol.winbar').get_bar() },
  -- {Align},
  -- {actionHints},
}

local InactiveWinBar = {
  condition = conditions.is_not_active,
  {},
  {},
}

local WinBars = {
  -- hl = function()
  --   if conditions.is_active() then
  --     return 'WinBar'
  --   else
  --     return 'WinBarNC'
  --   end
  -- end,
  -- the first statusline with no condition, or which condition returns true is used.
  -- think of it as a switch case with breaks to stop fallthrough.
  fallthrough = false,
  -- SpecialStatusline,
  -- TerminalStatusline,
  InactiveWinBar,
  WinBar,
}

-- local WinBar = { {Navic}, { {}, {} } }
-- local WinBar = { {}, { {}, {} } }
-- local TabLine = { {TabPages }, {}, {} }
-- local TabLine = { {BufferLine}, {}, {} }

-- }}} Build Lines

-- {{{ Setup Heirline

require('heirline').setup {
  -- statusline = StatusLines,
  winbar = WinBars,
  tabline = TabLine,
  opts = {
    colors = colors,
  },
}

-- }}} Setup Heirline

-- vim: set foldmethod=marker:
