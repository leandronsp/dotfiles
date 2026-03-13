-- ===================================================================
-- Colorscheme Configuration - Everforest
-- ===================================================================
-- Beautiful dark/light theme with good contrast and eye-friendly colors
-- See: https://github.com/neanias/everforest-nvim

return {
  'neanias/everforest-nvim',
  name = 'everforest',
  lazy = false, -- Load immediately since this is our main theme
  priority = 1000, -- High priority to ensure it loads before other UI plugins

  config = function()
    -- Configure the theme
    require('everforest').setup {
      -- Background contrast level: 'soft', 'medium', 'hard'
      -- 'medium' provides good balance between contrast and eye comfort
      background = 'medium',

      -- Transparency settings
      -- 0 = no transparency, 1-2 = increasing transparency levels
      transparent_background_level = 0,

      -- Enable italics for certain highlight groups
      italics = true,

      -- Disable terminal colors (let terminal handle its own colors)
      disable_terminal_colors = false,

      -- UI-related options
      ui_contrast = 'low', -- 'low' or 'high' - affects UI element contrast
      float_style = 'bright', -- 'bright' or 'dim' - floating window style

      -- Colors can be customized if needed
      colours_override = function(colours)
        -- Example: colours.bg0 = '#your_color'
        -- Leave empty for default colors
      end,

      -- Highlight overrides
      on_highlights = function(hl, palette)
        -- Example customizations:
        -- hl.CursorLine = { bg = palette.bg1 }
        -- hl.Visual = { bg = palette.bg_visual }
      end,
    }

    -- Set the default background mode
    -- This can be toggled with <leader>tt (configured in keymaps.lua)
    vim.o.background = 'dark'

    -- Apply the colorscheme
    vim.cmd.colorscheme 'everforest'
  end,
}
