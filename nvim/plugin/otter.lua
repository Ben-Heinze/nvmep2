-- LSP inside org `#+begin_src` blocks, via otter.nvim.
--
-- otter creates a hidden buffer per embedded language, keeps it in sync with the
-- code chunks in the org buffer, and attaches the matching language server to
-- it. It also runs an `otter-ls` client on the org buffer itself, which routes
-- the standard `vim.lsp.buf.*` requests (hover/definition/references, and cmp's
-- `nvim_lsp` completion source) into those hidden buffers. Net effect: real
-- completion / hover / diagnostics / go-to-definition inside a src block.
--
-- The servers themselves are the same ones the ftplugins start: setting the
-- otter buffer's filetype (otter's default `set_filetype = true`) triggers
-- `ftplugin/<lang>.lua`, whose `vim.lsp.start` attaches clangd / pylsp / the R
-- language server / jdtls. Those must be on PATH for the given language (C++ is
-- always available here; R and Java come from a per-project direnv, matching how
-- org-babel execution resolves its runtimes -- see lua/user/org_babel.lua).

if vim.g.did_load_otter_plugin then
  return
end
vim.g.did_load_otter_plugin = true

local languages = { 'python', 'r', 'cpp', 'java' }

require('otter').setup {
  -- `java` is not in otter's built-in extension table; register it so the
  -- hidden buffer gets a .java extension and jdtls attaches.
  extensions = { java = 'java' },
  lsp = {
    -- Update diagnostics on leaving insert too, not only on save -- notes
    -- buffers are rarely written mid-edit.
    diagnostic_update_events = { 'BufWritePost', 'InsertLeave' },
  },
  -- Don't nag when a block's language isn't among the ones we activate.
  verbose = { no_code_found = false },
}

---Activate otter for an org buffer (idempotent; re-run to pick up blocks whose
---language was added after the first activation). `buf` must be the current
---buffer: otter targets `nvim_get_current_buf()`, and attaching servers to the
---hidden otter buffers relies on the real current-buffer context (wrapping this
---in `nvim_buf_call` silently prevents the language servers from attaching).
local function activate(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or buf ~= vim.api.nvim_get_current_buf() then
    return
  end
  -- Only real, on-disk org buffers -- skip org-roam prompts and scratch buffers.
  if vim.bo[buf].buftype ~= '' then
    return
  end
  pcall(function()
    -- Ensure the org tree (and its src-block injections) is parsed so otter can
    -- extract code chunks; otherwise activation finds nothing and bails.
    local ok_parser, parser = pcall(vim.treesitter.get_parser, buf, 'org')
    if ok_parser and parser then
      parser:parse(true)
    end
    require('otter').activate(languages, true, true)
  end)
end

local group = vim.api.nvim_create_augroup('OtterOrg', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'org',
  group = group,
  desc = 'Activate otter LSP in org code blocks',
  callback = function(args)
    -- Defer so the org treesitter parser and its injection query are ready
    -- before otter extracts code chunks.
    vim.schedule(function()
      activate(args.buf)

      -- Buffer-local command + mapping to re-activate after adding a new
      -- language block (otter only tracks languages present at activation).
      vim.api.nvim_buf_create_user_command(args.buf, 'OtterActivate', function()
        activate(args.buf)
      end, { desc = 'otter: (re)activate LSP for org code blocks' })

      vim.keymap.set('n', '<Space>ol', function()
        activate(args.buf)
      end, { buffer = args.buf, silent = true, desc = 'otter: (re)activate code-block LSP' })
    end)
  end,
})
