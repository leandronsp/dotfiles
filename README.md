# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Fresh macOS setup

### 1. Xcode Command Line Tools

```bash
xcode-select --install
```

Provides: git, make, curl, gcc, unzip, clang-format.

### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Brew packages

```bash
brew install stow nvim tmux asdf mise direnv jq ripgrep pipx reattach-to-user-namespace gd fswatch tig gh glow agent-browser
```

| Package | What it does |
|---------|-------------|
| `stow` | Symlink manager for dotfiles |
| `nvim` | Neovim editor |
| `tmux` | Terminal multiplexer |
| `asdf` | Version manager for Node, Ruby, OCaml (legacy) |
| `mise` | Version manager replacing asdf. Faster, reads `.tool-versions` natively |
| `direnv` | Per-directory environment variables |
| `jq` | JSON processor for shell |
| `ripgrep` | Fast text search (used by nvim telescope) |
| `pipx` | Install Python CLI tools in isolated envs |
| `reattach-to-user-namespace` | macOS clipboard integration for tmux |
| `gd` | Graphics library (needed to build Ruby image gems) |
| `fswatch` | File change monitor (used by pair/dev skills) |
| `tig` | Git browser / log viewer |
| `gh` | GitHub CLI (used by commit skill for draft PRs) |
| `glow` | Markdown renderer in terminal (used by nvim glow plugin) |
| `agent-browser` | Browser automation CLI (used by /browser and /qa skills) |

### 4. Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 5. Rust toolchain

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Provides: cargo, rustfmt, rust-analyzer.

### 6. Tools via cargo

```bash
cargo install stylua elan
```

| Tool | What it does |
|------|-------------|
| `stylua` | Lua code formatter (used by nvim and CI) |
| `elan` | Lean 4 theorem prover toolchain manager |

### 7. Language runtimes via mise

mise reads `.tool-versions` natively. No plugins to install.

```bash
mise install
```

That's it. All runtimes defined in `.tool-versions` are installed.

#### mise basics

```bash
mise install                    # Install all runtimes from .tool-versions
mise install node@22            # Install a specific version
mise use node@22                # Set version for current directory (.tool-versions)
mise use -g node@22             # Set global default
mise ls                         # List installed versions
mise ls-remote node             # List available versions
mise prune                      # Remove unused versions
mise doctor                     # Check mise health
mise reshim                     # Rebuild shims after installing global npm/gem packages
```

| Runtime | What it does |
|---------|-------------|
| `nodejs` | JavaScript runtime (provides npm/npx for tools) |
| `ruby` | Ruby runtime |
| `golang` | Go runtime |
| `opam` | OCaml package manager and compiler |
| `erlang` | Erlang VM |
| `elixir` | Elixir runtime |

#### Legacy: asdf

If using asdf instead of mise, install plugins manually:

```bash
asdf plugin add nodejs && asdf install nodejs
asdf plugin add ruby && asdf install ruby
asdf plugin add opam && asdf install opam
asdf plugin add erlang && asdf install erlang
asdf plugin add elixir && asdf install elixir
asdf plugin add golang && asdf install golang
```

### 8. Claude Code, pi, and tools

```bash
npm install -g @anthropic-ai/claude-code @mariozechner/pi-coding-agent @tobilu/qmd
```

| Tool | What it does |
|------|-------------|
| `claude-code` | Claude CLI agent |
| `pi-coding-agent` | Pi coding agent TUI (extensible, shares skills with Claude Code) |
| `qmd` | Semantic search over markdown (used by vault hooks and skills) |

### 9. Obsidian vault

