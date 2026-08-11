-- Export the current org buffer to a PDF (via Emacs ox-latex) and view it in
-- zathura. Bound to <Space>oe and the winbar OrgPdfButton (see heirline.lua);
-- once a preview is open, saving the buffer refreshes it (BufWritePost hook in
-- nvim/ftplugin/org.lua -> M.on_save).
--
-- The render is ephemeral: the .tex/.pdf are written to a cache dir, never next
-- to the org source or into the yappopotamus site tree. The editor's rainbow
-- `hl` highlight palette is preserved in the PDF by nvim/scripts/org-pdf-export.el.

local M = {}

-- Track the zathura job per PDF path so re-exporting refreshes the open window
-- (zathura live-reloads on file change) instead of spawning a duplicate.
local viewers = {}
-- Guard against overlapping exports for the same PDF (e.g. rapid saves).
local inflight = {}

local function is_running(job)
  return job and vim.fn.jobwait({ job }, 0)[1] == -1
end

-- Cache path for a given org source. Kept in one place so the keymap, the
-- viewer dedup, and the save hook all agree on the target file.
local function pdf_path(src)
  local base = vim.fn.fnamemodify(src, ':t:r')
  return vim.fn.stdpath('cache') .. '/org-pdf/' .. base .. '.pdf'
end

-- The current buffer's org source path, or nil if it isn't an on-disk .org file.
local function current_src()
  local src = vim.api.nvim_buf_get_name(0)
  if src == '' or not src:match('%.org$') then
    return nil
  end
  return src
end

local function view(pdf)
  if is_running(viewers[pdf]) then
    return -- zathura already open on this file; it auto-reloads.
  end
  viewers[pdf] = vim.fn.jobstart({ 'zathura', pdf }, { detach = true })
end

-- Run the async Emacs export for `src`. opts:
--   view   -> spawn/refresh the zathura viewer on success
--   notify -> emit progress/success notifications (manual invocation only)
--   open_qf-> auto-open the quickfix list on failure (manual only; a silent
--             save shouldn't steal focus, but still fills the qflist for :copen)
local function do_export(src, opts)
  local outdir = vim.fn.stdpath('cache') .. '/org-pdf'
  vim.fn.mkdir(outdir, 'p')
  local base = vim.fn.fnamemodify(src, ':t:r')
  local tex = outdir .. '/' .. base .. '.tex'
  local pdf = outdir .. '/' .. base .. '.pdf'

  if inflight[pdf] then
    return -- an export is already running for this file; let it finish.
  end

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

  if opts.notify then
    vim.notify('org_pdf: exporting ' .. base .. '.pdf …', vim.log.levels.INFO)
  end
  inflight[pdf] = true
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = collect,
    on_stderr = collect,
    on_exit = function(_, code)
      inflight[pdf] = nil
      if code == 0 then
        if opts.notify then
          vim.notify('org_pdf: opened ' .. base .. '.pdf', vim.log.levels.INFO)
        end
        if opts.view then
          view(pdf)
        end
      else
        vim.fn.setqflist({}, ' ', { title = 'org_pdf export', lines = output })
        if opts.open_qf then
          vim.cmd('copen')
          vim.notify('org_pdf: export failed (see quickfix)', vim.log.levels.ERROR)
        else
          vim.notify('org_pdf: auto-export failed (:copen for details)', vim.log.levels.WARN)
        end
      end
    end,
  })
end

-- Manual export + open the viewer (keymap / winbar button).
function M.export_and_view()
  local src = current_src()
  if not src then
    vim.notify('org_pdf: current buffer is not an .org file', vim.log.levels.WARN)
    return
  end
  -- Export reflects on-disk content, so persist the buffer first.
  vim.cmd('silent! write')
  do_export(src, { view = true, notify = true, open_qf = true })
end

-- BufWritePost hook: refresh an already-open preview. No-op if the user hasn't
-- opened the PDF for this buffer (so we never export in the background for org
-- files nobody is previewing). The buffer is already written by the time this
-- fires, so we don't re-:write (which would also recurse into BufWritePost).
function M.on_save()
  local src = current_src()
  if not src then
    return
  end
  if is_running(viewers[pdf_path(src)]) then
    do_export(src, { view = false, notify = false, open_qf = false })
  end
end

return M
