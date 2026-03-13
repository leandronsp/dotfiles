-- ===================================================================
-- GitHub Copilot AI Completion Configuration
-- ===================================================================
-- AI-powered code completion that works alongside nvim-cmp
-- See: https://github.com/github/copilot.vim

return {
  'github/copilot.vim',
  event = 'InsertEnter',

  config = function()
    -- ===================================================================
    -- Keymaps for AI Suggestions
    -- ===================================================================
    vim.keymap.set('i', '<C-A>', 'copilot#Accept("")', {
      expr = true,
      replace_keycodes = false,
      desc = 'Accept entire Copilot suggestion',
    })

    vim.keymap.set('i', '<C-D>', '<Plug>(copilot-dismiss)', {
      desc = 'Dismiss Copilot suggestion',
    })

    vim.keymap.set('i', '<C-j>', '<Plug>(copilot-accept-word)', {
      desc = 'Accept next word from Copilot',
    })


    -- ===================================================================
    -- Configuration Variables
    -- ===================================================================
    vim.g.copilot_no_tab_map = true

    vim.g.copilot_filetypes = {
      gitcommit = false,
      gitrebase = false,
      help = false,
      ['*'] = true,
    }

    vim.g.copilot_workspace_folders = { vim.fn.getcwd() }

    -- ===================================================================
    -- Custom Commands
    -- ===================================================================
    vim.api.nvim_create_user_command('CopilotToggle', function()
      vim.cmd 'Copilot toggle'
      local status = vim.fn['copilot#Enabled']() and 'enabled' or 'disabled'
      vim.notify('Copilot ' .. status, vim.log.levels.INFO)
    end, { desc = 'Toggle GitHub Copilot' })

    vim.api.nvim_create_user_command('CopilotStatus', function()
      vim.cmd 'Copilot status'
    end, { desc = 'Show Copilot status' })

    vim.api.nvim_create_user_command('CopilotAuth', function()
      vim.cmd 'Copilot auth'
    end, { desc = 'Authenticate with GitHub Copilot' })
  end,
}
