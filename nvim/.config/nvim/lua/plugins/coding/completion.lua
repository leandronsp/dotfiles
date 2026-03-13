-- ===================================================================
-- Completion Configuration - nvim-cmp
-- ===================================================================
-- Advanced completion engine with LSP, snippets, and multiple sources
-- See: https://github.com/hrsh7th/nvim-cmp

return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter', -- Load when entering insert mode for better startup time
  dependencies = {
    -- ===================================================================
    -- Snippet Engine - LuaSnip
    -- ===================================================================
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build regex support for snippets (not supported on Windows)
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),

      config = function()
        local luasnip = require 'luasnip'

        -- Basic LuaSnip configuration
        luasnip.config.setup {
          -- Enable autotriggered snippets
          enable_autosnippets = true,

          -- Use Tab (or some other key if you prefer) to trigger visual selection
          store_selection_keys = '<Tab>',

          -- Update events for better performance
          update_events = 'TextChanged,TextChangedI',
        }

        -- Load snippets from friendly-snippets if you want more snippets
        -- Uncomment the following lines and add 'rafamadriz/friendly-snippets' as dependency
        -- require('luasnip.loaders.from_vscode').lazy_load()

        -- Load custom snippets from snippets directory if it exists
        require('luasnip.loaders.from_lua').lazy_load { paths = { './snippets' } }
      end,
    },

    -- LuaSnip completion source
    'saadparwaiz1/cmp_luasnip',

    -- ===================================================================
    -- Completion Sources
    -- ===================================================================
    -- nvim-cmp doesn't ship with sources - they're separate plugins

    -- LSP completion (already included as dependency in lsp.lua)
    'hrsh7th/cmp-nvim-lsp',

    -- File path completion
    'hrsh7th/cmp-path',

    -- Function signature help
    'hrsh7th/cmp-nvim-lsp-signature-help',

    -- Buffer completion (words from open buffers)
    'hrsh7th/cmp-buffer',

    -- Command line completion
    'hrsh7th/cmp-cmdline',
  },

  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    -- ===================================================================
    -- Completion Menu Icons
    -- ===================================================================
    local kind_icons = {
      Text = '󰉿',
      Method = '󰆧',
      Function = '󰊕',
      Constructor = '',
      Field = '󰜢',
      Variable = '󰀫',
      Class = '󰠱',
      Interface = '',
      Module = '',
      Property = '󰜢',
      Unit = '󰑭',
      Value = '󰎠',
      Enum = '',
      Keyword = '󰌋',
      Snippet = '',
      Color = '󰏘',
      File = '󰈙',
      Reference = '󰈇',
      Folder = '󰉋',
      EnumMember = '',
      Constant = '󰏿',
      Struct = '󰙅',
      Event = '',
      Operator = '󰆕',
      TypeParameter = '',
    }

    -- ===================================================================
    -- Main Completion Setup
    -- ===================================================================
    cmp.setup {
      -- Snippet expansion
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- Completion behavior
      completion = {
        completeopt = 'menu,menuone,noinsert', -- Don't auto-insert first match
        keyword_length = 1, -- Start completion after 1 character
      },

      -- ===================================================================
      -- Key Mappings
      -- ===================================================================
      -- See `:help ins-completion` for understanding these choices
      mapping = cmp.mapping.preset.insert {
        -- Navigation
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Documentation scrolling
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- Completion confirmation
        ['<C-y>'] = cmp.mapping.confirm { select = true },
        ['<CR>'] = cmp.mapping.confirm { select = true },

        -- Tab completion (alternative to C-n/C-p)
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),

        -- Manual completion trigger
        ['<C-Space>'] = cmp.mapping.complete {},

        -- Abort completion
        ['<C-e>'] = cmp.mapping.abort(),

        -- ===================================================================
        -- Snippet Navigation
        -- ===================================================================
        -- Navigate through snippet placeholders
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),

        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      },

      -- ===================================================================
      -- Completion Sources (Ordered by Priority)
      -- ===================================================================
      sources = {
        -- Lazydev for Neovim Lua API (highest priority for Lua files)
        {
          name = 'lazydev',
          group_index = 0, -- Highest priority
        },

        -- LSP completion
        {
          name = 'nvim_lsp',
          priority = 1000,
        },

        -- Snippet completion
        {
          name = 'luasnip',
          priority = 900,
        },

        -- Path completion
        {
          name = 'path',
          priority = 800,
        },

        -- Function signature help
        {
          name = 'nvim_lsp_signature_help',
          priority = 700,
        },

        -- Buffer completion (words from open buffers)
        {
          name = 'buffer',
          priority = 600,
          option = {
            get_bufnrs = function()
              -- Complete from all visible buffers
              local bufs = {}
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                bufs[vim.api.nvim_win_get_buf(win)] = true
              end
              return vim.tbl_keys(bufs)
            end,
          },
        },
      },

      -- ===================================================================
      -- Formatting and Appearance
      -- ===================================================================
      formatting = {
        format = function(entry, vim_item)
          -- Kind icons
          vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)

          -- Source names
          vim_item.menu = ({
            nvim_lsp = '[LSP]',
            luasnip = '[Snippet]',
            buffer = '[Buffer]',
            path = '[Path]',
            lazydev = '[LazyDev]',
            nvim_lsp_signature_help = '[Signature]',
          })[entry.source.name]

          return vim_item
        end,
      },

      -- ===================================================================
      -- Window Appearance
      -- ===================================================================
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      -- ===================================================================
      -- Experimental Features
      -- ===================================================================
      experimental = {
        ghost_text = true, -- Show ghost text preview
      },
    }

    -- ===================================================================
    -- Command Line Completion
    -- ===================================================================
    -- Enable completion in command line
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
      }, {
        { name = 'cmdline' },
      }),
    })

    -- Enable completion for search
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })

    -- ===================================================================
    -- Module Exports for Testing
    -- ===================================================================
    _G.cmp_config = {
      sources = cmp.get_config().sources,
      mapping = cmp.get_config().mapping,
    }
  end,
}
