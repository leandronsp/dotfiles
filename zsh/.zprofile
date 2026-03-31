# Locale
export LANG=en_US.UTF-8

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# asdf version manager (legacy, gradually replacing with mise)
export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

# mise version manager (asdf replacement, reads .tool-versions natively)
eval "$(mise activate zsh 2>/dev/null)"

# Lean theorem prover
export PATH="$HOME/.elan/bin:$PATH"

# pipx
export PATH="$PATH:$HOME/.local/bin"

# Personal scripts
export PATH="$HOME/bin:$PATH"

# OrbStack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