Install [Obsidian](https://obsidian.md/) and enable iCloud sync. Then create the vault symlink:

```bash
ln -s ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents ~/vault
```

The vault is the second brain. Claude Code hooks load context from it on session start, and skills like `/note`, `/vault`, `/recap`, `/brainstorm`, and `/task` read and write to it.

### 10. Secrets directory

```bash
mkdir -p ~/.secrets
```

API tokens go in `~/.secrets/env`, sourced by `.zshrc`.

### 11. Clone and install dotfiles

```bash
mkdir -p ~/Documents/code
git clone git@github.com:leandronsp/dotfiles.git ~/Documents/code/dotfiles
cd ~/Documents/code/dotfiles
make deps           # Verify everything from steps 1-10
make install        # Stow all packages
source ~/.zshrc     # Reload shell
```

### 12. Neovim first run

Open `nvim`. Lazy will auto-install plugins. Mason will auto-install LSP servers (lua_ls, rust_analyzer) and debug adapters (delve).

## Usage

```
make help           # Show all commands
make deps           # Check dependencies
make check          # Verify symlinks
make status         # Show stow package status
make restow         # Re-stow all packages
make stow-zsh       # Stow a single package
make unstow-zsh     # Unstow a single package
make lint           # Check for hardcoded paths
make sync-claude    # Sync portable Claude settings into settings.json
```

## Packages

| Package | What it manages |
|---------|----------------|
| `zsh` | `.zshenv`, `.zprofile`, `.zshrc`, `.profile` |
| `git` | `.gitconfig`, `.gitignore_global` |
| `tmux` | `.tmux.conf` |
| `tool-versions` | `.tool-versions` (mise/asdf runtime versions) |
| `nvim` | `.config/nvim/` (full Neovim config) |
| `claude` | `.mcp.json`, `.claude/` (settings, hooks, skills) |
| `pi` | `.pi/agent/` (settings, themes, extensions, agents, skills) |
| `direnv` | `.config/direnv/direnv.toml` |
| `ssh` | `.ssh/config` (Include directives only) |
| `local-bin` | `.local/bin/` (annotation buffer scripts, tmux-pi-status) |
| `tig` | `.tigrc` (tig git browser config) |
| `ghostty` | `.config/ghostty/config` (terminal emulator) |

## Claude Code

The `claude` stow package manages hooks, skills, MCP servers, and portable settings.

### Settings split

- `~/.claude/settings.local.json` (tracked) - hooks, plugins, statusline. Source of truth for portable config
- `~/.claude/settings.json` (not tracked) - machine-specific permissions. Portable keys synced via `make sync-claude`

### Hooks

| Hook | Trigger | What it does |
|------|---------|-------------|
| `vault-session-load.sh` | SessionStart | Loads last session recap + related vault notes (score >= 70%) |
| `notify-ready.sh` | Stop, Notification | macOS notification + sound + tmux window highlight when Claude finishes in a background window |

### Skills

| Skill | What it does |
|-------|-------------|
| `/vault` | Search and retrieve notes from Obsidian vault |
| `/note` | Capture ideas, TILs, or drafts to the vault |
| `/recap` | Save session learnings to the vault |
| `/brainstorm` | Develop blog post ideas into outlines |
| `/task` | Manage tasks across roadmap, sprint, pomodoro, routines |
| `/pair` | TDD pair programming with mode switching (driver/navigator) |
| `/skill-creator` | Create and test new skills |
| `/pair-review` | Interactive pair review of a PR |
| `/qa` | Smoke-test changes in the browser, validate behavior, plan fixes |
| `/browser` | Browser automation via agent-browser CLI |

`~/.claude/skills` is a directory-level symlink. New skills added to `claude/.claude/skills/` appear automatically without restow.

All Claude Code skills also work in pi via shared skill paths (see [Pi > Skill sharing](#skill-sharing)).

### MCP servers

| Server | Source | What it does |
|--------|--------|-------------|
| `chrome-devtools` | `~/.mcp.json` | Browser automation for testing and debugging |

### Vault dependency

Skills and hooks depend on `qmd` for semantic search over the Obsidian vault. The vault lives in iCloud and is symlinked to `~/vault`.

## Local Scripts (`local-bin`)

### Annotation Buffer

Review tmux output without scroll fatigue. Each tmux window gets its own buffer (`/tmp/abuf-{session}-{window}.md`). Both `a` (copy mode) and `prefix + B` open the same vim popup on the buffer.

| Script | What it does |
|--------|-------------|
| `abuf-edit` | Opens vim popup on the buffer, appends quoted selection if available |
| `abuf-paste` | Pastes buffer into the current pane via send-keys |
| `abuf-clear` | Clears the current window's buffer |

### Pi Tmux Status

| Script | What it does |
|--------|-------------|
| `tmux-pi-status.sh` | Reads pi session status for active pane, displayed in tmux status-right |

Written by the `tmux-status.ts` pi extension, read by tmux every second.

### Annotation Buffer Keybindings

| Key | Context | Action |
|-----|---------|--------|
| `a` | copy mode | Appends selection (if any) to buffer, opens vim popup |
| `prefix + B` | normal | Opens buffer in vim popup (edit, delete, organize) |
| `prefix + S` | normal | Paste buffer into current pane (does not clear buffer) |
| `prefix + Ctrl-x` | normal | Clear buffer (asks for confirmation) |

### Annotation Buffer Workflow

1. Enter copy mode (`prefix + [`)
2. Optionally select text with `v` + movement
3. Press `a` to open buffer in vim. Selection is appended as a quote block
4. Edit freely. `:wq` to save, `:q!` to discard changes
5. You stay in copy mode after the popup closes. Repeat for more annotations
6. `prefix + B` to reopen the buffer at any time (same content)
7. Go to the Claude Code pane, `prefix + S` to paste the buffer

## Neovim cheatsheet

Leader is `;` (semicolon). Full reference in [`nvim/.config/nvim/README.md`](nvim/.config/nvim/README.md).

### Search and navigation

| Key | Action |
|-----|--------|
| `Ctrl-p` | Find files (frecency ranking) |
| `Ctrl-f` | Live grep across project |
| `Ctrl-i` | Recent files |
| `;;` | Open buffers |
| `;n` | Toggle file tree |
| `;k` | Reveal current file in tree |
| `;sg` | Grep with preview |
| `;sd` | Search diagnostics |

### LSP (works out of the box for Rust and Lua)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find all references |
| `gI` | Go to implementation |
| `K` | Hover docs (type info, signature) |
| `;rn` | Rename symbol across project |
| `;ca` | Code actions (quick fix, refactor) |
| `;th` | Toggle inlay hints |
| `;f` | Format buffer |

### Git

| Key | Action |
|-----|--------|
| `;gs` | Git status |
| `;gb` | Git branches |
| `;gc` | Git log |
| `;hs` | Stage hunk |
| `;hr` | Reset hunk |
| `;hb` | Blame current line |
| `]c` / `[c` | Next/prev change |

### Example: navigating a Rust project

```
;n                  Open file tree, navigate to src/engine/board.rs
Ctrl-p              Or fuzzy-find "board" to jump there directly
gd                  On a function call -> jumps to its definition
gr                  On a struct -> shows all references across crate
K                   On a type -> shows full signature + doc comments
;ca                 On a warning -> "add #[allow(...)]" or "extract to function"
;rn                 Rename a struct field -> updates all usages
;f                  Format with rustfmt
Ctrl-f              Grep for "impl Board" across the entire project
;th                 Show inlay type hints inline (e.g. let x: i32 = ...)
```

## Pi

The `pi` stow package manages settings, themes, agents, and pi-only skills.

### Settings

- `~/.pi/agent/settings.json` - model, provider, theme, skill paths, extensions
- `~/.pi/agent/keybindings.json` - custom keybindings
- `~/.pi/agent/themes/everforest.json` - custom theme matching terminal/nvim/tmux

### Extensions

pi does **not** load Claude Code hooks (`settings.local.json`). The equivalent functionality lives in TypeScript extensions using pi's `ExtensionAPI`.

| Extension | What it does |
|-----------|-------------|
| `tmux-notify.ts` | Sound + tmux window/session highlight when pi finishes in a background pane |
| `tmux-status.ts` | Writes model, thinking level, context %, tokens, cost to tmux status bar |
| `subagent/` | Multi-agent orchestration. Spawns isolated pi subprocesses. Supports single, parallel (max 8), and chain modes |
| `plan-mode/` | Read-only exploration mode. Restricts tools, extracts numbered plans, tracks step completion |

The tmux status bar reads pi session info via `tmux-pi-status.sh` (in `local-bin` package), refreshed every second.

`subagent` is required by `/skill:review`, `/skill:dev`, and `/skill:po`. Extensions load on pi startup — restart pi after changing `settings.json`.

#### Subagent

Spawns isolated `pi` subprocesses with delegated system prompts. Three modes:

| Mode | Usage | Description |
|------|-------|-------------|
| Single | `subagent({ agent, task })` | One agent, one task |
| Parallel | `subagent({ tasks: [...] })` | Multiple agents run concurrently (max 8, 4 concurrent) |
| Chain | `subagent({ chain: [...] })` | Sequential, `{previous}` passes output between steps |

Agents are discovered automatically from `~/.pi/agent/agents/*.md` (user-level) and `.pi/agents/*.md` (project-level, opt-in via `agentScope: "both"`). Each agent is a markdown file with YAML frontmatter:

```markdown
---
name: scout
description: Fast codebase recon
tools: read, grep, find, ls, bash
model: claude-haiku-4-5
---

System prompt goes here.
```

#### Plan Mode

Read-only exploration mode for safe code analysis.

| Command | Action |
|---------|--------|
| `/plan` | Toggle plan mode (read-only ↔ full access) |
| `/todos` | Show current plan progress |
| `Ctrl+Alt+P` | Toggle plan mode (shortcut) |

In plan mode, only read-only tools are available (read, grep, find, ls) and bash commands are filtered through an allowlist (cat, head, tail, git status, git log, git diff, etc). The agent creates a numbered plan, then on execution full access is restored and progress is tracked with `[DONE:n]` markers.

### Agents

Subagent definitions used by the review and dev skills. Each spawns an isolated `pi` subprocess.

| Agent | Model | Role |
|-------|-------|------|
| `scout` | haiku | Fast codebase recon, compressed context |
| `security-reviewer` | sonnet | Auth, injection, SSRF, race conditions |
| `performance-reviewer` | sonnet | N+1, allocations, hot loops, blocking I/O |
| `quality-reviewer` | sonnet | DDD, SOLID, testing, clean code, patterns |
| `review-auditor` | sonnet | Red team, verifies findings against code and rules |

### Skills (pi-only)

These use pi-specific features (subagents) and don't conflict with Claude Code skills.

| Skill | What it does |
|-------|--------------|
| `/skill:po` | Product owner: scout codebase, write PRD, publish to docs/GitHub/Linear |
| `/skill:dev` | Senior engineer: scout → questions → test proposal → 5 TDD pairing modes |
| `/skill:review` | 3 parallel reviewers → red team audit → user judgment → fix or report |
| `/skill:commit` | Conventional commits + `--pr` for draft PRs via `gh` CLI |

### Skill sharing

Pi loads skills from two sources:
1. **Shared**: `"skills": ["~/.claude/skills"]` in settings.json (all Claude Code skills)
2. **Pi-only**: `~/.pi/agent/skills/` (agents, subagent workflows)

## Not tracked

- `~/.secrets/env` - API tokens sourced by `.zshrc`
- `~/.zshrc.local` - machine-specific shell config
- `~/.claude/settings.json` - machine-specific permissions, auto-managed by Claude
- `~/.ssh/config.d/*` - host-specific SSH entries
- `~/vault` - Obsidian vault symlink to iCloud (content not in this repo)
- `~/bin/*` - project-specific scripts
