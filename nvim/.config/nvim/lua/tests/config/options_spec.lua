-- ===================================================================
-- Configuration Options Tests
-- ===================================================================
-- Test that vim options and global variables are set correctly

require 'plenary.busted'
local assert = require 'luassert'

describe('Neovim Options', function()
  -- Test leader key configuration
  it('should set leader key to semicolon', function()
    assert.equals(';', vim.g.mapleader)
    assert.equals(';', vim.g.maplocalleader)
  end)

  -- Test Nerd Font configuration
  it('should have Nerd Font enabled', function()
    assert.equals(true, vim.g.have_nerd_font)
  end)

  -- Test basic vim options
  it('should enable line numbers', function()
    assert.equals(true, vim.opt.number:get())
  end)

  it('should enable mouse support', function()
    local mouse_setting = vim.opt.mouse:get()
    if type(mouse_setting) == 'table' then
      assert.is_true(mouse_setting.a)
    else
      assert.equals('a', mouse_setting)
    end
  end)

  it('should disable showmode', function()
    assert.equals(false, vim.opt.showmode:get())
  end)

  it('should enable cursor line highlighting', function()
    assert.equals(true, vim.opt.cursorline:get())
  end)

  it('should set proper split behavior', function()
    assert.equals(true, vim.opt.splitright:get())
    assert.equals(true, vim.opt.splitbelow:get())
  end)

  it('should configure search behavior', function()
    assert.equals(true, vim.opt.ignorecase:get())
    assert.equals(true, vim.opt.smartcase:get())
  end)

  it('should set scrolloff', function()
    assert.equals(10, vim.opt.scrolloff:get())
  end)

  it('should configure timing options', function()
    assert.equals(250, vim.opt.updatetime:get())
    assert.equals(300, vim.opt.timeoutlen:get())
  end)
end)

describe('Environment Configuration', function()
  it('should have Rust tools in PATH', function()
    local path = vim.env.PATH
    local home = vim.env.HOME
    assert.is_not_nil(path)
    assert.is_not_nil(home)
    assert.is_true(string.find(path, home .. '/.cargo/bin') ~= nil)
  end)
end)
