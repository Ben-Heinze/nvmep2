vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.loadplugins = false

vim.o.swapfile = false
vim.o.writebackup = false
vim.o.backup = false
vim.o.undofile = false
vim.o.shadafile = 'NONE'

local plenary_dir = vim.env.NVIM_TEST_PLENARY
local project_rtp = vim.env.NVIM_TEST_RTP

assert(type(plenary_dir) == 'string' and plenary_dir ~= '', 'NVIM_TEST_PLENARY is required')
assert(type(project_rtp) == 'string' and project_rtp ~= '', 'NVIM_TEST_RTP is required')

vim.opt.rtp:prepend(plenary_dir)
vim.opt.rtp:prepend(project_rtp)

require('plenary.busted')
