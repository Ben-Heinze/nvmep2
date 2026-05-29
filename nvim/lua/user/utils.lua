local M = {}

M.detect_project_root = function(fpath)
  return vim.fs.dirname(vim.fs.find({ '.git' }, {
    path = fpath,
    upward = true,
  })[1])
end

M.has_flake = function(fname)
  local root = M.detect_project_root(fname)
  if not root then
    return false
  end
  local flake_path = vim.fs.joinpath(root, 'flake.nix')
  return vim.loop.fs_stat(flake_path) ~= nil
end

return M
