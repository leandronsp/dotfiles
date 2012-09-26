[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
git_prompt_info() {
 git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\/\(.*\)/ (\1)/' 2> /dev/null
}

export PS1="\[\033[1;34m\]\u:\w\[\033[1;31m\]\$(git_prompt_info)\[\033[0m\] ➤ "
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

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


export ODBCINI=/Library/ODBC/odbc.ini
export ODBCSYSINI=/opt
export FREETDSCONF=/opt/local/etc/freetds/freetds.conf
export CATALINA_HOME=/Users/leandronsp/programs/tomcat
export PATH=$CATALINA_HOME:$PATH
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

