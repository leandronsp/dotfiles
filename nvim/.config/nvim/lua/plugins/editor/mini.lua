-- ===================================================================
-- Mini.nvim Configuration
-- ===================================================================
-- Collection of small, independent plugins that enhance text editing
-- See: https://github.com/echasnovski/mini.nvim

return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',

  config = function()
    -- ===================================================================
    -- Mini.ai - Better Around/Inside Text Objects
    -- ===================================================================
    -- Enhances the built-in text objects with more intelligent selection
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)] parentheses
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside ['] single quotes
    --  - daf  - [D]elete [A]round [F]unction
    --  - vib  - [V]isually select [I]nside [B]rackets

    require('mini.ai').setup {
      -- Number of lines within which textobjects are searched
      n_lines = 500,

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Main textobject prefixes
        around = 'a',
        inside = 'i',

        -- Next/last variants
        around_next = 'an',
        inside_next = 'in',
        around_last = 'al',
        inside_last = 'il',

        -- Move cursor to corresponding edge of `a` textobject
        goto_left = 'g[',
        goto_right = 'g]',
      },

      -- Custom text objects
      custom_textobjects = {
        -- Entire buffer
        e = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = vim.fn.line '$',
            col = math.max(vim.fn.getline('$'):len(), 1),
          }
          return { from = from, to = to }
        end,

        -- Function definition (works with treesitter)
        f = require('mini.ai').gen_spec.treesitter {
          a = '@function.outer',
          i = '@function.inner',
        },

        -- Class definition
        c = require('mini.ai').gen_spec.treesitter {
          a = '@class.outer',
          i = '@class.inner',
        },

        -- Arguments/parameters
        a = require('mini.ai').gen_spec.treesitter {
          a = '@parameter.outer',
          i = '@parameter.inner',
        },
      },
    }

    -- ===================================================================
    -- Mini.surround - Add/Delete/Replace Surroundings
    -- ===================================================================
    -- Efficiently work with surroundings (brackets, quotes, tags, etc.)
    --
    -- Examples:
    --  - saiw) - [S]urround [A]dd [I]nner [W]ord with [)] parentheses
    --  - sd'   - [S]urround [D]elete ['] single quotes
    --  - sr)'  - [S]urround [R]eplace [)] with ['] (parens to quotes)
    --  - sf)   - [S]urround [F]ind [)] next parentheses
    --  - sh    - [S]urround [H]ighlight current surroundings

    require('mini.surround').setup {
      -- Add custom surroundings to be used on top of builtin ones
      custom_surroundings = {
        -- Example: LaTeX math mode
        ['$'] = {
          input = { '%$(.-)%$' },
          output = { left = '$', right = '$' },
        },

        -- Example: Function call
        ['f'] = {
          input = { '%w+%((.-)%)' },
          output = function()
            local fname = vim.fn.input 'Function name: '
            return { left = fname .. '(', right = ')' }
          end,
        },
      },

      -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
      highlight_duration = 500,

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`
      },

      -- Number of lines within which surrounding is searched
      n_lines = 20,

      -- Whether to respect selection type:
      -- - Place surroundings on separate lines in linewise mode
      -- - Place surroundings on each line in blockwise mode
      respect_selection_type = false,

      -- How to search for surrounding (first inside current line, then inside
      -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
      -- 'cover_or_nearest', 'next', 'prev', 'nearest'
      search_method = 'cover',

      -- Whether to disable showing non-error feedback
      silent = false,
    }

    -- ===================================================================
    -- Mini.comment - Smart Commenting
    -- ===================================================================
    -- Smart and powerful commenting that respects language syntax
    --
    -- Examples:
    --  - gc  - Toggle comment for selection/motion
    --  - gcc - Toggle comment for current line
    --  - gco - Comment line below and enter insert mode
    --  - gcO - Comment line above and enter insert mode

    require('mini.comment').setup {
      -- Options for comment formatting
      options = {
        -- Function to compute custom 'commentstring' (optional)
        custom_commentstring = nil,

        -- Whether to ignore blank lines when commenting
        ignore_blank_line = false,

        -- Whether to recognize tabstop for indentation
        start_of_line = false,

        -- Whether to force single space inner padding for comment parts
        pad_comment_parts = true,
      },

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = 'gc',

        -- Toggle comment on current line
        comment_line = 'gcc',

        -- Toggle comment on visual selection
        comment_visual = 'gc',

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        textobject = 'gc',
      },

      -- Hook functions to be executed at certain stage of commenting
      hooks = {
        -- Before successful commenting. Does nothing by default.
        pre = function() end,
        -- After successful commenting. Does nothing by default.
        post = function() end,
      },
    }

    -- ===================================================================
    -- Mini.pairs - Auto Pairs
    -- ===================================================================
    -- Automatically insert, delete, and manage bracket/quote pairs

    require('mini.pairs').setup {
      -- In which modes mappings from this `config` should be created
      modes = { insert = true, command = false, terminal = false },

      -- Global mappings. Each right hand side should be a pair information, a
      -- table with at least these fields (see more in help):
      -- - <action> - one of 'open', 'close', 'closeopen'
      -- - <pair> - two character string for pair to be used
      -- By default pair is not inserted after `\`, quotes are not recognized by
      -- `<CR>`, `'` does not insert pair after a letter.
      mappings = {
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

        [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
        [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
        ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
      },
    }

    -- Note: We're not setting up mini.statusline here since we're using lualine
    -- which provides more comprehensive status line functionality
  end,
}
