# shell/aliases.sh

# Git
alias g='git'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Productivity
if [[ "$(uname -s)" == "Darwin" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
