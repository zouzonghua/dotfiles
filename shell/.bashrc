# ~/.bashrc --- Aliases, functions, and variables for Bash

# Shorter version of a common command that it used herein.
_checkexec ()
{
    command -v "$1" > /dev/null
}

### General settings

# Include my scripts in the PATH.
if [ -d "$HOME"/bin ]
then
    PATH=$PATH:"$HOME"/bin
fi

if [ -d "$HOME"/.local/bin ]
then
    PATH=$PATH:"$HOME"/.local/bin
fi

# Default editor.
if pgrep -x emacs > /dev/null
then
    export VISUAL="emacsclient -c"
    export EDITOR="emacsclient -t"
elif _checkexec vim
then
    export VISUAL=vim
    export EDITOR=$VISUAL
fi

# Default browser.  This leverages the MIME list.
export BROWSER=/usr/bin/xdg-open

# Prompt
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

parse_git_dirty() {
  [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}
parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w'
    PS1+="\[\033[33m\]\$(parse_git_branch)\[\033[00m\]$ "
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt

# The following is taken from the .bashrc shipped with Debian 9.  Enable
# programmable completion features (you don't need to enable this, if
# it's already enabled in /etc/bash.bashrc and /etc/profile sources
# /etc/bash.bashrc).
if ! shopt -oq posix
then
    if [ -f /usr/share/bash-completion/bash_completion ]
    then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]
    then
        . /etc/bash_completion
    fi
fi

# Enable tab completion when starting a command with 'sudo'
[ "$PS1" ] && complete -cf sudo

# If not running interactively, don't do anything.  This too is taken
# from Debian 9's bashrc.
case $- in
    *i*) ;;
    *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
# See `man bash` for more options.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in `man bash`.
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary, update the
# values of LINES and COLUMNS.
shopt -s checkwinsize

# Make `less` more friendly for non-text input files.
_checkexec lesspipe && eval "$(SHELL=/bin/sh lesspipe)"

### Aliases

# A note on how I define aliases.  I try to abstract the command into
# its initials or something that resembles the original.  This helps me
# remember the original command when necessary.  There are some
# exceptions for commands I seldom execute.

#### Pacman and Yay (Arch Linux)

if _checkexec pacman
then
    # General package management
    alias pSyu="sudo pacman -Syu"   # system upgrade
    alias pSyyu="sudo pacman -Syyu" # when updating mirrors
    alias pD="sudo pacman -D"       # set `--asdeps` or `--asexplicit`

    # Search remote database and download packages
    alias pSs="pacman -Ss"      # search remote for package
    alias pS="sudo pacman -S"   # sync download

    # Search local database
    alias pQs="pacman -Qs"      # query list
    alias pQmq="pacman -Qmq"    # list foreign packages
    alias pQdt="pacman -Qdt"    # list orphans

    # Inspect packages (remote and local)
    alias pSi="pacman -Si"      # remote package details
    alias pQi="pacman -Qi"      # local package details

    # Remove packages
    alias pRs="sudo pacman -Rs"     # remove package
    alias pRnsc="sudo pacman -Rnsc" # remove package recursively

    # Clear cache
    alias pcache1="sudo paccache -rk 1" # remove cache except last item
    alias pcache0="sudo paccache -ruk0" # remove all cache
fi

if _checkexec yay
then
    alias ySyu="yay -Syu"       # upgrade aur
    alias yS="yay -S"           # sync download AUR
    alias ySs="yay -Ss"         # search aur
    alias ySi="yay -Si"         # see remote package details
fi

#### Common tasks and utilities

# Check these because some of them modify the behaviour of standard
# commands, such as `cp`, `mv`, `rm`, so that they provide verbose
# output and open a prompt when an existing file is affected.
#
# PRO TIP to ignore aliases, start them with a backslash \.  The
# original command will be used.  This is useful when the original
# command and the alias have the same name.  Example is my `cp` which is
# aliased to `cp -iv`:
#
#   cp == cp -iv
#   \cp == cp

# cd into the previous working directory by omitting `cd`.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safer default for cp, mv, rm.  These will print a verbose output of
# the operations.  If an existing file is affected, they will ask for
# confirmation.  This can make things a bit more cumbersome, but is a
# generally safer option.
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'

# Enable automatic color support for common commands that list output

alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Make ls a bit easier to read.  Note that the -A is the same as -a but
# does not include implied paths (the current dir denoted by a dot and
# the previous dir denoted by two dots).  I would also like to use the
# -p option, which prepends a forward slash to directories, but it does
# not seem to work with symlinked directories. For more, see `man ls`.
alias ls='ls -pv --color=auto --group-directories-first'
alias lsa='ls -pvA --color=auto --group-directories-first'
alias lsl='ls -lhpv --color=auto --group-directories-first'
alias lsla='ls -lhpvA --color=auto --group-directories-first'


#### Extra tasks and infrequently used tools
if _checkexec mpv
then
    alias et='emacsclient -a "" -t'
    alias ec='emacsclient -a "" -c -n'
    alias eq='emacsclient -e "(kill-emacs)"'
fi

if _checkexec git
then
    alias g="git"
fi

### Functions

# Colourise man pages
man ()
{
    env \
        LESS_TERMCAP_mb=$(tput bold; tput setaf 6) \
        LESS_TERMCAP_md=$(tput bold; tput setaf 6) \
        LESS_TERMCAP_me=$(tput sgr0) \
        LESS_TERMCAP_se=$(tput rmso; tput sgr0) \
        LESS_TERMCAP_ue=$(tput rmul; tput sgr0) \
        LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 4) \
        LESS_TERMCAP_mr=$(tput rev) \
        LESS_TERMCAP_mh=$(tput dim) \
        LESS_TERMCAP_ZN=$(tput ssubm) \
        LESS_TERMCAP_ZV=$(tput rsubm) \
        LESS_TERMCAP_ZO=$(tput ssupm) \
        LESS_TERMCAP_ZW=$(tput rsupm) \
        man "$@"
}

# Back up a file. Usage "backupthis <filename>"
backupthis ()
{
    cp -riv $1 ${1}-$(date +%Y%m%d%H%M).backup;
}

