# General setup

export CLICOLOR=1;
export LSCOLORS=ExGxcxdxCxxxxxxxxxxxxx;
export HISTSIZE=10000
export HISTCONTROL=ignoreboth:erasedups
export BASH_SILENCE_DEPRECATION_WARNING=1

shopt -s histappend

if [[ `uname` = "Linux" ]]; then
    alias ls='ls --color=auto'
fi
alias l='ls'
alias ll='ls -lh'
alias la='ls -a'
alias d='cd ..'
alias u='cd -'

alias cdcase='cd `realpath .`'

# Set terminal title based on SSH host

echo -ne "\033[22;0t"                     #Save Title on Stack
echo -ne "\033]0;${HOSTNAME}\007"         #Set New Title
trap 'echo -ne "\033[23;0t"'  EXIT

# Locale setup

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Colors

function color_hex_to_esc()
{
    printf "2;%d;%d;%d\n" 0x${1:1:2} 0x${1:3:2} 0x${1:5:2}
}

export COLOR_RED="#E06C75"
export COLOR_GREEN="#98C379"
export COLOR_YELLOW="#E5C07B"
export COLOR_BLUE="#61AFEF"
export COLOR_MAGENTA="#C678DD"
export COLOR_CYAN="#56B6C2"

export COLOR_DIM_RED="#B2574B"
export COLOR_DIM_GREEN="#78A557"
export COLOR_DIM_YELLOW="#CA9B6E"
export COLOR_DIM_BLUE="#518BBB"
export COLOR_DIM_MAGENTA="#976CA5"
export COLOR_DIM_CYAN="#46919A"

export COLOR_RED_ESC=`color_hex_to_esc $COLOR_RED`
export COLOR_GREEN_ESC=`color_hex_to_esc $COLOR_GREEN`
export COLOR_YELLOW_ESC=`color_hex_to_esc $COLOR_YELLOW`
export COLOR_BLUE_ESC=`color_hex_to_esc $COLOR_BLUE`
export COLOR_MAGENTA_ESC=`color_hex_to_esc $COLOR_MAGENTA`
export COLOR_CYAN_ESC=`color_hex_to_esc $COLOR_CYAN`

export COLOR_DIM_RED_ESC=`color_hex_to_esc $COLOR_DIM_RED`
export COLOR_DIM_GREEN_ESC=`color_hex_to_esc $COLOR_DIM_GREEN`
export COLOR_DIM_YELLOW_ESC=`color_hex_to_esc $COLOR_DIM_YELLOW`
export COLOR_DIM_BLUE_ESC=`color_hex_to_esc $COLOR_DIM_BLUE`
export COLOR_DIM_MAGENTA_ESC=`color_hex_to_esc $COLOR_DIM_MAGENTA`
export COLOR_DIM_CYAN_ESC=`color_hex_to_esc $COLOR_DIM_CYAN`

# Prompt setup

