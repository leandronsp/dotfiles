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
brew install stow nvim tmux asdf direnv jq ripgrep pipx reattach-to-user-namespace gd fswatch
```

| Package | What it does |
|---------|-------------|
| `stow` | Symlink manager for dotfiles |
| `nvim` | Neovim editor |
| `tmux` | Terminal multiplexer |
| `asdf` | Version manager for Node, Ruby, OCaml |
| `direnv` | Per-directory environment variables |
| `jq` | JSON processor for shell |
| `ripgrep` | Fast text search (used by nvim telescope) |
| `pipx` | Install Python CLI tools in isolated envs |
| `reattach-to-user-namespace` | macOS clipboard integration for tmux |
| `gd` | Graphics library (needed to build Ruby image gems) |
| `fswatch` | File change monitor (used by `/tdd` skill) |

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

### 7. Language runtimes via asdf

```bash
asdf plugin add nodejs && asdf install nodejs
asdf plugin add ruby && asdf install ruby
asdf plugin add opam && asdf install opam
```

Versions are defined in `.tool-versions`.

| Runtime | What it does |
|---------|-------------|
| `nodejs` | JavaScript runtime (provides npm/npx for tools) |
| `ruby` | Ruby runtime |
| `opam` | OCaml package manager and compiler |

### 8. Claude Code and tools

```bash
npm install -g @anthropic-ai/claude-code @tobilu/qmd
```

| Tool | What it does |
|------|-------------|
| `claude-code` | Claude CLI agent |
| `qmd` | Semantic search over markdown (used by vault hooks and skills) |

### 9. Obsidian vault

Install [Obsidian](https://obsidian.md/) and enable iCloud sync. Then create the vault symlink:

```bash
ln -s ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents ~/vault
```

The vault is the second brain. Claude Code hooks load context from it on session start, and skills like `/note`, `/vault`, `/recap`, `/brainstorm`, and `/task` read and write to it.

### 11. Secrets directory

```bash
mkdir -p ~/.secrets
```

API tokens go in `~/.secrets/env`, sourced by `.zshrc`.

### 12. Clone and install dotfiles

```bash
mkdir -p ~/Documents/code
git clone git@github.com:leandronsp/dotfiles.git ~/Documents/code/dotfiles
cd ~/Documents/code/dotfiles
make deps           # Verify everything from steps 1-11
make install        # Stow all packages
source ~/.zshrc     # Reload shell
```

### 13. Neovim first run

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
| `tool-versions` | `.tool-versions` (asdf defaults) |
| `nvim` | `.config/nvim/` (full Neovim config) |
| `claude` | `.mcp.json`, `.claude/` (settings, hooks, skills) |
| `direnv` | `.config/direnv/direnv.toml` |
| `ssh` | `.ssh/config` (Include directives only) |

## Claude Code

The `claude` stow package manages hooks, skills, MCP servers, and portable settings.

### Settings split

- `~/.claude/settings.local.json` (tracked) - hooks, plugins, statusline. Source of truth for portable config
- `~/.claude/settings.json` (not tracked) - machine-specific permissions. Portable keys synced via `make sync-claude`

### Hooks

| Hook | Trigger | What it does |
|------|---------|-------------|
| `vault-session-load.sh` | SessionStart | Loads last session recap + related vault notes (score >= 70%) |
| `notify-ready.sh` | Stop | macOS notification + sound + tmux window highlight when Claude finishes in a background window |

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

### MCP servers

| Server | Source | What it does |
|--------|--------|-------------|
| `chrome-devtools` | `~/.mcp.json` | Browser automation for testing and debugging |

### Vault dependency

Skills and hooks depend on `qmd` for semantic search over the Obsidian vault. The vault lives in iCloud and is symlinked to `~/vault`.

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

## Not tracked

- `~/.secrets/env` - API tokens sourced by `.zshrc`
- `~/.claude/settings.json` - machine-specific permissions, auto-managed by Claude
- `~/.ssh/config.d/*` - host-specific SSH entries
- `~/vault` - Obsidian vault symlink to iCloud (content not in this repo)
- `~/bin/*` - project-specific scripts
