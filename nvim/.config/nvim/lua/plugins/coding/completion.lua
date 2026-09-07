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

    local SOURCE_LABELS = {
      luasnip = '[Snippet]',
      buffer = '[Buffer]',
      path = '[Path]',
      lazydev = '[LazyDev]',
      nvim_lsp_signature_help = '[Signature]',
    }

    local function truncate(text, max)
      if text and vim.fn.strdisplaywidth(text) > max then
        return vim.fn.strcharpart(text, 0, max - 1) .. '…'
      end
      return text
    end

    -- "(use std::io::BufReader)" -> "std::io"
    local function import_path(detail)
      local path = detail:match '^%(use (.+)%)$'
      return path and path:gsub('::[^:]+$', '') or nil
    end

    -- The third menu column. For LSP entries prefer the import path, then
    -- the signature; skip a detail that only repeats the kind ("(function)").
    local function item_origin(source, item, kind)
      if source ~= 'nvim_lsp' then
        return SOURCE_LABELS[source]
      end

      local details = item.labelDetails or {}
      if details.detail then
        return import_path(details.detail) or details.detail
      end

      local detail = details.description or item.detail
      if not detail or detail:lower() == ('(%s)'):format(kind:lower()) then
        return nil
      end
      return detail
    end

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
        keyword_length = 3, -- Start completion after 3 characters
      },

      -- ===================================================================
      -- Key Mappings
      -- ===================================================================
      -- See `:help ins-completion` for understanding these choices
      mapping = cmp.mapping.preset.insert {
        -- Navigation
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Documentation scrolling (the side window, while the menu is open)
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        -- Completion confirmation
        ['<C-y>'] = cmp.mapping.confirm { select = true },
        -- Enter confirms only LSP, snippet and path entries. A word
        -- repeated from the buffer never hijacks Enter.
        ['<CR>'] = cmp.mapping(function(fallback)
          if not cmp.visible() then
            return fallback()
          end

          local entry = cmp.get_selected_entry() or cmp.get_entries()[1]
          local confirmable = { 'nvim_lsp', 'luasnip', 'path', 'lazydev' }

          if entry and vim.tbl_contains(confirmable, entry.source.name) then
            return cmp.confirm { select = true }
          end

          fallback()
        end, { 'i', 's' }),

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
            -- Current buffer only. Words from a file tree, a terminal or
            -- another open file never reach the menu.
            get_bufnrs = function()
              return { vim.api.nvim_get_current_buf() }
            end,
          },
        },
      },

      -- ===================================================================
      -- Formatting and Appearance
      -- ===================================================================
      -- Three columns: name | kind | where it comes from. The last column is
      -- what tells three identical `BufReader` entries apart: rust-analyzer
      -- sends the import path in labelDetails.detail as "(use std::io::X)",
      -- Expert puts the signature straight into the label and only sends a
      -- redundant "(function)" as detail, which we drop.
      formatting = {
        fields = { 'abbr', 'kind', 'menu' },
        format = function(entry, vim_item)
          local item = entry.completion_item
          local kind = vim_item.kind

          vim_item.abbr = truncate(vim_item.abbr, 40)
          vim_item.kind = string.format('%s %s', kind_icons[kind] or '', kind)
          vim_item.menu = truncate(item_origin(entry.source.name, item, kind), 36)

          return vim_item
        end,
      },

      -- ===================================================================
      -- Window Appearance
      -- ===================================================================
      -- `border` is explicit because bordered() otherwise falls back to the
      -- global `winborder` option, which is empty and yields no border at
      -- all. Both floats use NormalFloat so the box stands out from the
      -- buffer. Docs get room to breathe: rust-analyzer hard-wraps its
      -- markdown at ~80 columns, so a narrower window re-wraps every line
      -- into an ugly long/short pair. bordered() drops max_width, hence the
      -- tbl_extend.
      window = {
        completion = cmp.config.window.bordered {
          border = 'rounded',
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        },
        documentation = vim.tbl_extend(
          'force',
          cmp.config.window.bordered {
            border = 'rounded',
            winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,Search:None',
            max_height = 24,
          },
          { max_width = 84 }
        ),
      },

      -- ===================================================================
      -- Experimental Features
      -- ===================================================================
      experimental = {
        ghost_text = false, -- No inline preview of the selected entry
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
