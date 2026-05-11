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

# Terminal specific
if [[ "$TERM" == "xterm-kitty" ]] && command -v kitty >/dev/null 2>&1; then
    alias ssh="kitty +kitten ssh"
fi
