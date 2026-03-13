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
brew install stow nvim tmux asdf direnv jq ripgrep pipx reattach-to-user-namespace gd
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

### 8. Claude CLI

```bash
npm install -g @anthropic-ai/claude-code
```

### 9. Secrets directory

```bash
mkdir -p ~/.secrets
```

API tokens go in `~/.secrets/env`, sourced by `.zshrc`.

### 10. Clone and install dotfiles

```bash
mkdir -p ~/Documents/code
git clone git@github.com:leandronsp/dotfiles.git ~/Documents/code/dotfiles
cd ~/Documents/code/dotfiles
make deps           # Verify everything from steps 1-9
make install        # Stow all packages
source ~/.zshrc     # Reload shell
```

### 11. Neovim first run

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
```

## Packages

| Package | What it manages |
|---------|----------------|
| `zsh` | `.zshenv`, `.zprofile`, `.zshrc`, `.profile` |
| `git` | `.gitconfig`, `.gitignore_global` |
| `tmux` | `.tmux.conf` |
| `tool-versions` | `.tool-versions` (asdf defaults) |
| `nvim` | `.config/nvim/` (full Neovim config) |
| `claude` | `.mcp.json`, `.claude/` (settings, skills, memory) |
| `direnv` | `.config/direnv/direnv.toml` |
| `ssh` | `.ssh/config` (Include directives only) |

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
- `~/.claude/settings.json` - machine-specific project permissions
- `~/.ssh/config.d/*` - host-specific SSH entries
- `~/bin/*` - project-specific scripts
