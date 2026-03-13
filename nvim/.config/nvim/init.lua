--[[
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================  
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is This Configuration?

  This is a MODULAR Neovim configuration built on top of kickstart.nvim.
  
  The original kickstart approach was to keep everything in a single init.lua
  file for educational purposes. This configuration takes the next step by
  organizing everything into logical modules while maintaining the same
  educational approach with detailed comments.

Structure Overview:

  lua/config/         - Core Neovim configuration
    ├── init.lua      - Main configuration loader  
    ├── options.lua   - Vim options and settings
    ├── keymaps.lua   - Key mappings and shortcuts
    ├── autocmds.lua  - Autocommands and events
    └── lazy.lua      - Plugin manager setup
    
  lua/plugins/        - Plugin configurations organized by purpose
    ├── ui/           - User interface plugins
    ├── editor/       - Text editing and navigation
    ├── coding/       - Language support and development tools  
    └── tools/        - Utilities and specialized tools

Getting Started:

  1. Run `:Tutor` if you're new to Neovim
  2. Check `:checkhealth` to verify your setup  
  3. Read the README.md for usage guide and shortcuts
  4. Explore lua/config/ to understand the configuration structure
  5. Look at lua/plugins/ to see how plugins are organized

Useful Commands:
  
  :Lazy              - Manage plugins
  :Mason             - Manage LSP servers and tools
  :checkhealth       - Verify system setup
  :source %          - Reload configuration
  
Key Shortcuts (Leader: ';'):
  
  ;sf                - Search files
  ;sg                - Search text (grep)  
  ;n                 - Toggle file tree
  ;f                 - Format current buffer
  ;tt                - Toggle dark/light theme
  
For a complete guide, see README.md

--]]

-- ===================================================================
-- Neovim Configuration Entry Point
-- ===================================================================
-- This is the main entry point for the Neovim configuration.
-- All actual configuration is organized into modules in lua/config/

-- Load the main configuration module
-- This handles loading all other configuration in the correct order
require('config')

-- ===================================================================
-- Legacy Compatibility
-- ===================================================================
-- Keep the modeline for proper file handling
-- vim: ts=2 sts=2 sw=2 et