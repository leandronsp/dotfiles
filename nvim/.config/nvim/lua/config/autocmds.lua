-- ===================================================================
-- Autocommands Configuration
-- ===================================================================
-- Custom autocommands for editor behavior and UI improvements
-- See `:help lua-guide-autocommands` for more information

-- ===================================================================
-- Editor Experience Improvements
-- ===================================================================

-- Highlight text when it's yanked (copied) - provides visual feedback
-- Try it with `yap` in normal mode to see the effect
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ===================================================================
-- UI and Window Management
-- ===================================================================

-- Auto-quit Neo-tree when it's the last window open
-- Prevents Neovim from staying open with only Neo-tree visible
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Quit Neo-tree when it is the last window',
  group = vim.api.nvim_create_augroup('neotree-auto-quit', { clear = true }),
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == 'neo-tree' then
      vim.cmd 'quit'
    end
  end,
})

-- ===================================================================
-- LSP Autocommands Module
-- ===================================================================
-- Functions to be called by LSP configuration when setting up language servers

local M = {}

-- Setup LSP attachment autocommand - called from LSP plugin configuration
function M.setup_lsp_attach()
  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'Setup LSP keymaps and features when LSP attaches to buffer',
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- Load keymap setup function from keymaps module
      local keymaps = require 'config.keymaps'
      keymaps.setup_lsp_keymaps(event)

      -- Setup document highlighting if supported by LSP client
      M.setup_document_highlight(event)

      -- Setup inlay hints toggle if supported by LSP client
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client then
        keymaps.setup_inlay_hints(client, event.buf)
      end
    end,
  })
end

-- Setup document highlighting (called internally by setup_lsp_attach)
function M.setup_document_highlight(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)

  -- Helper function to check if client supports a specific method
  local function client_supports_method(client, method, bufnr)
    if vim.fn.has 'nvim-0.11' == 1 then
      return client:supports_method(method, bufnr)
    else
      return client.supports_method(method, { bufnr = bufnr })
    end
  end

  -- Setup document highlighting if supported
  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

    -- Highlight references under cursor when holding still
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    -- Clear highlights when cursor moves
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    -- Clean up highlights when LSP detaches
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
      end,
    })
  end
end

return M
