-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
-- require("nvim-tree").setup()

-- OR setup with some options
-- require("nvim-tree").setup({
--   sort = {
--     sorter = "case_sensitive",
--   },
--   view = {
--     width = 30,
--   },
--   renderer = {
--     group_empty = true,
--   },
--   filters = {
--     dotfiles = true,
--   },
--   sync_root_with_cwd = true,
--
--   actions = {
--     open_file = {
--       window_picker = {
--         enable = true,
--         picker = function()
--           return require('window-picker').pick_window {
--             filter_rules = {
--               file_path_contains = { 'nvim-tree-preview://' },
--             },
--           }
--         end,
--       },
--     },
--   },
--
-- })

-- require('nvim-tree-preview').setup {
--   -- Keymaps for the preview window (does not apply to the tree window).
--   -- Keymaps can be a string (vimscript command), a function, or a table.
--   --
--   -- If a function is provided:
--   --   When the keymap is invoked, the function is called.
--   --   It will be passed a single argument, which is a table of the following form:
--   --     {
--   --       node: NvimTreeNode|NvimTreeRootNode, -- The tree node under the cursor
--   --     }
--   --   See the type definitions in `lua/nvim-tree-preview/types.lua` for a description
--   --   of the fields in the table.
--   --
--   -- If a table, it must contain either an 'action' or 'open' key:
--   --   Actions:
--   --     { action = 'close', unwatch? = false, focus_tree? = true }
--   --     { action = 'toggle_focus' }
--   --     { action = 'select_node', target: 'next'|'prev' }
--   --
--   --   Open modes:
--   --     { open = 'edit' }
--   --     { open = 'tab' }
--   --     { open = 'vertical' }
--   --     { open = 'horizontal' }
--   --
--   -- To disable a default keymap, set it to false.
--   -- All keymaps are set in normal mode. Other modes are not currently supported.
--   keymaps = {
--     ['<Esc>'] = { action = 'close', unwatch = true },
--     ['<Tab>'] = { action = 'toggle_focus' },
--     ['<CR>'] = { open = 'edit' },
--     ['<C-t>'] = { open = 'tab' },
--     ['<C-v>'] = { open = 'vertical' },
--     ['<C-x>'] = { open = 'horizontal' },
--     ['<C-n>'] = { action = 'select_node', target = 'next' },
--     ['<C-p>'] = { action = 'select_node', target = 'prev' },
--   },
--   min_width = 10,
--   min_height = 5,
--   max_width = 85,
--   max_height = 25,
--   wrap = false,           -- Whether to wrap lines in the preview window
--   border = 'rounded',     -- Border style for the preview window
--   zindex = 100,           -- Stacking order. Increase if the preview window is shown below other windows.
--   show_title = true,      -- Whether to show the file name as the title of the preview window
--   title_pos = 'top-left', -- top-left|top-center|top-right|bottom-left|bottom-center|bottom-right
--   title_format = ' %s ',
--   follow_links = true,    -- Whether to follow symlinks when previewing files
--   -- win_position: { row?: number|function, col?: number|function }
--   -- Position of the preview window relative to the tree window.
--   -- If not specified, the position is automatically calculated.
--   -- Functions receive (tree_win, size) parameters and must return a number, where:
--   --   tree_win: number - tree window handle
--   --   size: {width: number, height: number} - dimensions of the preview window
--   -- Example:
--   --   win_position = {
--   --    col = function(tree_win, size)
--   --      local view_side = require('nvim-tree').config.view.side
--   --      return view_side == 'left' and vim.fn.winwidth(tree_win) + 1 or -size.width - 3
--   --    end,
--   --   },
--   win_position = {},
--   image_preview = {
--     enable = true, -- Whether to preview images (for more info see Previewing Images section in README)
--     patterns = {   -- List of Lua patterns matching image file names
--       '.*%.png$',
--       '.*%.jpg$',
--       '.*%.jpeg$',
--       '.*%.gif$',
--       '.*%.webp$',
--       '.*%.avif$',
--       -- Additional patterns:
--       '.*%.svg$',
--       '.*%.bmp$',
--       '.*%.pdf$', -- (known to have issues)
--     },
--   },
--   on_open = nil,          -- fun(win: number, buf: number) called when the preview window is opened
--   on_close = nil,         -- fun() called when the preview window is closed
--   watch = {
--     event = 'CursorMoved' -- 'CursorMoved'|'CursorHold'. Event to use to update the preview in watch mode
--   },
-- }

require('nvim-tree').setup {
  sync_root_with_cwd = true,
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')

    -- Important: When you supply an `on_attach` function, nvim-tree won't
    -- automatically set up the default keymaps. To set up the default keymaps,
    -- call the `default_on_attach` function. See `:help nvim-tree-quickstart-custom-mappings`.
    api.config.mappings.default_on_attach(bufnr)

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    local function open_with_xdg()
      local node = api.tree.get_node_under_cursor()
      if node and node.type == 'file' then
        vim.fn.jobstart({ 'xdg-open', node.absolute_path }, { detach = true })
      end
    end

    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', '<C-o>', open_with_xdg, { buffer = bufnr, desc = 'Open with xdg-open' })

    -- local preview = require('nvim-tree-preview')

    -- vim.keymap.set('n', 'P', preview.watch, opts 'Preview (Watch)')
    -- vim.keymap.set('n', '<Esc>', preview.unwatch, opts 'Close Preview/Unwatch')
    -- -- NOTE: consider these bindings?
    -- vim.keymap.set('n', '<C-f>', function() return preview.scroll(4) end, opts 'Scroll Down')
    -- vim.keymap.set('n', '<C-b>', function() return preview.scroll(-4) end, opts 'Scroll Up')

    -- -- Option A: Smart tab behavior: Only preview files, expand/collapse directories (recommended)
    -- vim.keymap.set('n', '<Tab>', function()
    --   local ok, node = pcall(api.tree.get_node_under_cursor)
    --   if ok and node then
    --     if node.type == 'directory' then
    --       api.node.open.edit()
    --     else
    --       preview.node(node, { toggle_focus = true })
    --     end
    --   end
    -- end, opts 'Preview')

    -- Option B: Simple tab behavior: Always preview
    -- vim.keymap.set('n', '<Tab>', preview.node_under_cursor, opts 'Preview')
  end,
}
