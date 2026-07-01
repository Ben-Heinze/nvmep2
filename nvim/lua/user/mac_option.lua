local M = {}

local aliases = {
  ['<A-1>'] = '¡',
  ['<A-2>'] = '™',
  ['<A-3>'] = '£',
  ['<A-4>'] = '¢',
  ['<A-5>'] = '∞',
  ['<A-6>'] = '§',
  ['<A-7>'] = '¶',
  ['<A-8>'] = '•',
  ['<A-9>'] = 'ª',
  ['<A-d>'] = '∂',
  ['<A-f>'] = 'ƒ',
  ['<A-g>'] = '©',
  ['<A-h>'] = '˙',
  ['<A-j>'] = '∆',
  ['<A-k>'] = '˚',
  ['<A-l>'] = '¬',
  ['<A-o>'] = 'ø',
  ['<A-p>'] = 'π',
  ['<A-s>'] = 'ß',
  ['<A-v>'] = '√',
  ['<A-x>'] = '≈',
  ['<A-S-->'] = '—',
  ['<A-S-=>'] = '±',
  ['<A-S-h>'] = 'Ó',
  ['<A-S-j>'] = 'Ô',
  ['<A-S-k>'] = '',
  ['<A-S-l>'] = 'Ò',
}

function M.alias_for(key)
  if vim.fn.has('macunix') ~= 1 then
    return nil
  end

  return aliases[key:gsub('^<M%-', '<A-')]
end

function M.set(mode, key, value, opts)
  local alias = M.alias_for(key)
  if alias then
    vim.keymap.set(mode, alias, value, opts)
  end
end

return M
