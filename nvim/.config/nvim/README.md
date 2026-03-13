# Neovim Config

Modular configuration built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). Lua only, managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

## Quick start

```bash
# From the dotfiles repo
make stow-nvim

# Or manually
ln -s ~/Documents/code/dotfiles/nvim/.config/nvim ~/.config/nvim
nvim --headless +'Lazy install' +qall
```

## Structure

```
init.lua                    Entry point
lua/
  config/
    options.lua             Leader = ;, line numbers, search, splits
    keymaps.lua             All bindings + LSP/snacks/inlay hint helpers
    autocmds.lua            Yank highlight, neo-tree auto-quit, LSP lifecycle
    lazy.lua                Plugin manager bootstrap
  plugins/
    ui/                     Everforest theme, lualine, which-key, todo-comments
    editor/                 Snacks (fuzzy finder), treesitter, mini.nvim
    coding/                 LSP, completion, formatting
    tools/                  Copilot, languages, markdown, sleuth
  kickstart/                Health check, DAP, gitsigns, indent, lint, neo-tree, autopairs
  tests/                    Plenary specs
tests/run.lua               Test runner
Makefile                    Dev commands
```

## Keymaps

Leader is `;` (semicolon).

### Files and search

| Key | Action |
|-----|--------|
| `Ctrl-p` / `;sf` | Find files (frecency) |
| `Ctrl-f` / `;sg` | Live grep |
| `Ctrl-i` / `;s.` | Recent files |
| `;;` | Open buffers |
| `;s/` | Search in open files |
| `;sn` | Search nvim config |
| `;sh` | Help tags |
| `;sk` | Keymaps |
| `;sd` | Diagnostics |
| `;/` | Current buffer search |
| `;sr` | Resume last search |

### Navigation

| Key | Action |
|-----|--------|
| `;n` | Toggle neo-tree |
| `;k` | Reveal current file in tree |
| `Ctrl-h/j/k/l` | Window navigation |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `;rn` | Rename symbol |
| `;ca` | Code actions |
| `;th` | Toggle inlay hints |
| `;f` | Format buffer |

### Git

| Key | Action |
|-----|--------|
| `;gb` | Git branches |
| `;gc` | Git commits |
| `;gs` | Git status |
| `;hs` | Stage hunk |
| `;hr` | Reset hunk |
| `;hp` | Preview hunk |
| `;hb` | Blame line |
| `]c` / `[c` | Next/prev hunk |

### Debug (DAP)

| Key | Action |
|-----|--------|
| `F5` | Start/Continue |
| `F1` | Step into |
| `F2` | Step over |
| `F3` | Step out |
| `F7` | Toggle debug UI |
| `;b` | Toggle breakpoint |

### Other

| Key | Action |
|-----|--------|
| `;tt` | Toggle dark/light theme |
| `;mp` | Markdown preview (browser) |
| `;mg` | Markdown glow (terminal) |
| `;cz` | Copy file path to clipboard |

## LSP servers

Managed by Mason. Auto-installed:

- **rust_analyzer** - Clippy on save, all cargo features, proc macros, inlay hints
- **lua_ls** - Neovim Lua with LazyDev integration

## Formatters

Via conform.nvim. Format on save enabled (toggle with `:FormatToggle`).

| Language | Formatter |
|----------|-----------|
| Lua | stylua |
| JS/TS/JSON | prettier |
| Python | black + isort |
| Rust | rustfmt |
| Go | gofmt |
| C/C++ | clang-format |
| Shell | shfmt |

## Linters

Via nvim-lint. Auto-lint on BufEnter, BufWritePost, InsertLeave.

- Markdown: markdownlint

## Dev commands

```bash
make test           # Run test suite (plenary)
make health         # Neovim health check
make format         # Format lua/ with stylua
make lint           # Check lua style
make sync           # Sync plugins + Mason tools
make startup-time   # Measure startup time
make doctor         # health + test
```

## CI

GitHub Actions workflow at `.github/workflows/ci.yml`. Runs on `nvim/**` changes:

1. Install neovim + stylua + plugins (all cached)
2. `stylua --check lua/`
3. `make health`
4. `make test`

## Theme

Everforest with medium contrast. Toggle dark/light with `;tt`.

## Customization

### Add a language server

Edit `lua/plugins/coding/lsp.lua`, add to the `servers` table:

```lua
gopls = {},
pyright = {},
ts_ls = {},
clangd = {},
```

Mason auto-installs them on next startup.

### Add a formatter

Edit `lua/plugins/coding/formatting.lua`:

```lua
formatters_by_ft = {
  -- existing...
  your_language = { "your_formatter" },
}
```

### Add a plugin

Create a file in the appropriate `lua/plugins/` directory:

```lua
-- lua/plugins/tools/your-plugin.lua
return {
  'author/your-plugin',
  config = function()
    -- setup here
  end,
}
```

## Commands

```vim
:Lazy                 " Plugin manager UI
:Lazy sync            " Update all plugins
:Mason                " Manage LSP servers and tools
:LspInfo              " Show active LSP clients
:LspRestart           " Restart LSP
:ConformInfo          " Show formatter info
:FormatToggle         " Toggle format-on-save
:checkhealth          " System diagnostics
```

## Troubleshooting

**Plugins not loading**: `:Lazy sync` then restart nvim.

**LSP not working**: `:LspInfo` to check status, `:Mason` to verify server is installed.

**Slow startup**: `make startup-time` to find bottlenecks.

**Nuclear reset** (re-downloads everything):

```bash
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
nvim
```

## Dependencies

- Neovim 0.10+
- git, make, unzip, gcc, ripgrep
- Nerd Font (for icons)
- Node.js (for some Mason tools)
