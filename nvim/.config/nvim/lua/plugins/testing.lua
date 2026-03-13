-- ===================================================================
-- Testing Infrastructure - Plenary.nvim
-- ===================================================================
-- Unit testing framework for Neovim configuration
-- See: https://github.com/nvim-lua/plenary.nvim

return {
  'nvim-lua/plenary.nvim',
  lazy = true, -- Only load when needed (as dependency or explicitly)

  -- Plenary provides:
  -- - Testing framework (busted-style)
  -- - Async utilities
  -- - File system utilities
  -- - Job management
  -- - Window/popup utilities
  -- - Many other Lua utility functions
  --
  -- It's used by many plugins as a dependency, and we use it for testing
}
