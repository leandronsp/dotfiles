-- ===================================================================
-- Lazy.nvim Plugin Manager Setup
-- ===================================================================
-- Bootstrap and configure lazy.nvim for plugin management
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info

-- ===================================================================
-- Bootstrap lazy.nvim
-- ===================================================================
-- Install lazy.nvim if not already installed

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- ===================================================================
-- Plugin Configuration
-- ===================================================================
-- Setup lazy.nvim with automatic plugin loading from lua/plugins/

require('lazy').setup({
  -- Import all plugin configurations from the plugins directory
  -- This automatically loads any .lua file in lua/plugins/ and its subdirectories
  { import = 'plugins.ui' }, -- UI plugins (theme, statusline, etc.)
  { import = 'plugins.editor' }, -- Editor plugins (telescope, treesitter, etc.)
  { import = 'plugins.coding' }, -- Coding plugins (LSP, completion, etc.)
  { import = 'plugins.tools' }, -- Tool plugins (AI, markdown, etc.)

  -- Keep existing kickstart plugins for compatibility
  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns',
}, {
  -- ===================================================================
  -- Lazy.nvim UI Configuration
  -- ===================================================================
  ui = {
    -- Use Nerd Font icons if available, otherwise use unicode fallbacks
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },

  -- ===================================================================
  -- Performance Options
  -- ===================================================================
  install = {
    -- Try to load one of these colorschemes when starting an installation during startup
    colorscheme = { 'everforest' },
  },

  -- Automatically check for plugin updates but don't notify
  checker = {
    enabled = false,
    notify = false,
  },

  -- Disable change detection notifications
  change_detection = {
    notify = false,
  },
})
