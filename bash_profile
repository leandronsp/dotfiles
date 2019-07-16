source /usr/local/share/chruby/chruby.sh
chruby 2.5.1

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
  local RED_LIGHT="\[\033[0;91m\]"
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
  export PS1="\n$CYAN\u:$YELLOW\w$RED_LIGHT\$(git_prompt_info)$CYAN \\$ "
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

gu() {
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

gd() {
  git pull --rebase origin $(git rev-parse --abbrev-ref HEAD)
}

masterplease() {
  git fetch --all
  git merge origin/master
}

clear_dns() {
  sudo killall -HUP mDNSResponder
}

abl() {
  PROJECT=$1

  if [ -z $PROJECT ]; then
    echo "Missing project"
    return 1
  fi

  GEM_PATH="/Users/leandro/Documents/code/$PROJECT"

  if [ $PROJECT = "sabe-core-models" ]; then
    GEM_NAME="bugle_core"
  elif [ $PROJECT = "sabe-learn" ]; then
    GEM_NAME="sabe_learn"
  elif [ $PROJECT = "sabe-translations" ]; then
    GEM_NAME="sabe_translations"
  elif [ $PROJECT = "omniauth-leo-pharma" ]; then
    GEM_NAME="omniauth_bugle"
  else
    echo "Unkown project"
    return 1
  fi

  bundle config --local local.$GEM_NAME $GEM_PATH
}

rbl() {
  PROJECT=$1

  if [ -z $PROJECT ]; then
    echo "Missing project"
    return 1
  fi

  if [ $PROJECT = "sabe-core-models" ]; then
    GEM_NAME="bugle_core"
  elif [ $PROJECT = "sabe-learn" ]; then
    GEM_NAME="sabe_learn"
  elif [ $PROJECT = "sabe-translations" ]; then
    GEM_NAME="sabe_translations"
  elif [ $PROJECT = "omniauth-leo-pharma" ]; then
    GEM_NAME="omniauth_bugle"
  else
    echo "Unkown project"
    return 1
  fi

  bundle config --delete local.$GEM_NAME
}

rblall() {
  bundle config --delete local.bugle_core
  bundle config --delete local.sabe_learn
  bundle config --delete local.sabe_translations
  bundle config --delete local.omniauth_bugle
}

gotob() {
  git branch | grep "$1" | git checkout `awk '{ print $1 }'`
}

fdxrails() {
  PORT=$1

  if [ -z $PORT ]; then
    echo "Missing port"
    return 1
  fi

	kill -9 $(lsof -i tcp:$PORT | grep ruby | awk '{print $2}')
	bundle exec rails s -p $PORT
}

gobo() {
	kill -9 $(lsof -i tcp:3001 | grep ruby | awk '{print $2}')
	bundle; bundle exec rails s -p 3001
}

gofo() {
	kill -9 $(lsof -i tcp:3000 | grep ruby | awk '{print $2}')
	bundle; bundle exec rails s -p 3000
}

copyb() {
  git branch | grep "*" | awk '{ print $2 }' | pbcopy > /dev/null
}

cb() {
  git branch | grep "*" | awk '{ print $2 }' | pbcopy > /dev/null
}

backb() {
  git checkout @{-1}
}

byarn() {
  bundle && yarn && yarn start
}

fompila() {
  tmux new-session -s bgl -d
  tmux new-window -n backoffice
}

[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh

export ANDROID_HOME=~/Library/Android/sdk
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

. $HOME/.asdf/asdf.sh

. $HOME/.asdf/completions/asdf.bash

. $HOME/.asdf/asdf.sh

. $HOME/.asdf/completions/asdf.bash
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PKG_CONFIG_PATH=:/usr/local/opt/imagemagick@6/lib/pkgconfig

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/usr/local/opt/sqlite/bin:$PATH"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/opt/postgresql@9.4/bin:$PATH"

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# for Zeus
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export PATH=~/Library/Python/3.7/bin/:$PATH

stty start undef
stty stop undef
