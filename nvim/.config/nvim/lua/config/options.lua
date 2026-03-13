-- ===================================================================
-- Neovim Options Configuration
-- ===================================================================
-- Core settings that define the behavior and appearance of Neovim
-- These settings are loaded first before any plugins

-- ===================================================================
-- Leader Keys
-- ===================================================================
-- Set leader key to semicolon for easier access than default space
-- Must be set before loading plugins to ensure correct mapping
vim.g.mapleader = ';'
vim.g.maplocalleader = ';'

-- ===================================================================
-- Environment Setup
-- ===================================================================
-- Add Rust tools to PATH for Neovim to find rust-analyzer and other tools
vim.env.PATH = vim.env.PATH .. ':' .. vim.env.HOME .. '/.cargo/bin'

-- Enable Nerd Font support for better icons and visual elements
vim.g.have_nerd_font = true

-- ===================================================================
-- Display Options
-- ===================================================================
-- Show line numbers on the left side
vim.opt.number = true

-- Enable mouse support for all modes (useful for resizing splits, selecting text)
vim.opt.mouse = 'a'

-- Don't show mode indicator in command line (status line already shows it)
vim.opt.showmode = false

-- Show which line your cursor is currently on with background highlighting
vim.opt.cursorline = true

-- Always show the sign column to avoid text shifting when signs appear/disappear
vim.opt.signcolumn = 'yes'

-- Make whitespace characters visible with custom symbols
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- ===================================================================
-- Editing Behavior
-- ===================================================================
-- Enable break indent - wrapped lines will match the indentation of the first line
vim.opt.breakindent = true

-- Save undo history to a file so you can undo even after closing and reopening
vim.opt.undofile = true

-- Keep at least 10 screen lines above and below the cursor when scrolling
vim.opt.scrolloff = 10

-- ===================================================================
-- Search Configuration
-- ===================================================================
-- Case-insensitive searching UNLESS the search contains capital letters
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Show live preview of substitute commands as you type
vim.opt.inccommand = 'split'

-- ===================================================================
-- Timing Options
-- ===================================================================
-- Faster completion and better user experience (default is 4000ms)
vim.opt.updatetime = 250

-- Time to wait for a mapped sequence to complete (default is 1000ms)
vim.opt.timeoutlen = 300

-- ===================================================================
-- Window Behavior
-- ===================================================================
-- Open vertical splits to the right of current window
vim.opt.splitright = true

-- Open horizontal splits below current window
vim.opt.splitbelow = true

-- ===================================================================
-- Clipboard Integration
-- ===================================================================
-- Sync clipboard between OS and Neovim
-- Scheduled after UI loads to avoid slowing down startup
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
