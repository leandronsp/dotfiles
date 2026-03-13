-- ===================================================================
-- Todo Comments Configuration
-- ===================================================================
-- Highlights TODO, FIXME, NOTE, etc. in comments with distinctive colors
-- See: https://github.com/folke/todo-comments.nvim

return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },

  opts = {
    -- Don't show signs in the sign column to keep it cleaner
    signs = false,

    -- Keywords to highlight and their configurations
    keywords = {
      FIX = {
        icon = ' ', -- Icon used for the sign and in the results
        color = 'error', -- Can be a hex color, or a named color
        alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- Alternative keywords
      },
      TODO = { icon = ' ', color = 'info', alt = { 'todo' } },
      HACK = { icon = ' ', color = 'warning' },
      WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
      PERF = { icon = ' ', color = 'default', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
      NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
      TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
    },

    -- Enable GUI colors for better appearance in terminals that support it
    gui_style = {
      fg = 'NONE', -- The gui style to use for the fg highlight group
      bg = 'BOLD', -- The gui style to use for the bg highlight group
    },

    -- Merge keywords with defaults instead of replacing
    merge_keywords = true,

    -- Highlighting options
    highlight = {
      multiline = true, -- Enable multiline todo comments
      multiline_pattern = '^.', -- Pattern to match the start of a multiline comment
      multiline_context = 10, -- Lines to show around a multiline comment
      before = '', -- "fg" or "bg" or empty
      keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty
      after = 'fg', -- "fg" or "bg" or empty
      pattern = [[.*<(KEYWORDS)\s*:]], -- Pattern to match todo comments
      comments_only = true, -- Uses treesitter to match keywords in comments only
      max_line_len = 400, -- Ignore lines longer than this
      exclude = {}, -- List of file types to exclude highlighting
    },

    -- Search configuration for telescope integration
    search = {
      command = 'rg',
      args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
      },
      -- Regex pattern to find todo comments
      pattern = [[\b(KEYWORDS):]], -- Ripgrep regex
    },

    -- Color definitions for different keyword types
    colors = {
      error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
      warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
      info = { 'DiagnosticInfo', '#2563EB' },
      hint = { 'DiagnosticHint', '#10B981' },
      default = { 'Identifier', '#7C3AED' },
      test = { 'Identifier', '#FF006E' },
    },
  },
}
