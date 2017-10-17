export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

git_prompt_info() {
  git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\/\(.*\)/ (\1)/' 2> /dev/null
}

function prompt {
  local RESET="\[\033[00m\]"
  local BLACK="\[\033[0;30m\]"
  local BLACKBOLD="\[\033[1;30m\]"
  local RED="\[\033[0;31m\]"
  local REDBOLD="\[\033[1;31m\]"
  local GREEN="\[\033[0;32m\]"
  local GREENBOLD="\[\033[1;32m\]"
  local YELLOW="\[\033[0;33m\]"
  local YELLOWBOLD="\[\033[1;33m\]"
  local BLUE="\[\033[0;34m\]"
  local BLUEBOLD="\[\033[1;34m\]"
  local PURPLE="\[\033[0;35m\]"
  local PURPLEBOLD="\[\033[1;35m\]"
  local CYAN="\[\033[0;36m\]"
  local CYANBOLD="\[\033[1;36m\]"
  local WHITE="\[\033[0;37m\]"
  local WHITEBOLD="\[\033[1;37m\]"
  export PS1="\n$CYAN\u:$YELLOW\w$RED\$(git_prompt_info)$CYAN \\$ "
}

prompt

# load aliases
if [ -f ~/.bash/aliases ]; then
. ~/.bash/aliases
fi

if [ -f ~/.bash/private_aliases ]; then
. ~/.bash/private_aliases
fi

# load private config
if [ -f ~/.bash/private ]; then
. ~/.bash/private
fi

export EDITOR=vim
export TMUX_HOME=/opt/bin
export PGDATA=/usr/local/var/postgres

# configure PATH
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
PATH=/usr/local/bin:/usr/local:/usr/local/sbin:$PATH

PATH=$TMUX_HOME:$CATALINA_HOME:$PATH
export PATH

clear_dns() {
  sudo killall -HUP mDNSResponder
}

copyb() {
  git branch | grep "*" | awk '{ print $2 }' | pbcopy > /dev/null
}

backb() {
  git checkout @{-1}
}

[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh

export PATH="$PATH:`yarn global bin`"

export ANDROID_HOME=~/Library/Android/sdk
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

. $HOME/.asdf/asdf.sh

. $HOME/.asdf/completions/asdf.bash
