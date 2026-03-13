-- ===================================================================
-- Configuration Keymaps Tests
-- ===================================================================
-- Test that keymaps are configured correctly

require 'plenary.busted'
local assert = require 'luassert'

describe('Basic Keymaps', function()
  it('should have escape keymap for clearing search highlights', function()
    local keymap = vim.api.nvim_get_keymap 'n'
    local escape_map = nil

    for _, map in ipairs(keymap) do
      if map.lhs == '<Esc>' then
        escape_map = map
        break
      end
    end

    assert.is_not_nil(escape_map)
    assert.is_true(string.find(escape_map.rhs, 'nohlsearch') ~= nil)
  end)

  it('should have window navigation keymaps', function()
    -- Load configuration to ensure keymaps are set
    require('config.options')
    require('config.keymaps')
    
    local nav_keys = { '<C-h>', '<C-j>', '<C-k>', '<C-l>' }

    for _, key in ipairs(nav_keys) do
      -- Check if keymap exists using vim.fn.mapcheck
      local mapping = vim.fn.mapcheck(key, 'n')
      assert.is_not.equals('', mapping, 'Missing navigation keymap: ' .. key)
    end
  end)

  it('should have diagnostic quickfix keymap', function()
    local keymap = vim.api.nvim_get_keymap 'n'
    local diagnostic_map = nil

    for _, map in ipairs(keymap) do
      if map.lhs == ';q' then
        diagnostic_map = map
        break
      end
    end

    assert.is_not_nil(diagnostic_map)
  end)
end)

describe('Keymap Helper Functions', function()
  it('should provide snacks keymap setup function', function()
    local keymaps = require 'config.keymaps'
    assert.is_function(keymaps.setup_snacks_keymaps)
  end)

  it('should provide LSP keymap setup function', function()
    local keymaps = require 'config.keymaps'
    assert.is_function(keymaps.setup_lsp_keymaps)
  end)

  it('should provide inlay hints setup function', function()
    local keymaps = require 'config.keymaps'
    assert.is_function(keymaps.setup_inlay_hints)
  end)
end)
