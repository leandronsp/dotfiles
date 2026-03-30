# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Prompt: line 1 = path:branch, line 2 = cursor
precmd() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  local git_info=""
  if [[ -n "$branch" ]]; then
    git_info=":%F{green}${branch}%f"
    [[ -n $(git status --porcelain 2>/dev/null) ]] && git_info+=" %F{red}✗%f"
  fi
  PROMPT="%F{blue}%~%f${git_info}"$'\n'"%F{yellow}❯%f "
}

# Editor
export TERM="xterm-256color"
alias vim=nvim
export MANPAGER="nvim +Man!"

# gd build flags (required by some Ruby gems)
export LDFLAGS="-L$(brew --prefix gd)/lib"
export CPPFLAGS="-I$(brew --prefix gd)/include"
export CFLAGS="-I$(brew --prefix gd)/include"
export PKG_CONFIG_PATH="$(brew --prefix gd)/lib/pkgconfig"
export C_INCLUDE_PATH="$(brew --prefix gd)/include"
export LIBRARY_PATH="$(brew --prefix gd)/lib"
export LD_LIBRARY_PATH="$(brew --prefix gd)/lib"

# opam (OCaml)
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null

# Secrets
[[ -f ~/.secrets/env ]] && source ~/.secrets/env

# Machine-specific config (not tracked)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# direnv
eval "$(direnv hook zsh 2>/dev/null)"
export DIRENV_LOG_FORMAT=""

# yolo mode for Claude
yolo() {
  claude --allow-dangerously-skip-permissions "$@"
}
