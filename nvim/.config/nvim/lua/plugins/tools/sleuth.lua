-- ===================================================================
-- Vim Sleuth Configuration
-- ===================================================================
-- Automatically detect and set buffer indentation (tabstop, shiftwidth)
-- See: https://github.com/tpope/vim-sleuth

return {
  'tpope/vim-sleuth',
  event = { 'BufReadPre', 'BufNewFile' }, -- Load when opening files

  -- This plugin works automatically without configuration
  -- It analyzes existing code in the file and adjusts:
  -- - tabstop (width of tab characters)
  -- - shiftwidth (indentation width)
  -- - expandtab (whether to use spaces or tabs)
  -- - softtabstop (tab key behavior in insert mode)
  --
  -- Very useful when working with codebases that use different
  -- indentation styles than your default settings
}
