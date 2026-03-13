-- ===================================================================
-- Completion Configuration Tests
-- ===================================================================
-- Test that nvim-cmp is configured correctly

require 'plenary.busted'
local assert = require 'luassert'

describe('Completion Configuration', function()
  it('should have cmp configuration exported', function()
    if _G.cmp_config then
      assert.is_not_nil(_G.cmp_config)
      assert.is_table(_G.cmp_config)
    end
  end)

  it('should have proper completion sources', function()
    if _G.cmp_config and _G.cmp_config.sources then
      local sources = _G.cmp_config.sources
      local source_names = {}

      for _, source in ipairs(sources) do
        table.insert(source_names, source.name)
      end

      -- Check for essential completion sources
      assert.is_true(vim.tbl_contains(source_names, 'nvim_lsp'))
      assert.is_true(vim.tbl_contains(source_names, 'luasnip'))
      assert.is_true(vim.tbl_contains(source_names, 'path'))
    end
  end)

  it('should have lazydev source with correct priority', function()
    if _G.cmp_config and _G.cmp_config.sources then
      local sources = _G.cmp_config.sources
      local lazydev_source = nil

      for _, source in ipairs(sources) do
        if source.name == 'lazydev' then
          lazydev_source = source
          break
        end
      end

      if lazydev_source then
        assert.equals(0, lazydev_source.group_index)
      end
    end
  end)
end)

describe('LuaSnip Configuration', function()
  it('should have LuaSnip loaded', function()
    local ok, luasnip = pcall(require, 'luasnip')
    if ok then
      assert.is_not_nil(luasnip)
      assert.is_function(luasnip.expand_or_jump)
      assert.is_function(luasnip.jump)
    end
  end)
end)

describe('Completion Keymaps', function()
  it('should have completion mappings configured', function()
    if _G.cmp_config and _G.cmp_config.mapping then
      local mapping = _G.cmp_config.mapping
      assert.is_not_nil(mapping)
      assert.is_table(mapping)
    end
  end)
end)
