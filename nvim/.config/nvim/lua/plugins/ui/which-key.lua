-- ===================================================================
-- Which-Key Configuration
-- ===================================================================
-- Shows pending keybinds in a helpful popup - great for discovering shortcuts
-- See: https://github.com/folke/which-key.nvim

return {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Load when Neovim starts

  opts = {
    -- Timing configuration
    delay = 0, -- No delay - show immediately when keys are pressed

    -- Icon configuration based on Nerd Font availability
    icons = {
      -- Use built-in mappings if Nerd Font is available
      mappings = vim.g.have_nerd_font,

      -- Define fallback icons for systems without Nerd Fonts
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },

    -- Key group documentation
    -- This helps organize and explain what different key prefixes do
    spec = {
      -- Code-related actions (LSP, formatting, etc.)
      { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },

      -- Document/buffer actions
      { '<leader>d', group = '[D]ocument' },

      -- Rename operations
      { '<leader>r', group = '[R]ename' },

      -- Search operations (Telescope)
      { '<leader>s', group = '[S]earch' },

      -- Workspace/project operations
      { '<leader>w', group = '[W]orkspace' },

      -- Toggle operations (theme, options, etc.)
      { '<leader>t', group = '[T]oggle' },

      -- Git hunk operations (from gitsigns)
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    },

    -- Window configuration
    win = {
      -- Borders and styling
      border = 'rounded',
      padding = { 2, 2, 2, 2 }, -- Extra padding inside the popup

      -- Position relative to cursor
      wo = {
        winblend = 10, -- Slight transparency for the popup window
      },
    },

    -- Layout configuration
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = 'left', -- align columns left, center or right
    },

    -- Don't show which-key for certain keys to reduce noise
    triggers = {
      { '<leader>', mode = { 'n', 'v' } },
      { 'g', mode = { 'n', 'v' } },
      { 'z', mode = { 'n', 'v' } },
      { ']', mode = { 'n', 'v' } },
      { '[', mode = { 'n', 'v' } },
    },
  },
}
