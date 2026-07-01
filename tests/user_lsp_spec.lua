local lsp = require('user.lsp')

describe('user.lsp', function()
  describe('make_client_capabilities', function()
    it('merges cmp_nvim_lsp capabilities without overriding existing fields', function()
      local old_make = vim.lsp.protocol.make_client_capabilities
      local old_preload = package.preload['cmp_nvim_lsp']

      vim.lsp.protocol.make_client_capabilities = function()
        return { a = 1, nested = { keep = true } }
      end

      package.preload['cmp_nvim_lsp'] = function()
        return {
          default_capabilities = function()
            return { a = 999, b = 2, nested = { keep = false, add = true } }
          end,
        }
      end

      local capabilities = lsp.make_client_capabilities()

      vim.lsp.protocol.make_client_capabilities = old_make
      package.preload['cmp_nvim_lsp'] = old_preload

      assert.are.same(1, capabilities.a)
      assert.are.same(2, capabilities.b)
      assert.are.same(true, capabilities.nested.keep)
      assert.are.same(true, capabilities.nested.add)
    end)
  end)
end)

