# Dotfiles

Personal dotfiles managed with GNU Stow. Each top-level directory is a stow package.

## Commands

`make help` shows all targets. Key ones:

- `make install` - first time setup (installs stow, creates dirs, stows all)
- `make deps` - check all required dependencies
- `make restow` - re-stow all packages after changes
- `make stow-<pkg>` / `make unstow-<pkg>` - stow/unstow a single package
- `make check` - verify all symlinks are intact
- `make lint` - check for hardcoded paths

## Adding a new package

1. Create a directory named after the package
2. Mirror the home directory structure inside it
3. Add the package name to `PACKAGES` in the Makefile
4. `make stow-<pkg>`

## Key decisions

- Secrets live in `~/.secrets/env`, never committed
- `~/.zshrc.local` for machine-specific shell config, not tracked
- `~/.claude/settings.json` is machine-specific (permissions), not tracked. Portable keys synced from local via `make sync-claude`
- `~/.claude/settings.local.json` is portable (hooks, plugins, statusline), tracked via stow. Source of truth for portable config
- mise is the version manager (replacing asdf). Both coexist during migration. `.tool-versions` is the shared config file
- SSH host entries live in `~/.ssh/config.d/`, not tracked
- nvim CI workflow lives at repo root `.github/workflows/ci.yml` with path filter
- `~/vault` symlinks to Obsidian iCloud storage. Skills and hooks depend on `qmd` for semantic search
- pi (coding agent) config lives in `pi/.pi/agent/`. Skills shared with Claude Code via `"skills": ["~/.claude/skills"]` in pi settings

## Claude Code config

Lives in `claude/.claude/`. Stowed to `~/.claude/`.

### Hooks

- `hooks/vault-session-load.sh` - SessionStart hook. Loads last session recap + related vault notes (score >= 70% via qmd)
- `hooks/notify-ready.sh` - Stop hook. macOS notification + sound + tmux window highlight when Claude finishes responding in a background window

### Skills

- `/vault` - search and retrieve vault notes
- `/note` - capture ideas, TILs, drafts to vault
- `/recap` - save session learnings to vault
- `/brainstorm` - develop blog post ideas into outlines
- `/task` - manage tasks (roadmap, sprint, pomodoro, routines)
- `/pair` - TDD pair programming with mode switching (driver/navigator)
- `/skill-creator` - create and test new skills
- `/pair-review` - interactive pair review of a PR
- `/qa` - smoke-test changes in the browser, validate behavior
- `/browser` - browser automation via agent-browser CLI

`~/.claude/skills` is a directory-level symlink to `claude/.claude/skills/`. New skills added to the dotfiles appear automatically without restow.

### MCP servers

- `chrome-devtools` - defined in `~/.mcp.json` (stowed from `claude/.mcp.json`)

## Pi config

Lives in `pi/.pi/agent/`. Stowed to `~/.pi/agent/`.

pi is an alternative coding agent TUI that shares skills with Claude Code. Install via `npm i -g @mariozechner/pi-coding-agent`.

### Structure

```
pi/.pi/agent/
  settings.json           Model, provider, theme, skills path
  keybindings.json        Custom keybindings
  themes/
    everforest.json       Custom Everforest theme matching terminal/nvim/tmux
```

### Key settings

- `defaultProvider`: `anthropic`
- `defaultModel`: `claude-opus-4-6` (1M context)
- `defaultThinkingLevel`: `medium`
- `theme`: `everforest` (custom, hot-reloads on edit)
- `skills`: `["~/.claude/skills"]` — reuses Claude Code skills directly

### Skills sharing

pi discovers skills via the `"skills"` array in `settings.json`. Pointing it to `~/.claude/skills` (which is a directory symlink to `claude/.claude/skills/`) means both Claude Code and pi share the same skill set. No duplication.

## Ghostty config

Lives in `ghostty/.config/ghostty/`. Stowed to `~/.config/ghostty/`.

ZedMono Nerd Font, Gruvbox Dark theme, block cursor, `macos-option-as-alt = false` for accents/cedilla.

## Shell prompt

Custom two-line zsh prompt (no theme). First line shows `path:branch` with dirty indicator (`✗` in red). Cursor on second line with `❯`. Locale set to `en_US.UTF-8` in `.zprofile`.

## Tmux theme

Everforest-inspired dark theme. Session name with subtle background, window separators with `·`, active window highlighted with golden background (`#DBBC7F`). Inactive windows with muted text on slightly raised background.

## Neovim config

Lives in `nvim/.config/nvim/`. Stowed to `~/.config/nvim/`.

### Structure

```
nvim/.config/nvim/
  init.lua              Entry point. Loads lua/config/
  lua/config/
    init.lua            Module loader (options -> keymaps -> autocmds -> lazy)
    options.lua         Vim options. Leader is semicolon (;)
    keymaps.lua         All keymaps + helper functions for LSP/snacks/inlay hints
    autocmds.lua        Yank highlight, neo-tree auto-quit, neo-tree colors, LSP attach/detach
    lazy.lua            Plugin manager bootstrap + plugin imports
  lua/plugins/
    ui/                 colorscheme (everforest), lualine, todo-comments, which-key
    editor/             snacks (fuzzy finder), treesitter, mini.nvim
    coding/             lsp, completion (nvim-cmp), formatting (conform)
    tools/              copilot, languages (lean4, coffeescript, JS/TS), markdown (glow), sleuth
  lua/kickstart/        health check + plugins (debug/DAP, gitsigns, indent, lint, neo-tree, autopairs)
  lua/tests/            Plenary test specs (config, plugins, utils)
  tests/run.lua         Test runner
  Makefile              sync, test, health, format, lint, startup-time
```

### LSP servers

- `rust_analyzer` - cargo check on save, proc macros, inlay hints
- `lua_ls` - Neovim Lua development with LazyDev

### Key keymaps (leader = ;)

- `;sf` / `Ctrl-p` - find files (frecency)
- `;sg` / `Ctrl-f` - live grep
- `;n` - toggle neo-tree, `;k` - reveal in tree
- `;tt` - toggle dark/light theme
- `gd` / `gr` / `gI` - go to definition/references/implementation
- `;rn` - rename, `;ca` - code action, `K` - hover
- `;gb` / `;gc` / `;gs` - git branches/commits/status
- `;f` - format buffer
- `;b` - toggle breakpoint, `F5` - start/continue debug

### Formatters (conform)

stylua (Lua), prettier (JS/TS/JSON), black+isort (Python), rustfmt, gofmt, clang-format, shfmt

### CI

`.github/workflows/ci.yml` runs on `nvim/**` changes. Steps: install plugins, stylua lint, health check, tests.

### Local dev commands

```bash
cd ~/.config/nvim
make test           # Run test suite
make health         # Health check
make format         # Format lua files
make lint           # Check lua style
make sync           # Sync plugins + Mason tools
make startup-time   # Measure startup
```