function pwb {
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

function shortpath()
{
    if [[ $1 = '~' ]]; then
        echo $1
    else
        dir=$1
        if [[ ${1:0:1} = '~' ]]; then
            first="${1%%/*}/"
            dir="/${1#*/}"
        elif [[ ${1:0:1} = '/' ]]; then
            first='/'
        else
            first=''
        fi
        dir=${dir%/*}
        last=${1##*/}
        res=$(for i in ${dir//\// } ; do echo -n "${i:0:1}…/" ; done)
        echo "$first$res$last"
    fi
}

function shortdir()
{
    IFS='/'
    parts=($1)
    if [[ ${#parts[@]} -gt 2 ]]; then
        echo "…/${parts[${#parts[@]} - 1]}"
    else
        echo "$1"
    fi
}

function prompter() {
    # User color
    if [[ $(id -u) -eq 0 ]]; then
        usercolor="\[\033[00;35m\]"
    else
        usercolor="\[\033[00;32m\]"
    fi
    if [[ $COLUMNS -lt 79 ]]; then
        # Make a short prompt
        pt=$(shortpath `dirs`)
        export PS1="\n$usercolor\u \[\033[01;34m\]$pt\n\[\033[01;30m\]\$\[\033[00m\] "
    else
        # Git branch
        br=`pwb`
        if [[ ! -z $br ]]; then
            if [[ ${#br} -gt 40 ]]; then
                br=$(shortpath $br)
            fi
            if [[ ${#br} -gt 40 ]]; then
                br="${br:0:39}…"
            fi
            br="\[\033[00;36m\] ⎇ $br"
        fi
        # Python virtualenv
        if [[ -n $VIRTUAL_ENV ]]; then
            venvroot=`dirname $VIRTUAL_ENV`
            if [[ "$PWD/" = "$venvroot/"* ]]; then
                venvroot=`basename $venvroot`
                venvroot="\[\033[00;33m\] venv";
            else
                venvroot=`basename $venvroot`
                venvroot="\[\033[00;31m\] venv:${venvroot:0:32}";
            fi
        else
            venvroot=""
        fi
        # Make it so!
        export PS1="\n$usercolor\u@\h \[\033[01;34m\]\w$br$venvroot\n\[\033[01;30m\]\$\[\033[00m\] "
    fi
}

function chunky_prompter() {
    if [[ $? -eq 0 ]]; then
        promptchar="\[\033[38;${COLOR_GREEN_ESC}m\]❯\[\033[0m\]"
    else
        promptchar="\[\033[38;${COLOR_RED_ESC}m\]❯\[\033[0m\]"
    fi
    prompt="\n"
    len=2
    #fg="5;234"
    fg="5;231"

    # User+host
    userhost=$USER
    if [[ -z $TMUX ]]; then
        userhost="$userhost@`hostname -s`"
    fi
    len=$((len + ${#userhost} + 5))

    # Directory
    dir=`dirs`
    len=$((len + ${#dir} + 5))

    # Git branch
    gitbr=" `pwb`"
    isnotgit=$?
    len=$((len + ${#gitbr} + 4))

    # Python virtualenv
    if [[ -n $VIRTUAL_ENV ]]; then
	venvroot=`dirname $VIRTUAL_ENV`
        venvname=" `basename $venvroot`"
	len=$((len + ${#venvname} + 4))
    else
        venvname=""
    fi

    # Do our best to shorten the prompt, as needed
    if [[ $len -gt $COLUMNS && -n $venvname ]]; then
	len=$((len - ${#venvname}))
	venvname=""
    fi

    if [[ $len -gt $COLUMNS && -n $gitbr ]]; then
	len=$((len - ${#gitbr}))
	gitbr=" `shortdir $gitbr`"
	len=$((len + ${#gitbr}))
	if [[ $len -gt $COLUMNS ]]; then
	    len=$((len - ${#gitbr}))
	    gitbr=" ${gitbr:0:18}…"
	    len=$((len + ${#gitbr}))
	fi
	if [[ $len -gt $COLUMNS ]]; then
	    len=$((len - ${#gitbr}))
	    gitbr=""
	fi
    fi

    if [[ $len -gt $COLUMNS ]]; then
	dir=`shortdir $dir`
    fi

    # User+host
    if [[ `uname` = "Darwin" ]]; then
        usericon=""
    else
        usericon="󰻀"
    fi
    if [[ $(id -u) -eq 0 ]]; then
        bg=$COLOR_DIM_MAGENTA_ESC
    else
        bg=$COLOR_DIM_GREEN_ESC
    fi
    prompt="${prompt}\[\033[38;${bg}m\]\[\033[48;${bg}m\]\[\033[38;${fg}m\]$usericon $userhost\[\033[38;${bg}m\]"
    prompt="${prompt}"

    # Directory
    bg=$COLOR_DIM_BLUE_ESC
    prompt="${prompt}\[\033[48;${bg}m\] \[\033[38;${fg}m\] ${dir}\033[38;${bg}m\]"

    # Git branch
    if [[ $isnotgit -eq 0 ]]; then
	bg=$COLOR_DIM_CYAN_ESC
        prompt="${prompt}\[\033[48;${bg}m\] \[\033[38;${fg}m\]${gitbr}\033[38;${bg}m\]"
    fi

    # Python virtualenv
    if [[ -n $VIRTUAL_ENV ]]; then
	if [[ "$PWD/" = "$venvroot/"* ]]; then
	    bg=$COLOR_DIM_YELLOW_ESC
	else
	    bg=$COLOR_DIM_RED_ESC
	fi
        prompt="${prompt}\[\033[48;${bg}m\] \[\033[38;${fg}m\]󱔎${venvname}\033[38;${bg}m\]"
    fi

    # Make it so!
    prompt="${prompt} \[\033[0m\]\[\033[38;${bg}m\] \[\033[0m\]\n${promptchar} "
    export PS1=$prompt
}

PROMPT_COMMAND=chunky_prompter

# Virtualenv setup
alias venv='source venv/bin/activate 2> /dev/null || source venv3/bin/activate 2> /dev/null || source .venv/bin/activate'
export VIRTUAL_ENV_DISABLE_PROMPT=1
if [[ -n $VIRTUAL_ENV ]]; then
    if [[ `which python` != "$VIRTUAL_ENV"* ]]; then
        unset VIRTUAL_ENV
    fi
fi

# Sublime text setup

if [[ -d "/Applications/Sublime Text.app/Contents/SharedSupport/bin" && ":$PATH:" != *":/Applications/Sublime Text.app/Contents/SharedSupport/bin:"* ]]; then
    PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin":$PATH
fi

# nvim setup
if which nvim > /dev/null 2>&1; then
    alias vim=nvim
fi

# Git setup

alias gc='git commit'
alias gd='git diff'
alias gf='git fetch'
alias gg='git grep -n'
#alias gl='git --no-pager log -3'
alias gs='git status'
alias gp='git pull --ff-only'
alias ga='git add -u;git status'
alias gt='git checkout'
alias git-cleanup='git remote prune origin;git branch -v|grep "\[gone\]"|cut -d" " -f3|xargs git branch -D'

function gl() {
    git --no-pager log --max-count ${1-3}
}

if [[ -d "/usr/local/git/bin" && ":$PATH:" != *":/usr/local/git/bin:"* ]]; then
    PATH="/usr/local/git/bin":$PATH
fi

if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

# FZF setup
export FZF_DEFAULT_OPTS="--color=16,border:241,bg:-1,bg+:-1 --cycle"

# Pyenv setup
if [[ -d "$HOME/.pyenv/bin" && ":$PATH:" != *":$HOME/.pyenv/bin:"* ]]; then
    PATH="$HOME/.pyenv/bin":$PATH
    if which pyenv > /dev/null 2>&1;
        then eval "$(pyenv init -)";
    fi
fi

# Pipenv setup
export PIPENV_VENV_IN_PROJECT=1

# Go setup
export GOPATH=$HOME/Projects/go
if [[ -d "$GOPATH/bin" && ":$PATH:" != *":$GOPATH/bin:"* ]]; then
    PATH="$GOPATH/bin":$PATH
fi

# Poetry setup
if [[ -d "$HOME/.poetry/bin" && ":$PATH:" != *":$HOME/.poetry/bin:"* ]]; then
    PATH="$HOME/.poetry/bin":$PATH
fi

# Pipx setup
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    PATH="$HOME/.local/bin":$PATH
fi

# Brew setup
if [[ -d "/usr/local/sbin" && ":$PATH:" != *":/usr/local/sbin:"* ]]; then
    PATH="/usr/local/sbin":$PATH
fi

# Home bin setup

if [[ -d "$HOME/bin" && ":$PATH:" != *":$HOME/bin:"* ]]; then
    PATH="$HOME/bin":$PATH
fi

# Java setup

if [[ -d "/Library/Java/JavaVirtualMachines/jdk1.8.0_341.jdk/Contents/Home" ]]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_341.jdk/Contents/Home"
    PATH="$JAVA_HOME/bin":$PATH
fi

if [[ -d "/Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home" ]]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home"
    PATH="$JAVA_HOME/bin":$PATH
fi

if [[ -d "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home" ]]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
    PATH="$JAVA_HOME/bin":$PATH
fi

# Rust setup

if [[ -d "$HOME/.cargo" && ":$PATH:" != *"/Users/jimorie/.cargo/bin"* ]]; then
    source "$HOME/.cargo/env"
fi

# Opsview setup

alias livehack='find . -name '\''*.py'\'' -exec mv -v '\''{}c'\'' '\''{}c.orig'\'' \;'
alias liveunhack='find . -name '\''*.py'\'' -exec mv -v '\''{}c.orig'\'' '\''{}c'\'' \;'
alias gr='_sel=( $(git review -l --color=always | sed -e "$ d" | fzf --ansi --no-sort --border-label="Select change to git review -d" --border=top --color=label:red) ) && git review -d ${_sel[0]}'

# Envman setup
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
