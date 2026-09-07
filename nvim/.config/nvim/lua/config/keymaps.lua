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

-- ===================================================================
-- LSP Actions
-- ===================================================================
-- One row per action. `desc` is the which-key label, `hint` is the plain
-- sentence the <leader>? cheat sheet shows, `method` is what the server
-- must support for the key to exist. No `func` means the key is mapped
-- elsewhere (see setup_inlay_hints), the row is there only for the sheet.
local ms = vim.lsp.protocol.Methods

-- Neovim's own K and <C-s> open borderless floats as wide as the screen
-- (the global `winborder` is empty). Same size as the cmp docs window so
-- the two look alike. rust-analyzer hard-wraps markdown at ~80 columns.
local FLOAT = { border = 'rounded', max_width = 84, max_height = 24 }

local function picker(name)
  return function()
    require('snacks').picker[name]()
  end
end

local LSP_ACTIONS = {
  -- Read
  {
    group = 'Read',
    key = 'K',
    desc = 'Hover',
    method = ms.textDocument_hover,
    hint = 'Docs, type and signature of what is under the cursor. K again enters the popup.',
    func = function()
      vim.lsp.buf.hover(FLOAT)
    end,
  },
  {
    group = 'Read',
    key = 'gK',
    desc = 'Docs in a split',
    method = ms.textDocument_hover,
    hint = 'Same docs as K, in a full-height side window. q closes.',
    func = function()
      M.lsp_docs_split()
    end,
  },
  {
    group = 'Read',
    key = '<C-s>',
    desc = 'Signature help',
    method = ms.textDocument_signatureHelp,
    hint = 'While typing a call, show its parameters. Insert mode.',
    func = function()
      vim.lsp.buf.signature_help(FLOAT)
    end,
    mode = 'i',
  },
  {
    group = 'Read',
    key = '<leader>th',
    desc = '[T]oggle Inlay [H]ints',
    method = ms.textDocument_inlayHint,
    hint = 'Show or hide inferred types and parameter names inline.',
  },

  -- Navigate
  {
    group = 'Navigate',
    key = 'gd',
    desc = '[G]oto [D]efinition',
    method = ms.textDocument_definition,
    hint = 'Jump to where this is defined.',
    func = picker 'lsp_definitions',
  },
  {
    group = 'Navigate',
    key = 'gr',
    desc = '[G]oto [R]eferences',
    method = ms.textDocument_references,
    hint = 'List every place this is used.',
    func = picker 'lsp_references',
  },
  {
    group = 'Navigate',
    key = 'gI',
    desc = '[G]oto [I]mplementation',
    method = ms.textDocument_implementation,
    hint = 'From a trait or behaviour, jump to the concrete implementations.',
    func = picker 'lsp_implementations',
  },
  {
    group = 'Navigate',
    key = '<leader>D',
    desc = 'Type [D]efinition',
    method = ms.textDocument_typeDefinition,
    hint = 'Jump to the type of this variable, not to the variable itself.',
    func = picker 'lsp_type_definitions',
  },
  {
    group = 'Navigate',
    key = 'gD',
    desc = '[G]oto [D]eclaration',
    method = ms.textDocument_declaration,
    hint = 'C-style declaration. Rarely differs from gd in Rust or Elixir.',
    func = vim.lsp.buf.declaration,
  },

  -- Explore
  {
    group = 'Explore',
    key = '<leader>ds',
    desc = '[D]ocument [S]ymbols',
    method = ms.textDocument_documentSymbol,
    hint = 'Outline of this file: functions, types, modules.',
    func = picker 'lsp_symbols',
  },
  {
    group = 'Explore',
    key = '<leader>ws',
    desc = '[W]orkspace [S]ymbols',
    method = ms.workspace_symbol,
    hint = 'Search a symbol by name across the whole project.',
    func = picker 'lsp_workspace_symbols',
  },

  -- Change
  {
    group = 'Change',
    key = '<leader>rn',
    desc = '[R]e[n]ame',
    method = ms.textDocument_rename,
    hint = 'Rename this symbol everywhere it is used.',
    func = vim.lsp.buf.rename,
  },
  {
    group = 'Change',
    key = '<leader>ca',
    desc = '[C]ode [A]ction',
    method = ms.textDocument_codeAction,
    hint = 'Fixes and refactors the server offers at the cursor.',
    func = vim.lsp.buf.code_action,
    mode = { 'n', 'x' },
  },
}

local GROUPS = { 'Read', 'Navigate', 'Explore', 'Change' }

