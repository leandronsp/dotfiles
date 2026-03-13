-- ===================================================================
-- Markdown Tools Configuration
-- ===================================================================
-- Live markdown preview in browser
-- See: https://github.com/iamcco/markdown-preview.nvim

return {
  {
    'ellisonleao/glow.nvim',
    cmd = 'Glow',
    ft = 'markdown',
    config = function()
      require('glow').setup {
        border = 'rounded',
        width_ratio = 0.85,
        height_ratio = 0.85,
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          vim.keymap.set('n', '<leader>mg', '<cmd>Glow<CR>', { buffer = true, silent = true, desc = '[M]arkdown [G]low preview' })
        end,
      })
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' }, -- Only load for markdown files

    -- Build the plugin when installed/updated
    build = function()
      vim.fn['mkdp#util#install']()
    end,

    config = function()
      -- ===================================================================
      -- Markdown Preview Configuration
      -- ===================================================================

      -- Auto-start preview when opening markdown files
      vim.g.mkdp_auto_start = 0 -- 0 = manual start, 1 = auto start

      -- Auto-close preview when switching away from markdown buffer
      vim.g.mkdp_auto_close = 1

      -- Refresh markdown on save or when leaving insert mode
      vim.g.mkdp_refresh_slow = 0

      -- Specify browser to open preview
      -- Empty string = use default browser
      vim.g.mkdp_browser = ''

      -- Preview server options
      vim.g.mkdp_echo_preview_url = 0 -- Echo preview URL
      vim.g.mkdp_port = '' -- Empty = auto select port
      vim.g.mkdp_page_title = '「${name}」' -- Preview page title

      -- ===================================================================
      -- Theme and Styling
      -- ===================================================================

      -- Use dark theme that matches our Everforest colorscheme
      vim.g.mkdp_theme = 'dark'

      -- Custom CSS for better integration (optional)
      -- vim.g.mkdp_markdown_css = ''
      -- vim.g.mkdp_highlight_css = ''

      -- ===================================================================
      -- Markdown Processing Options
      -- ===================================================================

      -- Enable front matter processing
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0, -- Sync scroll between editor and preview
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1, -- Hide YAML metadata in preview
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false, -- Make preview content non-editable
        disable_filename = 0, -- Show filename in preview
        toc = {}, -- Table of contents options
      }

      -- ===================================================================
      -- File Type Support
      -- ===================================================================

      -- Recognized file types for markdown preview
      vim.g.mkdp_filetypes = { 'markdown' }

      -- ===================================================================
      -- Custom Keymaps
      -- ===================================================================
      -- Note: The main keymap `;mp` is defined in config/keymaps.lua
      -- Here we add buffer-local keymaps for markdown files only

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          local opts = { buffer = true, silent = true }

          -- Additional markdown-specific keymaps
          vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview<CR>', vim.tbl_extend('force', opts, { desc = '[M]arkdown [P]review' }))

          vim.keymap.set('n', '<leader>ms', '<cmd>MarkdownPreviewStop<CR>', vim.tbl_extend('force', opts, { desc = '[M]arkdown [S]top' }))

          vim.keymap.set('n', '<leader>mt', '<cmd>MarkdownPreviewToggle<CR>', vim.tbl_extend('force', opts, { desc = '[M]arkdown [T]oggle' }))
        end,
      })

      -- ===================================================================
      -- Integration with Other Plugins
      -- ===================================================================

      -- Ensure markdown files get proper syntax highlighting
      vim.api.nvim_create_autocmd('BufRead', {
        pattern = '*.md',
        callback = function()
          vim.bo.filetype = 'markdown'
        end,
      })

      -- ===================================================================
      -- Useful Commands
      -- ===================================================================
      -- The plugin provides these commands:
      -- :MarkdownPreview       - Start preview
      -- :MarkdownPreviewStop   - Stop preview
      -- :MarkdownPreviewToggle - Toggle preview
    end,
  },
}
