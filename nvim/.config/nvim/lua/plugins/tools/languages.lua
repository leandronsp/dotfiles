-- ===================================================================
-- Language-Specific Plugin Support
-- ===================================================================
-- Syntax highlighting and basic support for various languages
-- These are minimal, focused plugins for specific file types

return {
  -- ===================================================================
  -- Web Development Languages
  -- ===================================================================

  -- CoffeeScript support
  {
    'kchmck/vim-coffee-script',
    ft = 'coffee', -- Only load for CoffeeScript files
  },

  -- JavaScript enhanced syntax
  {
    'pangloss/vim-javascript',
    ft = 'javascript', -- Only load for JavaScript files
  },

  -- TypeScript syntax highlighting
  {
    'leafgarland/typescript-vim',
    ft = 'typescript', -- Only load for TypeScript files
  },

  -- ===================================================================
  -- Lean 4 Theorem Prover
  -- ===================================================================
  {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
    build = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      mappings = true,
    },
  },

  -- ===================================================================
  -- Additional Language Support
  -- ===================================================================
  -- Uncomment and add more language plugins as needed:

  -- -- Go language support
  -- {
  --   'fatih/vim-go',
  --   ft = 'go',
  -- },

  -- -- Python indentation and syntax
  -- {
  --   'vim-python/python-syntax',
  --   ft = 'python',
  -- },

  -- -- Rust (though rust-analyzer LSP handles most of this)
  -- {
  --   'rust-lang/rust.vim',
  --   ft = 'rust',
  -- },

  -- -- TOML support
  -- {
  --   'cespare/vim-toml',
  --   ft = 'toml',
  -- },

  -- -- YAML support
  -- {
  --   'stephpy/vim-yaml',
  --   ft = 'yaml',
  -- },

  -- -- Dockerfile support
  -- {
  --   'ekalinin/Dockerfile.vim',
  --   ft = 'dockerfile',
  -- },

  -- ===================================================================
  -- Notes
  -- ===================================================================
  -- Most modern language support is better handled by:
  -- 1. Treesitter (syntax highlighting, text objects)
  -- 2. LSP servers (intelligent features, diagnostics)
  -- 3. Formatters via conform.nvim
  -- 4. Linters via nvim-lint
  --
  -- These language-specific plugins are mainly for:
  -- - Languages not well supported by treesitter yet
  -- - Special file type detection
  -- - Language-specific commands or mappings
  -- - Legacy compatibility
}