-- Does any client attached to this buffer implement the method?
local function supports(bufnr, method)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client:supports_method(method, bufnr) then
      return true
    end
  end

  return false
end

-- Render `<leader>` as the actual leader key so the sheet shows what to press.
local function display_key(key)
  local leader = vim.g.mapleader or '\\'
  if leader == ' ' then
    leader = '<Space>'
  end
  return (key:gsub('<leader>', leader))
end

-- Full documentation of the symbol under the cursor in a vertical split,
-- rendered as markdown. It is the same hover payload K shows, without the
-- size limits of the float, so long docs (std, Enum, GenServer) fit.
function M.lsp_docs_split()
  local bufnr = vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(bufnr, ms.textDocument_hover, function(client)
    return vim.lsp.util.make_position_params(0, client.offset_encoding)
  end, function(err, result)
    local lines = result and result.contents and vim.lsp.util.convert_input_to_markdown_lines(result.contents) or {}

    if err or vim.tbl_isempty(lines) then
      return vim.notify('No documentation under the cursor', vim.log.levels.INFO)
    end

    local doc = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(doc, 0, -1, false, lines)
    vim.bo[doc].filetype = 'markdown'
    vim.bo[doc].modifiable = false
    vim.bo[doc].bufhidden = 'wipe'

    vim.cmd 'vsplit'
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, doc)
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = 'no'
    vim.wo[win].conceallevel = 2

    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = doc, nowait = true })
  end)
end

-- Cheat sheet for the current buffer: a focused floating window listing
-- what this language's server implements, grouped by intent, with the
-- unsupported actions dimmed at the bottom. j/k scroll, q closes.
function M.lsp_cheatsheet(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  if #clients == 0 then
    return vim.notify('No LSP attached to this buffer', vim.log.levels.WARN)
  end

  local KEY_WIDTH = 10
  local lines, marks = {}, {}

  -- Append a line, optionally recording a highlight for a column range.
  local function add(text, hl_group, col_start, col_end)
    table.insert(lines, text)
    if hl_group then
      table.insert(marks, { #lines - 1, col_start or 0, col_end or #text, hl_group })
    end
  end

  local function add_row(action, dim)
    local key = display_key(action.key)
    local text = ('  %-' .. KEY_WIDTH .. 's  %s'):format(key, action.hint)
    add(text, dim and 'Comment' or 'Special', 2, 2 + #key)
    if not dim then
      table.insert(marks, { #lines - 1, 2 + KEY_WIDTH + 2, #text, 'Normal' })
    end
  end

  local missing = {}

  for _, group in ipairs(GROUPS) do
    local rows = {}
    for _, action in ipairs(LSP_ACTIONS) do
      if action.group == group then
        if supports(bufnr, action.method) then
          table.insert(rows, action)
        else
          table.insert(missing, action)
        end
      end
    end

    if #rows > 0 then
      add(group, 'Title')
      for _, action in ipairs(rows) do
        add_row(action, false)
      end
      add ''
    end
  end

  if #missing > 0 then
    add('Not supported by this server', 'Comment')
    for _, action in ipairs(missing) do
      add_row(action, true)
    end
  else
    table.remove(lines) -- trailing blank line
  end

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 2, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 6)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'

  local ns = vim.api.nvim_create_namespace 'lsp_cheatsheet'
  for _, mark in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, mark[1], mark[2], { end_col = mark[3], hl_group = mark[4] })
  end

  local names = vim.tbl_map(function(client)
    return client.name
  end, clients)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    title = (' %s  %s '):format(table.concat(names, ', '), vim.bo[bufnr].filetype),
    title_pos = 'center',
    footer = ' j/k scroll   q close ',
    footer_pos = 'center',
  })
  vim.wo[win].cursorline = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  for _, key in ipairs { 'q', '<Esc>', '<leader>?' } do
    vim.keymap.set('n', key, close, { buffer = buf, nowait = true })
  end
end

-- Setup LSP keymaps (called when LSP attaches)
function M.setup_lsp_keymaps(event)
  for _, action in ipairs(LSP_ACTIONS) do
    -- No func: Neovim maps it on its own, the row exists only so the
    -- action shows up in the cheat sheet.
    if action.func and supports(event.buf, action.method) then
      vim.keymap.set(action.mode or 'n', action.key, action.func, { buffer = event.buf, desc = 'LSP: ' .. action.desc })
    end
  end

  vim.keymap.set('n', '<leader>?', function()
    M.lsp_cheatsheet(event.buf)
  end, { buffer = event.buf, desc = 'LSP: what this server supports' })
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
