# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Dependencies

brew, stow, git, nvim, tmux, asdf, direnv, opam, jq, curl, cargo, claude, elan, pipx, oh-my-zsh, gd (brew).

Run `make deps` to check what's installed.

## Setup

```bash
git clone git@github.com:leandronsp/dotfiles.git ~/Documents/code/dotfiles
cd ~/Documents/code/dotfiles
make deps           # Check dependencies
make install        # Stow all packages
```

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
