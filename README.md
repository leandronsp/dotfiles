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

## Not tracked

- `~/.secrets/env` - API tokens sourced by `.zshrc`
- `~/.claude/settings.json` - machine-specific project permissions
- `~/.ssh/config.d/*` - host-specific SSH entries
- `~/bin/*` - project-specific scripts
