-- ===================================================================
-- Configuration Module Loader
-- ===================================================================
-- This module loads all configuration components in the correct order
-- Called from the main init.lua file

-- ===================================================================
-- Load Configuration Modules
-- ===================================================================

-- 1. Load core options first (leader keys, vim options, etc.)
require 'config.options'

-- 2. Load basic keymaps (non-plugin keymaps)
require 'config.keymaps'

-- 3. Setup autocommands
require 'config.autocmds'

-- 4. Setup LSP autocommands (must be called after autocmds module loads)
local autocmds = require 'config.autocmds'
autocmds.setup_lsp_attach()

-- 5. Bootstrap and configure lazy.nvim (loads all plugins)
require 'config.lazy'

-- ===================================================================
-- Post-Plugin Configuration
-- ===================================================================
-- Any configuration that needs to run after plugins are loaded

-- Note: Plugin-specific configurations are handled in their respective
-- files in lua/plugins/. This file only handles the core loading sequence.
