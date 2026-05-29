local function mymap(mode, key, value)
  vim.keymap.set(mode, key, value, { silent = true, remap = true })
end

require('aerial').setup {}

mymap('n', '<Space>aa', '<CMD>AerialToggle<CR>')
