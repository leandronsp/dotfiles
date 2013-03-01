if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
export RBENV_ROOT=~/.rbenv
RBENV_SHIMS=~/.rbenv/shims
alias rvm=rbenv

git_prompt_info() {
 git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\/\(.*\)/ (\1)/' 2> /dev/null
}

export PS1="\[\033[1;34m\]\u:\w\[\033[1;31m\]\$(git_prompt_info)\[\033[0m\] ➤ "
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

export TERM="screen-256color"
export ODBCINI=/Library/ODBC/odbc.ini
export ODBCSYSINI=/opt
export FREETDSCONF=/opt/local/etc/freetds/freetds.conf
export CATALINA_HOME=/Users/leandronsp/programs/tomcat
export TMUX_HOME=/opt/bin

# configure PATH
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
PATH=/usr/local/bin:/usr/local:/usr/local/sbin:$PATH
PATH=$TMUX_HOME:$CATALINA_HOME:$RBENV_SHIMS:$PATH
export PATH

