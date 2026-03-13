-- ===================================================================
-- Treesitter Configuration
-- ===================================================================
-- Advanced syntax highlighting, text objects, and code understanding
-- See: https://github.com/nvim-treesitter/nvim-treesitter

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate', -- Update parsers when plugin updates
  main = 'nvim-treesitter.configs', -- Use this as the main module for opts
  event = { 'BufReadPre', 'BufNewFile' }, -- Load when opening files

  opts = {
    -- ===================================================================
    -- Parser Installation
    -- ===================================================================
    -- Languages to ensure are installed
    -- Add more languages as needed for your projects
    ensure_installed = {
      -- Core languages for Neovim configuration
      'lua',
      'luadoc',
      'vim',
      'vimdoc',
      'query',

      -- System and shell
      'bash',

      -- Web development
      'html',
      'css',
      'javascript',
      'typescript',
      'tsx',
      'json',

      -- Systems programming
      'c',
      'rust',
      'go',

      -- Markup and data
      'markdown',
      'markdown_inline',
      'toml',
      'yaml',

      -- Git and diffs
      'diff',
      'git_config',
      'git_rebase',
      'gitcommit',
      'gitignore',

      -- Documentation
      'comment',
    },

    -- Automatically install language parsers when entering new filetypes
    auto_install = true,

    -- ===================================================================
    -- Syntax Highlighting
    -- ===================================================================
    highlight = {
      enable = true,

      -- Some languages depend on Vim's regex highlighting for indent rules
      -- Add languages here if you experience indenting issues
      additional_vim_regex_highlighting = { 'ruby' },

      -- Disable treesitter for very large files (performance)
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },

    -- ===================================================================
    -- Indentation
    -- ===================================================================
    indent = {
      enable = true,
      -- Disable for languages that have issues with treesitter indenting
      disable = { 'ruby', 'python' },
    },

    -- ===================================================================
    -- Incremental Selection
    -- ===================================================================
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = '<C-s>',
        node_decremental = '<M-space>',
      },
    },

    -- ===================================================================
    -- Text Objects
    -- ===================================================================
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['al'] = '@loop.outer',
          ['il'] = '@loop.inner',
          ['ab'] = '@block.outer',
          ['ib'] = '@block.inner',
          ['a/'] = '@comment.outer',
          ['i/'] = '@comment.inner',
        },
      },

      move = {
        enable = true,
        set_jumps = true, -- Whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
          [']l'] = '@loop.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
          [']L'] = '@loop.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
          ['[l'] = '@loop.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
          ['[L'] = '@loop.outer',
        },
      },
    },
  },

  -- ===================================================================
  -- Additional Configuration
  -- ===================================================================
  config = function(_, opts)
    -- Setup treesitter with our options
    require('nvim-treesitter.configs').setup(opts)

    -- ===================================================================
    -- Folding Setup
    -- ===================================================================
    -- Use treesitter for better code folding
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldenable = false -- Don't fold by default
    vim.opt.foldlevel = 99 -- High fold level = less folding
  end,

  -- ===================================================================
  -- Additional Treesitter Modules
  -- ===================================================================
  -- Consider adding these treesitter extensions:
  --
  -- Text Objects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  -- Context: https://github.com/nvim-treesitter/nvim-treesitter-context
  -- Refactor: https://github.com/ThePrimeagen/refactoring.nvim
}
