# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

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

# direnv
eval "$(direnv hook zsh 2>/dev/null)"
export DIRENV_LOG_FORMAT=""

# yolo mode for Claude
yolo() {
  claude --allow-dangerously-skip-permissions "$@"
}
