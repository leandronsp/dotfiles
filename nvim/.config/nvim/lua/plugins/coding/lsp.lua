-- ===================================================================
-- LSP Configuration - Language Server Protocol
-- ===================================================================
-- Complete LSP setup with Mason for automatic server management
-- See: https://github.com/neovim/nvim-lspconfig
-- See: https://github.com/williamboman/mason.nvim

return {
  -- ===================================================================
  -- LazyDev - Lua LSP for Neovim Configuration
  -- ===================================================================
  -- Enhanced Lua LSP specifically for Neovim config development
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- Only load for Lua files
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- ===================================================================
  -- Main LSP Configuration
  -- ===================================================================
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason must be loaded first
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- LSP status updates
      { 'j-hui/fidget.nvim', opts = {} },

      -- Enhanced capabilities from nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },

    config = function()
      -- ===================================================================
      -- What is LSP?
      -- ===================================================================
      -- LSP (Language Server Protocol) enables editors and language tooling
      -- to communicate in a standardized way. Language servers like `lua_ls`,
      -- `rust_analyzer`, `gopls` run as separate processes and provide:
      --
      -- - Go to definition/references
      -- - Autocompletion
      -- - Symbol search
      -- - Error diagnostics
      -- - Code actions and refactoring
      -- - Hover documentation
      --
      -- Mason automatically installs and manages these language servers.
      -- See `:help lsp-vs-treesitter` for LSP vs Treesitter comparison.

      -- ===================================================================
      -- Diagnostic Configuration
      -- ===================================================================
      -- Configure how LSP diagnostics are displayed
      vim.diagnostic.config {
        -- Sort diagnostics by severity (errors first)
        severity_sort = true,

        -- Floating window style for diagnostic details
        float = {
          border = 'rounded',
          source = 'if_many', -- Show source if multiple sources
        },

        -- Only underline errors (reduce visual noise)
        underline = {
          severity = vim.diagnostic.severity.ERROR,
        },

        -- Sign column icons (if Nerd Font available)
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},

        -- Virtual text configuration
        virtual_text = {
          source = 'if_many', -- Show source if multiple
          spacing = 2, -- Space between text and diagnostic
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }

      -- ===================================================================
      -- LSP Capabilities
      -- ===================================================================
      -- Extend default LSP capabilities with completion support
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- ===================================================================
      -- Language Server Configuration
      -- ===================================================================
      -- Define language servers and their specific settings
      -- Add/remove servers as needed for your projects
      local servers = {
        -- Rust Language Server
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              -- Use Clippy for enhanced linting
              checkOnSave = {
                command = 'clippy',
              },

              -- Enable all Cargo features
              cargo = {
                allFeatures = true,
              },

              -- Enable procedural macros
              procMacro = {
                enable = true,
              },

              -- Import configuration
              assist = {
                importGranularity = 'module',
                importPrefix = 'self',
              },

              -- Enhanced diagnostics
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },

              -- Inlay hints for better code understanding
              inlayHints = {
                enable = true,
                parameterHints = {
                  enable = true,
                },
                typeHints = {
                  enable = true,
                },
              },
            },
          },
        },

        -- Lua Language Server (for Neovim configuration)
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- Uncomment to disable noisy missing-fields warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        -- Add more servers as needed:
        -- Go: gopls = {}
        -- Python: pyright = {} or pylsp = {}
        -- JavaScript/TypeScript: ts_ls = {}
        -- C/C++: clangd = {}
        -- See `:help lspconfig-all` for complete list
      }

      -- ===================================================================
      -- Mason Tool Installation
      -- ===================================================================
      -- Automatically install language servers and related tools
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Lua formatter
        -- Add other tools as needed:
        -- 'prettier', 'eslint_d', 'black', 'isort', etc.
      })

      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }

      -- ===================================================================
      -- LSP Server Setup
      -- ===================================================================
      require('mason-lspconfig').setup {
        -- Don't auto-install here (use mason-tool-installer instead)
        ensure_installed = {},
        automatic_installation = false,

        -- Handler for each language server
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}

            -- Merge server-specific capabilities with defaults
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

            -- Setup the language server
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      -- ===================================================================
      -- Module Exports for Testing
      -- ===================================================================
      -- Export server configuration for testing purposes
      _G.lsp_servers = servers
      _G.lsp_capabilities = capabilities
    end,
  },
}
