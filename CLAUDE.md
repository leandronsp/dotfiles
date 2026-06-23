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

## Working on this repo

- Never commit `claude/.claude/settings.json` (machine-specific permissions). Only `settings.local.json` is portable and tracked.
- Stage files explicitly with `git add <file>`. Never `git add -A` or `git add .`.
- After moving files between stow packages, run `make restow` to refresh symlinks.
- Run `make lint` before pushing. It catches hardcoded paths that break portability across machines.
- Adding a new package: create the dir, mirror home structure, add to `PACKAGES` in the Makefile, then `make stow-<pkg>`.

## Claude Code config

Lives in `claude/.claude/`. Stowed to `~/.claude/`.

### Hooks

- `vault-session-load.sh` — SessionStart. Loads last session recap + related vault notes (score >= 70% via qmd)
- `notify-ready.sh` — Stop + Notification. Sound + tmux window highlight when Claude finishes in a background window

### Skills (shared with pi)

`/vault`, `/note`, `/recap`, `/skill-creator`, `/qa`, `/browser`

`~/.claude/skills` is a directory-level symlink to `claude/.claude/skills/`. New skills appear automatically without restow.

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
- `web-search.ts` — `web_search`, `web_fetch`, `web_snapshot` tools via agent-browser (Chromium). For models without built-in web access
- `nvim-bridge.ts` — watches `/tmp/pi-nvim-bridge.md`; turns Neovim selections, buffers, and `![img]`/`@file` refs into pi messages. See [Neovim ↔ Pi bridge](#neovim--pi-bridge)
- `auto-memory.ts` — LLM auto-captures learnings to `~/vault/learnings`, reloaded into the system prompt each turn. Also checkpoints the session's recorded facts to `~/vault/sessions/` on `session_before_compact` (pi ≥ 0.79.10, skips overflow-retry events) and on `session_shutdown`
- `rules-loader.ts` — injects `~/.claude/CLAUDE.md` + `~/.claude/rules/*.md` + `<cwd>/.claude/rules/*.md` into the system prompt. pi only auto-loads `CLAUDE.md`/`AGENTS.md`, never `.claude/rules` — this closes that gap. Prints a `📐` load line on `session_start`
- `cc-memory-loader.ts` — reads Claude Code's curated memory (`~/.claude/projects/<encoded-cwd>/memory/MEMORY.md`) into the system prompt so both agents share one brain. Worktree-aware: resolves `<repo>/.worktrees/<name>` back to the main repo's memory (encoding replaces `/` and `.` with `-`). Prints a `🧠` load line on `session_start`
- `vision-switch.ts` — routes vision work to a vision model (`opencode-go/minimax-m3`) automatically, via `pi.setModel` + `ctx.modelRegistry.find`. Two triggers: (1) **image** at turn start — `event.images` **or** an image path in the prompt text (clipboard paste writes the image to `pi-clipboard-*.png` and puts the PATH in the prompt, so `event.images` is empty — the common case); one-shot, reverts at `agent_end`. (2) **browser** — a `tool_call` running `agent-browser` or a Chrome DevTools MCP tool; sticky, stays on the vision model through the whole browsing flow and reverts on the first turn with no browser work. A manual `/model` switch drops the pending revert — **gotcha:** clipboard paste writes the image to `/var/folders/.../pi-clipboard-*.png` and puts the PATH in the prompt, so `event.images` stays empty (the common case). A manual `/model` switch cancels the pending revert
- `ocr/` — OCR fallback for non-vision models (Apple Vision `image-use` → Tesseract + PIL). **Not registered** in `settings.json` — `vision-switch` supersedes it by switching to a real vision model. The `~/.claude/skills/ocr` skill remains the last-resort path when no vision model is reachable

### Skills (pi-only)

`/skill:po`, `/skill:dev`, `/skill:review`, `/skill:commit`

### Agents

`scout` is pinned to `opencode-go/deepseek-v4-flash` via frontmatter `model:` (cheap recon). The reviewers (`security-reviewer`, `performance-reviewer`, `quality-reviewer`, `review-auditor`) and `tdd-driver`/`tdd-navigator` have no `model:` line, so they inherit `defaultModel`. Pin any agent with `model: provider/id` in its frontmatter — the subagent extension passes it straight to `pi --model`.

### Model routing

opencode-go is a flat **$10/mo** plan (budget: $12/5h, $30/week, $60/month — not per-token billing).

- `defaultModel` (`settings.json`) — the opencode-go coding model. `mimo-v2.5-pro` wins agentic coding and is token-efficient; `deepseek-v4-pro` is the reasoning-heavy alternate. Both are text-only.
- Scout → `deepseek-v4-flash` (cheapest, stretches the budget).
- Images → `minimax-m3` automatically via `vision-switch.ts` (the text-only defaults can't see images; OCR is useless on diagrams).

### Skill sharing

1. **Shared with Claude Code**: `"skills": ["~/.claude/skills"]` — all Claude Code skills work in pi
2. **Pi-only**: `~/.pi/agent/skills/` — skills that use subagents/extensions

## Neovim ↔ Pi bridge

Send context from Neovim and the terminal into a running pi session:

- **Neovim** (`pi-bridge.lua`) — `:PiPrompt`, `:PiFile`, `:PiBuffer`, `:PiImage` write to `/tmp/pi-nvim-bridge.md` (commands in the [nvim README](nvim/.config/nvim/README.md#pi-bridge))
- **Pi** (`nvim-bridge.ts`) — watches the bridge file, expands `@file` and `![img]` refs into content blocks, steers them into the session. `/nvim-read` is the manual fallback
- **Tmux** — `P` in copy mode pipes the selection through `pi-note` into `/tmp/pi-nvim-notes.md`, which `:PiBuffer` picks up
- **local-bin** — `pi-img` (clipboard PNG → temp path, via `pngpaste` or osascript), `pi-note` (append terminal text to the notes file)

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
