local opts = {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
  bigfile = { enabled = true },
  dashboard = { enabled = true },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  --  picker = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  picker = { -- Enhances `select()`
    actions = {
      opencode_send = function(...)
        return require('opencode').snacks_picker_send(...)
      end,
    },
    win = {
      input = {
        keys = {
          ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
        },
      },
    },
  },
}

require('snacks').setup { opts }
