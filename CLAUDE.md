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
- Never use `git add -A`. Always stage files explicitly
- `~/vault` symlinks to Obsidian iCloud storage. Skills and hooks depend on `qmd` for semantic search
- pi (coding agent) config lives in `pi/.pi/agent/`. Skills shared with Claude Code via `"skills": ["~/.claude/skills"]` in pi settings

## Packages

`zsh`, `git`, `tmux`, `tool-versions`, `nvim`, `claude`, `pi`, `direnv`, `ssh`, `local-bin`, `ghostty`, `tig`

## Claude Code config

Lives in `claude/.claude/`. Stowed to `~/.claude/`.

### Hooks

- `vault-session-load.sh` — SessionStart. Loads last session recap + related vault notes (score >= 70% via qmd)
- `notify-ready.sh` — Stop + Notification. Sound + tmux window highlight when Claude finishes in a background window

### Skills (shared with pi)

`/vault`, `/note`, `/recap`, `/brainstorm`, `/task`, `/pair`, `/skill-creator`, `/pair-review`, `/qa`, `/browser`

`~/.claude/skills` is a directory-level symlink to `claude/.claude/skills/`. New skills appear automatically without restow.

### MCP servers

- `chrome-devtools` — defined in `~/.mcp.json` (stowed from `claude/.mcp.json`)

## Pi config

Lives in `pi/.pi/agent/`. Stowed to `~/.pi/agent/`.

pi is an alternative coding agent TUI. Install via `npm i -g @mariozechner/pi-coding-agent`.

**Pi does NOT load Claude Code hooks** (`settings.local.json`). All behavior is driven by extensions.

### Extensions

Registered in `settings.json` under `"extensions"`. Load on startup — restart pi after changes.

- `tmux-notify.ts` — sound + tmux highlight when pi finishes in background (port of `notify-ready.sh`)
- `tmux-status.ts` — writes model/tokens/cost to tmux status bar
- `subagent/` — multi-agent orchestration (parallel, chain, single). Discovers agents from `~/.pi/agent/agents/*.md`. Required by `/skill:review`, `/skill:dev`, `/skill:po`
- `plan-mode/` — read-only exploration mode (`/plan`, `/todos`, `Ctrl+Alt+P`). Restricts tools, tracks plan progress

### Skills (pi-only)

`/skill:po`, `/skill:dev`, `/skill:review`, `/skill:commit`

### Agents

`scout` (haiku), `security-reviewer` (sonnet), `performance-reviewer` (sonnet), `quality-reviewer` (sonnet), `review-auditor` (sonnet)

### Skill sharing

1. **Shared with Claude Code**: `"skills": ["~/.claude/skills"]` — all Claude Code skills work in pi
2. **Pi-only**: `~/.pi/agent/skills/` — skills that use subagents/extensions

## Ghostty config

Lives in `ghostty/.config/ghostty/`. Stowed to `~/.config/ghostty/`.

ZedMono Nerd Font, Gruvbox Dark theme (terminal-level), block cursor, `macos-option-as-alt = false` for accents/cedilla.

## Shell prompt

Custom two-line zsh prompt (no theme). First line shows `path:branch` with dirty indicator (`✗` in red). Cursor on second line with `❯`. Locale set to `en_US.UTF-8` in `.zprofile`.

## Tmux theme

Everforest-inspired dark theme. Session name with green accent (`#83C092`), window separators with `·`, active window highlighted with green background. Pane borders show active/inactive labels with command name. Status-right displays pi session info (model, thinking, context, tokens, cost) via `tmux-pi-status.sh`. Tmux hooks auto-reset notification highlights when switching windows/sessions.

## Neovim config

Lives in `nvim/.config/nvim/`. Stowed to `~/.config/nvim/`. Full reference in [`nvim/.config/nvim/README.md`](nvim/.config/nvim/README.md).

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

### LSP servers

- `rust_analyzer` - cargo check on save, proc macros, inlay hints
- `lua_ls` - Neovim Lua development with LazyDev

### Formatters (conform)

stylua (Lua), prettier (JS/TS/JSON), black+isort (Python), rustfmt, gofmt, clang-format, shfmt

### CI

`.github/workflows/ci.yml` runs on `nvim/**` changes. Steps: install plugins, stylua lint, health check, tests.
