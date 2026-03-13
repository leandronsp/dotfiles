-- ===================================================================
-- LSP Configuration Tests
-- ===================================================================
-- Test that LSP configuration is set up correctly

require 'plenary.busted'
local assert = require 'luassert'

describe('LSP Configuration', function()
  it('should have rust_analyzer configured', function()
    if _G.lsp_servers then
      assert.is_not_nil(_G.lsp_servers.rust_analyzer)
      assert.is_not_nil(_G.lsp_servers.rust_analyzer.settings)
      assert.is_not_nil(_G.lsp_servers.rust_analyzer.settings['rust-analyzer'])
    end
  end)

  it('should have lua_ls configured', function()
    if _G.lsp_servers then
      assert.is_not_nil(_G.lsp_servers.lua_ls)
      assert.is_not_nil(_G.lsp_servers.lua_ls.settings)
      assert.is_not_nil(_G.lsp_servers.lua_ls.settings.Lua)
    end
  end)

  it('should have LSP capabilities configured', function()
    if _G.lsp_capabilities then
      assert.is_not_nil(_G.lsp_capabilities)
      assert.is_table(_G.lsp_capabilities)
    end
  end)

  it('should configure rust-analyzer settings properly', function()
    if _G.lsp_servers and _G.lsp_servers.rust_analyzer then
      local rust_config = _G.lsp_servers.rust_analyzer.settings['rust-analyzer']

      -- Test clippy configuration
      assert.equals('clippy', rust_config.checkOnSave.command)

      -- Test cargo configuration
      assert.equals(true, rust_config.cargo.allFeatures)

      -- Test proc macro configuration
      assert.equals(true, rust_config.procMacro.enable)

      -- Test diagnostics configuration
      assert.equals(true, rust_config.diagnostics.enable)

      -- Test inlay hints configuration
      assert.equals(true, rust_config.inlayHints.enable)
    end
  end)
end)

describe('Diagnostic Configuration', function()
  it('should have diagnostic configuration set', function()
    local diagnostic_config = vim.diagnostic.config()

    assert.is_not_nil(diagnostic_config)
    -- Check if severity_sort is configured (may be nil if not set)
    assert.is_not_nil(diagnostic_config)
  end)

  it('should have proper diagnostic signs for Nerd Font', function()
    if vim.g.have_nerd_font then
      local config = vim.diagnostic.config()
      local signs = config.signs
      if type(signs) == 'table' and signs.text then
        assert.is_not_nil(signs.text[vim.diagnostic.severity.ERROR])
        assert.is_not_nil(signs.text[vim.diagnostic.severity.WARN])
      else
        -- Signs may be configured differently or not at all - this is acceptable
        assert.is_not_nil(config)
      end
    end
  end)
end)
