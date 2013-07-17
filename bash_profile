source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby 1.9.3-p392

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

if [ -f `brew --prefix`/etc/bash_completion ]; then
. `brew --prefix`/etc/bash_completion
fi

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
export ODBCINI=/Library/ODBC/odbc.ini
export ODBCSYSINI=/opt
export FREETDSCONF=/opt/local/etc/freetds/freetds.conf
export CATALINA_HOME=/Users/leandronsp/programs/tomcat
export TMUX_HOME=/opt/bin
export PGDATA=/usr/local/var/postgres

# configure PATH
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
PATH=/usr/local/bin:/usr/local:/usr/local/sbin:$PATH
PATH=$TMUX_HOME:$CATALINA_HOME:$PATH
export PATH

