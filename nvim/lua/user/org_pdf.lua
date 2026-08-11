-- Export the current org buffer to a PDF (via Emacs ox-latex) and view it in
-- zathura. Bound to <Space>oe in org buffers (see nvim/ftplugin/org.lua).
--
-- The render is ephemeral: the .tex/.pdf are written to a cache dir, never next
-- to the org source or into the yappopotamus site tree. The editor's rainbow
-- `hl` highlight palette is preserved in the PDF by nvim/scripts/org-pdf-export.el.

local M = {}

-- Track the zathura job per PDF path so re-exporting refreshes the open window
-- (zathura live-reloads on file change) instead of spawning a duplicate.
local viewers = {}

local function is_running(job)
  return job and vim.fn.jobwait({ job }, 0)[1] == -1
end

local function view(pdf)
  if is_running(viewers[pdf]) then
    return -- zathura already open on this file; it auto-reloads.
  end
  viewers[pdf] = vim.fn.jobstart({ 'zathura', pdf }, { detach = true })
end

function M.export_and_view()
  local src = vim.api.nvim_buf_get_name(0)
  if src == '' or not src:match('%.org$') then
    vim.notify('org_pdf: current buffer is not an .org file', vim.log.levels.WARN)
    return
  end

  -- Export reflects on-disk content, so persist the buffer first.
  vim.cmd('silent! write')

  local outdir = vim.fn.stdpath('cache') .. '/org-pdf'
  vim.fn.mkdir(outdir, 'p')
  local base = vim.fn.fnamemodify(src, ':t:r')
  local tex = outdir .. '/' .. base .. '.tex'
  local pdf = outdir .. '/' .. base .. '.pdf'

  local loader = vim.api.nvim_get_runtime_file('scripts/org-pdf-export.el', false)[1]
  if not loader then
    vim.notify('org_pdf: could not locate scripts/org-pdf-export.el', vim.log.levels.ERROR)
    return
  end

  local elisp = string.format(
    '(org-export-to-file (quote latex) %q nil nil nil nil nil (function org-latex-compile))',
    tex
  )
  local cmd = { 'emacs', '--batch', '-l', loader, src, '--eval', elisp }

  local output = {}
  local function collect(_, data)
    if data then
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(output, line)
        end
      end
    end
  end

  vim.notify('org_pdf: exporting ' .. base .. '.pdf …', vim.log.levels.INFO)
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = collect,
    on_stderr = collect,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify('org_pdf: opened ' .. base .. '.pdf', vim.log.levels.INFO)
        view(pdf)
      else
        vim.fn.setqflist({}, ' ', {
          title = 'org_pdf export',
          lines = output,
        })
        vim.cmd('copen')
        vim.notify('org_pdf: export failed (see quickfix)', vim.log.levels.ERROR)
      end
    end,
  })
end

return M
