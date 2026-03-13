-- ===================================================================
-- Code Formatting Configuration - Conform.nvim
-- ===================================================================
-- Automatic code formatting with multiple formatter support
-- See: https://github.com/stevearc/conform.nvim

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' }, -- Load before saving files
  cmd = { 'ConformInfo' }, -- Load when running ConformInfo command

  -- Setup keymap for manual formatting
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format {
          async = true, -- Don't block while formatting
          lsp_format = 'fallback', -- Use LSP if no formatter available
        }
      end,
      mode = '', -- Available in normal and visual mode
      desc = '[F]ormat buffer',
    },
  },

  opts = {
    -- ===================================================================
    -- Formatter Configuration by File Type
    -- ===================================================================
    formatters_by_ft = {
      -- Lua
      lua = { 'stylua' },

      -- Web Development
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      scss = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      jsonc = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },

      -- Python (run multiple formatters in sequence)
      python = { 'isort', 'black' },

      -- Rust (rustfmt is usually handled by LSP)
      rust = { 'rustfmt' },

      -- Go
      go = { 'gofmt' },

      -- Shell scripts
      sh = { 'shfmt' },
      bash = { 'shfmt' },

      -- C/C++
      c = { 'clang-format' },
      cpp = { 'clang-format' },

      -- TOML
      toml = { 'taplo' },

      -- Add more formatters as needed for your languages
      -- See: https://github.com/stevearc/conform.nvim#formatters
    },

    -- ===================================================================
    -- Format on Save Configuration
    -- ===================================================================
    format_on_save = function(bufnr)
      -- Disable format-on-save for languages that don't have well-standardized
      -- coding styles or where it might be disruptive
      local disable_filetypes = {
        c = true,
        cpp = true,
        -- Add other filetypes here if needed
      }

      -- Check if formatting should be disabled for this filetype
      local filetype = vim.bo[bufnr].filetype
      local lsp_format_opt

      if disable_filetypes[filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback' -- Use LSP formatting if no formatter available
      end

      return {
        timeout_ms = 500, -- Maximum time to wait for formatting
        lsp_format = lsp_format_opt,
      }
    end,

    -- ===================================================================
    -- General Options
    -- ===================================================================
    -- Don't show error notifications (errors still appear in :ConformInfo)
    notify_on_error = false,

    -- Log level for debugging
    log_level = vim.log.levels.WARN,

    -- ===================================================================
    -- Custom Formatter Configurations
    -- ===================================================================
    formatters = {
      -- Example: Custom stylua configuration
      stylua = {
        prepend_args = {
          '--indent-type',
          'Spaces',
          '--indent-width',
          '2',
          '--column-width',
          '120',
        },
      },

      -- Example: Custom prettier configuration
      prettier = {
        prepend_args = {
          '--tab-width',
          '2',
          '--single-quote',
          'true',
          '--trailing-comma',
          'es5',
        },
      },

      -- Example: Custom black configuration for Python
      black = {
        prepend_args = {
          '--line-length',
          '88',
          '--quiet',
        },
      },

      -- Example: Custom shfmt configuration for shell scripts
      shfmt = {
        prepend_args = {
          '-i',
          '2', -- 2 space indentation
          '-ci', -- indent switch cases
        },
      },
    },
  },

  -- ===================================================================
  -- Additional Configuration
  -- ===================================================================
  config = function(_, opts)
    require('conform').setup(opts)

    -- Add a command to toggle format-on-save
    vim.api.nvim_create_user_command('ConformToggle', function()
      if vim.g.conform_format_on_save then
        vim.g.conform_format_on_save = false
        vim.notify('Format-on-save disabled', vim.log.levels.INFO)
      else
        vim.g.conform_format_on_save = true
        vim.notify('Format-on-save enabled', vim.log.levels.INFO)
      end
    end, { desc = 'Toggle format-on-save' })

    -- Add a command to format the entire buffer range
    vim.api.nvim_create_user_command('Format', function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ['end'] = { args.line2, end_line:len() },
        }
      end
      require('conform').format { async = true, lsp_format = 'fallback', range = range }
    end, { range = true, desc = 'Format buffer or range' })

    -- Export configuration for testing
    _G.conform_config = opts
  end,
}
