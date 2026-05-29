local function mymap(mode, key, value)
  vim.keymap.set(mode, key, value, { silent = true, remap = true })
end

local status_ok, url_open = pcall(require, 'url-open')
if not status_ok then
  return
end
url_open.setup {}

mymap('n', '<A-o>', '<cmd>URLOpenUnderCursor<CR>')
