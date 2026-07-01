local utils = require('user.utils')

local function mktempdir()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, 'p')
  return dir
end

local function touch(path)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  vim.fn.writefile({}, path)
end

describe('user.utils', function()
  describe('detect_project_root', function()
    it('returns the nearest directory containing .git', function()
      local root = mktempdir()
      vim.fn.mkdir(vim.fs.joinpath(root, '.git'), 'p')

      local nested_file = vim.fs.joinpath(root, 'a', 'b', 'c.txt')
      touch(nested_file)

      assert.are.same(root, utils.detect_project_root(nested_file))
    end)

    it('treats a .git file as a project marker', function()
      local root = mktempdir()
      touch(vim.fs.joinpath(root, '.git'))

      local nested_file = vim.fs.joinpath(root, 'a', 'b', 'c.txt')
      touch(nested_file)

      assert.are.same(root, utils.detect_project_root(nested_file))
    end)

    it('returns nil when no .git exists upward', function()
      local root = mktempdir()
      local nested_file = vim.fs.joinpath(root, 'a', 'b', 'c.txt')
      touch(nested_file)

      assert.is_nil(utils.detect_project_root(nested_file))
    end)
  end)

  describe('has_flake', function()
    it('returns false when project root is missing', function()
      local root = mktempdir()
      local nested_file = vim.fs.joinpath(root, 'a', 'b', 'c.txt')
      touch(nested_file)

      assert.is_false(utils.has_flake(nested_file))
    end)

    it('returns false when flake.nix is missing', function()
      local root = mktempdir()
      vim.fn.mkdir(vim.fs.joinpath(root, '.git'), 'p')

      local nested_file = vim.fs.joinpath(root, 'a', 'b', 'c.txt')
      touch(nested_file)

      assert.is_false(utils.has_flake(nested_file))
    end)

    it('returns true when flake.nix exists at project root', function()
      local root = mktempdir()
      vim.fn.mkdir(vim.fs.joinpath(root, '.git'), 'p')

      touch(vim.fs.joinpath(root, 'flake.nix'))

      local nested_file = vim.fs.joinpath(root, 'a', 'b', 'c.txt')
      touch(nested_file)

      assert.is_true(utils.has_flake(nested_file))
    end)
  end)
end)
