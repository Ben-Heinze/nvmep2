local function mymap(mode, key, value)
  local opts = { silent = true, remap = true }
  vim.keymap.set(mode, key, value, opts)
  require('user.mac_option').set(mode, key, value, opts)
end

local status_ok, url_open = pcall(require, 'url-open')
if not status_ok then
  return
end
url_open.setup {}

mymap('n', '<A-o>', '<cmd>URLOpenUnderCursor<CR>')
