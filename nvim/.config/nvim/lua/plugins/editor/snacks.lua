-- ===================================================================
-- Snacks Picker Configuration - Modern Fuzzy Finder
-- ===================================================================
-- Comprehensive QoL plugin collection with modern fuzzy finder
-- Replaces telescope with enhanced features like frecency and git integration
-- See: https://github.com/folke/snacks.nvim

return {
  'folke/snacks.nvim',
  priority = 1000, -- Load early for better integration
  lazy = false, -- Don't lazy load for instant access
  dependencies = {
    -- Web dev icons (if Nerd Font is available)
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },

  config = function()
    -- ===================================================================
    -- Snacks Setup and Configuration
    -- ===================================================================
    -- Snacks is a collection of QoL plugins for Neovim with modern
    -- fuzzy finding capabilities that enhance the development experience

    require('snacks').setup {
      -- ===================================================================
      -- Core Modules Configuration
      -- ===================================================================

      -- Modern fuzzy finder with frecency, git integration, and image previews
      picker = {
        enabled = true,

        -- Default picker configuration
        opts = {
          -- File ignore patterns for better performance (same as telescope)
          file_ignore_patterns = {
            'node_modules',
            '.git/',
            'target/',
            'build/',
            '%.o',
            '%.a',
            '%.out',
            '%.class',
            '%.pdf',
            '%.mkv',
            '%.mp4',
            '%.zip',
          },

          -- Enable frecency for smart file ranking
          frecency = {
            enabled = true,
            -- Files accessed more recently and frequently rank higher
            max_timestamps = 100,
          },

          -- Git integration features
          git = {
            enabled = true,
            -- Show git status in file picker
            show_status = true,
          },

          -- Preview configuration
          preview = {
            enabled = true,
            -- Enable image previews (snacks exclusive feature)
            images = true,
            -- Enable treesitter highlighting in preview
            treesitter = true,
          },

          -- UI configuration
          ui = {
            -- Window border style
            border = 'rounded',
            -- Results window height
            height = 0.8,
            -- Results window width
            width = 0.8,
          },
        },

        -- Picker-specific configurations
        pickers = {
          files = {
            -- Include hidden files but respect gitignore
            hidden = true,
            -- Use ripgrep for file finding
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
          },

          grep = {
            -- Search in hidden files but respect gitignore
            additional_args = { '--hidden', '--glob', '!**/.git/*' },
          },

          buffers = {
            -- Sort buffers by last used
            sort_lastused = true,
          },

          oldfiles = {
            -- Include files from other projects
            include_current_session = true,
          },
        },
      },

      -- ===================================================================
      -- Additional QoL Modules
      -- ===================================================================

      -- Enhanced notifications
      notifier = {
        enabled = true,
        timeout = 3000, -- 3 seconds
        style = 'compact',
      },

      -- Dashboard for startup screen
      dashboard = {
        enabled = false, -- Disabled by default, can be enabled later
      },

      -- Enhanced status column
      statuscolumn = {
        enabled = false, -- Keep existing statusline, can be enabled later
      },

      -- Better quickfile handling
      quickfile = {
        enabled = true,
      },

      -- Smooth scrolling
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 15, total = 250 },
        },
      },

      -- Word highlighting
      words = {
        enabled = true,
      },

      -- Enhanced input dialogs
      input = {
        enabled = true,
      },

      -- Better indentation guides
      indent = {
        enabled = true,
        animate = {
          enabled = true,
        },
      },
    }

    -- ===================================================================
    -- Setup Keymaps
    -- ===================================================================
    -- Load keymaps from the keymaps module (cleaner separation)
    local keymaps = require 'config.keymaps'
    keymaps.setup_snacks_keymaps()

    -- ===================================================================
    -- Integration Notes
    -- ===================================================================
    -- Snacks picker provides all telescope functionality plus:
    -- - Built-in frecency (smart file ranking)
    -- - Native git integration (status, branches, logs)
    -- - Image previews directly in picker
    -- - Better performance and lower memory usage
    -- - Integrated QoL features (notifications, smooth scrolling)
    --
    -- Migration benefits:
    -- - Faster fuzzy finding with modern architecture
    -- - Smart file ranking based on usage patterns
    -- - Enhanced git workflow with built-in pickers
    -- - Image preview capabilities for better file browsing
    -- - Simplified configuration with better defaults
  end,
}
