-- Pi Bridge: send text from Neovim to pi coding agent
--
-- Two commands:
--   :PiPrompt [range]  Send selection (or current paragraph) to pi's editor
--   :PiBuffer           Open scratch buffer, save sends content to pi
--
-- Writes to /tmp/pi-nvim-bridge.md which pi's nvim-bridge extension watches.

return {
  "leandronsp/pi-bridge",
  -- No repo — this is local-only, just need lazy to run config()
  dir = vim.fn.stdpath("config") .. "/lua/plugins/tools",
  lazy = false, -- Load at startup so commands are always available
  config = function()
    local BRIDGE_FILE = "/tmp/pi-nvim-bridge.md"

    local function send_to_pi(lines)
      local text = vim.trim(table.concat(lines, "\n"))
      if text == "" then
        vim.notify("Pi: nothing to send (empty selection)", vim.log.levels.WARN)
        return
      end
      vim.fn.writefile(vim.split(text, "\n"), BRIDGE_FILE)
      vim.notify("Pi: sent " .. #lines .. " lines to prompt", vim.log.levels.INFO)
    end

    -- :PiImage — saves clipboard image and inserts ![clipboard](path)
    vim.api.nvim_create_user_command("PiImage", function()
      local result = vim.fn.system("pi-img")
      local path = vim.trim(result)
      if path == "" or vim.startswith(path, "ERROR") then
        vim.notify("Pi: no image in clipboard", vim.log.levels.WARN)
        return
      end
      -- Insert markdown image at cursor
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { "![clipboard](" .. path .. ")" })
      vim.notify("Pi: inserted " .. path, vim.log.levels.INFO)
    end, { desc = "Insert clipboard image into PiBuffer" })

    -- :PiFile — sends the entire current file to pi with filename context
    vim.api.nvim_create_user_command("PiFile", function()
      local filepath = vim.api.nvim_buf_get_name(0)
      local filename = vim.fn.fnamemodify(filepath, ":t")
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      if #lines == 1 and lines[1] == "" then
        vim.notify("Pi: empty buffer, nothing to send", vim.log.levels.WARN)
        return
      end

      local ext = vim.fn.fnamemodify(filepath, ":e")
      local lang = ext ~= "" and ext or ""
      local header = { "[File: " .. filename .. "]", "```" .. lang }
      local footer = { "```" }
      local all = vim.list_extend(header, lines)
      all = vim.list_extend(all, footer)
      send_to_pi(all)
    end, { desc = "Send entire current file to pi" })

    -- :PiPrompt — grabs visual selection or falls back to current paragraph
    vim.api.nvim_create_user_command("PiPrompt", function(opts)
      local lines
      if opts.range > 0 then
        lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
      else
        -- No selection: grab current paragraph (delimited by blank lines)
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row = cursor[1]
        local total = vim.api.nvim_buf_line_count(0)
        local start_row = row
        local end_row = row
        while start_row > 1 do
          if vim.trim(vim.api.nvim_buf_get_lines(0, start_row - 2, start_row - 1, false)[1] or "") == "" then
            break
          end
          start_row = start_row - 1
        end
        while end_row < total do
          if vim.trim(vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1] or "") == "" then
            break
          end
          end_row = end_row + 1
        end
        lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
      end
      send_to_pi(lines)
    end, { range = true, desc = "Send selection or paragraph to pi prompt" })

    -- :PiBuffer — opens (or reuses) a scratch buffer for composing a prompt
    vim.api.nvim_create_user_command("PiBuffer", function()
      local buf = vim.fn.bufnr("pi-prompt.md")
      local is_new = buf == -1

      if is_new then
        buf = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_buf_set_name(buf, "pi-prompt.md")
        vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
        vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

        vim.api.nvim_create_autocmd("BufWriteCmd", {
          buffer = buf,
          callback = function()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local text = table.concat(lines, "\n")
            -- Only send if content changed since last :w
            local hash = vim.fn.sha256(text)
            if hash == vim.b.pi_last_hash then
              vim.notify("Pi: not sent (unchanged)", vim.log.levels.WARN)
              vim.api.nvim_set_option_value("modified", false, { buf = buf })
              return
            end
            vim.b.pi_last_hash = hash
            send_to_pi(lines)
            vim.api.nvim_set_option_value("modified", false, { buf = buf })
          end,
        })

        vim.keymap.set("n", "q", function()
          vim.api.nvim_buf_delete(buf, { force = true })
        end, { buffer = buf, desc = "Close pi buffer" })
      end

      -- Timer: poll for new terminal notes while buffer is open
      local notes_file = "/tmp/pi-nvim-notes.md"
      local notes_mtime = vim.fn.getftime(notes_file)
      local timer = vim.loop.new_timer()
      timer:start(1000, 1000, vim.schedule_wrap(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          timer:close()
          return
        end
        local new_mtime = vim.fn.getftime(notes_file)
        if new_mtime > notes_mtime then
          notes_mtime = new_mtime
          local notes = vim.fn.readfile(notes_file)
          if #notes > 0 then
            local last = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_buf_set_lines(buf, last, last, false, notes)
            vim.fn.writefile({}, notes_file)
            notes_mtime = -1
            vim.notify("Pi: " .. #notes .. " lines from terminal", vim.log.levels.INFO)
          end
        end
      end))

      -- Append terminal notes if any (appended via 'P' in tmux copy mode)
      if vim.fn.filereadable(notes_file) == 1 then
        local notes = vim.fn.readfile(notes_file)
        if #notes > 0 then
          -- Append at end of buffer
          local last = vim.api.nvim_buf_line_count(buf)
          vim.api.nvim_buf_set_lines(buf, last, last, false, notes)
          vim.fn.writefile({}, notes_file)
          vim.notify("Pi: appended " .. #notes .. " lines from terminal", vim.log.levels.INFO)
        end
      end

      vim.api.nvim_set_current_buf(buf)
      if is_new then
        vim.notify("Pi: compose your prompt, then :w to send (q to close)", vim.log.levels.INFO)
      end
    end, { desc = "Open scratch buffer to compose pi prompt" })
  end,
}
