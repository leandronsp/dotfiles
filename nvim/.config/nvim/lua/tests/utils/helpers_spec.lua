-- ===================================================================
-- Utility Helpers Tests
-- ===================================================================
-- Test utility functions and helpers

require 'plenary.busted'
local assert = require 'luassert'

describe('Neovim Environment', function()
  it('should be running Neovim', function()
    assert.is_not_nil(vim)
    assert.is_not_nil(vim.version)
  end)

  it('should have required Neovim version', function()
    -- Check if we're running Neovim 0.10+
    local version = vim.version()
    assert.is_true(version.major >= 0)
    assert.is_true(version.minor >= 10)
  end)

  it('should have config directory set', function()
    local config_dir = vim.fn.stdpath 'config'
    assert.is_not_nil(config_dir)
    assert.is_true(vim.fn.isdirectory(config_dir) == 1)
  end)

  it('should have data directory set', function()
    local data_dir = vim.fn.stdpath 'data'
    assert.is_not_nil(data_dir)
    assert.is_true(vim.fn.isdirectory(data_dir) == 1)
  end)
end)

describe('Configuration Modules', function()
  it('should load config.options module', function()
    local ok, options = pcall(require, 'config.options')
    assert.is_true(ok, 'Failed to load config.options: ' .. tostring(options))
  end)

  it('should load config.keymaps module', function()
    local ok, keymaps = pcall(require, 'config.keymaps')
    assert.is_true(ok, 'Failed to load config.keymaps: ' .. tostring(keymaps))
    if ok then
      assert.is_table(keymaps)
    end
  end)

  it('should load config.autocmds module', function()
    local ok, autocmds = pcall(require, 'config.autocmds')
    assert.is_true(ok, 'Failed to load config.autocmds: ' .. tostring(autocmds))
    if ok then
      assert.is_table(autocmds)
    end
  end)

  it('should load config.lazy module', function()
    local ok, lazy = pcall(require, 'config.lazy')
    assert.is_true(ok, 'Failed to load config.lazy: ' .. tostring(lazy))
  end)
end)

describe('Plugin Loading', function()
  it('should have lazy.nvim available', function()
    local ok, lazy = pcall(require, 'lazy')
    assert.is_true(ok, 'lazy.nvim not available')
    if ok then
      assert.is_function(lazy.setup)
    end
  end)

  it('should load plenary for testing', function()
    local ok, plenary = pcall(require, 'plenary')
    assert.is_true(ok, 'plenary.nvim not available for testing')
  end)
end)

describe('File Structure', function()
  it('should have all required config files', function()
    local config_files = {
      'lua/config/init.lua',
      'lua/config/options.lua',
      'lua/config/keymaps.lua',
      'lua/config/autocmds.lua',
      'lua/config/lazy.lua',
    }

    for _, file in ipairs(config_files) do
      local full_path = vim.fn.stdpath 'config' .. '/' .. file
      assert.is_true(vim.fn.filereadable(full_path) == 1, 'Missing config file: ' .. file)
    end
  end)

  it('should have plugin directories', function()
    local plugin_dirs = {
      'lua/plugins/ui',
      'lua/plugins/editor',
      'lua/plugins/coding',
      'lua/plugins/tools',
    }

    for _, dir in ipairs(plugin_dirs) do
      local full_path = vim.fn.stdpath 'config' .. '/' .. dir
      assert.is_true(vim.fn.isdirectory(full_path) == 1, 'Missing plugin directory: ' .. dir)
    end
  end)
end)
