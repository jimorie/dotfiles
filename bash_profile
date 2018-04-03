# Locale setup

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Prompt setup

#PS1="\n\[\033[00;32m\]\u@\h\[\033[00;33m\]\$(if [[ -n \$VIRTUAL_ENV ]]\; then echo basename \$VIRTUAL_ENV; else echo " "\; fi)\[\033[00;36m\]\$(git branch 2>/dev/null | grep '^*' | colrm 1 1) \[\033[01;34m\]\w\n\[\033[01;30m\]\$\[\033[00m\] "

PROMPT_COMMAND=prompter

function prompter() {
    export PS1="\n\[\033[00;32m\]\u@\h$(_venv)\[\033[00;36m\]$(_gitbranch) \[\033[01;34m\]\w\n\[\033[01;30m\]\$\[\033[00m\] "
}

function _gitbranch {
    git branch 2>/dev/null | grep '^*' | colrm 1 1
}

function _venv {
    if [[ -n $VIRTUAL_ENV ]]; then
        venvroot=`dirname $VIRTUAL_ENV`
        if [[ "$PWD/" = "$venvroot/"* ]]; then
            echo "\[\033[00;33m\] `basename $VIRTUAL_ENV`"; 
        else
            echo "\[\033[00;31m\] `basename $VIRTUAL_ENV`"; 
        fi
    fi
}

export CLICOLOR=1;
export LSCOLORS=ExGxcxdxCxxxxxxxxxxxxx;

if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin":$PATH
fi

alias ll='ls -l'
alias la='ls -a'

# Git setup
alias gc='git commit'
alias gd='git diff'
alias gf='git fetch'
alias gg='git grep -n'
alias gl='git --no-pager log -3'
alias gs='git status'
alias gp='git pull --ff-only'
alias ga='git add -u;git status'
alias go='git checkout'

if [ -d "/usr/local/git/bin" ]; then
    PATH="/usr/local/git/bin":$PATH
fi

if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

# Pyenv setup
if which pyenv > /dev/null;
    then eval "$(pyenv init -)";
    alias py2="pyenv shell 2.7.13;export PATH=$(echo $PATH | sed -e 's/:\/Users\/jimorie\/.pyenv\/versions\/[^:]*//g');export PATH='$PATH:/Users/jimorie/.pyenv/versions/2.7.13/bin'"
    alias py3="pyenv shell 3.4.6;export PATH=$(echo $PATH | sed -e 's/:\/Users\/jimorie\/.pyenv\/versions\/[^:]*//g');export PATH='$PATH:/Users/jimorie/.pyenv/versions/3.4.6/bin'"
fi

# Virtualenv setup
alias venv='source .venv/bin/activate'
export VIRTUAL_ENV_DISABLE_PROMPT=1
if [[ -n $VIRTUAL_ENV ]]; then
    if [[ `which python` != "$VIRTUAL_ENV"* ]]; then
        unset VIRTUAL_ENV
    fi
fi

# Pipenv setup
export PIPENV_VENV_IN_PROJECT=1

# Go setup
export GOPATH=$HOME/Projects/go
export PATH=$PATH:$GOPATH/bin
