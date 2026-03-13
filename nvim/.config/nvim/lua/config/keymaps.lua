-- ===================================================================
-- Keymaps Configuration
-- ===================================================================
-- Custom key mappings that don't belong to specific plugins
-- Leader key is ';' (configured in options.lua)

-- ===================================================================
-- Basic Editor Keymaps
-- ===================================================================

-- Clear search highlights when pressing Escape in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Open diagnostic quickfix list
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Easier exit from terminal mode (double Escape)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ===================================================================
-- Window Navigation
-- ===================================================================
-- Move focus between windows using Ctrl + hjkl

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- ===================================================================
-- File Explorer (Neo-tree)
-- ===================================================================

-- Toggle Neo-tree file explorer
vim.keymap.set('n', '<leader>n', '<cmd>Neotree toggle<CR>', { desc = 'Toggle [N]eo-tree', silent = true })

-- Reveal current file in Neo-tree
vim.keymap.set('n', '<leader>k', '<cmd>Neotree reveal<CR>', { desc = 'Reveal in Neo-tree', silent = true })

-- ===================================================================
-- Theme and UI
-- ===================================================================

-- Toggle between dark and light theme
vim.keymap.set('n', '<leader>tt', function()
  vim.cmd [[hi clear]]

  if vim.o.background == 'dark' then
    vim.o.background = 'light'
    vim.cmd 'colorscheme everforest'
  else
    vim.o.background = 'dark'
    vim.cmd 'colorscheme everforest'
  end
end, { desc = 'Toggle [T]heme [D]ark/Light' })

-- ===================================================================
-- Markdown Tools
-- ===================================================================

-- Start Markdown preview
vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview<CR>', { desc = '[M]arkdown [P]review', silent = true })

-- ===================================================================
-- Utility Keymaps
-- ===================================================================

-- Copy current file's full path to clipboard
vim.keymap.set('n', '<leader>cz', ':let @+ = expand("%:p")<CR>', {
  desc = '[C]opy file path to clipboard',
  noremap = true,
  silent = true,
})

-- ===================================================================
-- Function to Setup Plugin-Specific Keymaps
-- ===================================================================
-- This will be called by plugins that need to set up keymaps

local M = {}

-- Setup Snacks keymaps (called from snacks plugin configuration)
function M.setup_snacks_keymaps()
  local snacks = require 'snacks'

  -- File and text search
  vim.keymap.set('n', '<leader>sh', function()
    snacks.picker.help()
  end, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', function()
    snacks.picker.keymaps()
  end, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', function()
    snacks.picker.files()
  end, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<C-p>', function()
    snacks.picker.files()
  end, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', function()
    snacks.picker.pickers()
  end, { desc = '[S]earch [S]elect Snacks' })
  vim.keymap.set('n', '<leader>sw', function()
    snacks.picker.grep_word()
  end, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', function()
    snacks.picker.grep()
  end, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<C-f>', function()
    snacks.picker.grep()
  end, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', function()
    snacks.picker.diagnostics()
  end, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', function()
    snacks.picker.resume()
  end, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', function()
    snacks.picker.recent()
  end, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<C-i>', function()
    snacks.picker.recent()
  end, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader><leader>', function()
    snacks.picker.buffers()
  end, { desc = '[ ] Find existing buffers' })

  -- Advanced search functions
  vim.keymap.set('n', '<leader>/', function()
    snacks.picker.lines()
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<leader>s/', function()
    snacks.picker.grep {
      open_files_only = true,
      prompt = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  -- Search Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function()
    snacks.picker.files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [N]eovim files' })

  -- Git-related pickers (snacks enhancement)
  vim.keymap.set('n', '<leader>gb', function()
    snacks.picker.git_branches()
  end, { desc = '[G]it [B]ranches' })
  vim.keymap.set('n', '<leader>gc', function()
    snacks.picker.git_log()
  end, { desc = '[G]it [C]ommits' })
  vim.keymap.set('n', '<leader>gs', function()
    snacks.picker.git_status()
  end, { desc = '[G]it [S]tatus' })
end

-- Setup LSP keymaps (called when LSP attaches)
function M.setup_lsp_keymaps(event)
  -- Helper function for setting buffer-local keymaps
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  -- Navigation
  map('gd', function()
    require('snacks').picker.lsp_definitions()
  end, '[G]oto [D]efinition')
  map('gr', function()
    require('snacks').picker.lsp_references()
  end, '[G]oto [R]eferences')
  map('gI', function()
    require('snacks').picker.lsp_implementations()
  end, '[G]oto [I]mplementation')
  map('<leader>D', function()
    require('snacks').picker.lsp_type_definitions()
  end, 'Type [D]efinition')

  -- Symbols and workspace
  map('<leader>ds', function()
    require('snacks').picker.lsp_symbols()
  end, '[D]ocument [S]ymbols')
  map('<leader>ws', function()
    require('snacks').picker.lsp_workspace_symbols()
  end, '[W]orkspace [S]ymbols')

  -- Code actions
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
end

-- Setup inlay hints toggle if supported
function M.setup_inlay_hints(client, bufnr)
  local function client_supports_method(client, method, bufnr)
    if vim.fn.has 'nvim-0.11' == 1 then
      return client:supports_method(method, bufnr)
    else
      return client.supports_method(method, { bufnr = bufnr })
    end
  end

  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
    vim.keymap.set('n', '<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
    end, { buffer = bufnr, desc = '[T]oggle Inlay [H]ints' })
  end
end

return M
