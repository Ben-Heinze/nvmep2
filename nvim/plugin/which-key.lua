require('which-key').setup {
  preset = 'classic',
  -- preset = 'helix'
}
local wk = require('which-key')
-- 󱪳󰟝󱕘 󱡶󱜚󱜙󱘎󱓞󱓟󱒉󱎯󱍊󱇪󱇫󱁾󱁕󱁊󱁉󰻈󰺛󰸘󰸗󰴻󰴺󰴭󰳆󰱐󰭎
-- 󰨡󰨆󰨊󰨈󰧲󰧱󰧰󰧊󰧑󰥨󰥩󰤑󰣙󰣘󰡴󰟁󰜏󰙨󰑣󰒪󰐅󰐁󰌢󰋸󰊢󰅎󰅏󰃤󰂒󰂓󰂖󰂚󰂞
-- 
-- ⭘
-- 
-- 󰂒󰃇󰃤󰃠󰃠󰃝󰄰󰄯󰈝󰈪  
-- valid colors are: `azure`, `blue`, `cyan`, `green`, `grey`, `orange`, `purple`, `red`, `yellow`
wk.add {
  { '<Space>a', group = 'Aerial', icon = { icon = '', color = 'cyan' } },
  { '<Space>b', group = 'Buffers', icon = { icon = '', color = 'azure' } },
  { '<Space>c', group = 'Code', icon = { icon = '', color = 'orange' } },
  { '<Space>d', group = 'Debug', icon = { icon = '', color = 'red' } },
  { '<Space>e', group = 'Errors', icon = { icon = '', color = 'red' } },
  { '<Space>f', group = 'File', icon = { icon = '', color = 'blue' } },
  { '<Space>g', group = 'Git/go', icon = { icon = '', color = 'red' } },
  { '<Space>h', group = 'Help', icon = { icon = '', color = 'purple' } },
  { '<Space>m', group = 'Make', icon = { icon = '', color = 'yellow' } },
  { '<Space>o', group = 'Open', icon = { icon = '', color = 'azure' } },
  { '<Space>p', group = 'Project', icon = { icon = '', color = 'purple' } },
  { '<Space>r', group = 'Run', icon = { icon = '', color = 'red' } },
  { '<Space>t', group = 'Tab', icon = { icon = '', color = 'cyan' } },
  { '<Space>u', group = 'Ui', icon = { icon = '', color = 'cyan' } },
  { '<Space>w', group = 'Window/Workspace', icon = { icon = '', color = 'orange' } },
  { '<Space>y', group = 'Snippet', icon = { icon = '', color = 'blue' } },
  { '<Space>z', '<CMD>ZenMode<CR>', mode = 'n', icon = { icon = '', color = 'grey' } },
  { '<Space><return>', '<CMD>Nuake<CR>', mode = 'n', icon = { icon = '', color = 'grey' } },
  { '<Space><Space>', '<CMD>JustRun<CR>', mode = 'n', icon = { icon = '󱕘', color = 'orange' } },
  { '<Space>j', '<CMD>JustSelect<CR>', mode = 'n', icon = { icon = '', color = 'orange' } },
}
