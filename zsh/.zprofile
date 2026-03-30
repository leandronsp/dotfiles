# Locale
export LANG=en_US.UTF-8

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# asdf version manager
export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

# Lean theorem prover
export PATH="$HOME/.elan/bin:$PATH"

# pipx
export PATH="$PATH:$HOME/.local/bin"

# Personal scripts
export PATH="$HOME/bin:$PATH"

# OrbStack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
