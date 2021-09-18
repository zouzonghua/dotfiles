
# \time zsh -i -c exit

export ZSH="~/.zsh"

# plugins
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
. ~/.zsh/plugins/z/z.sh

# enable color
autoload -U colors && colors

# prompt
setopt prompt_subst
PROMPT='❰%{$fg[green]%}%n%{$reset_color%}|%{$fg[yellow]%}%1~%{$reset_color%}%{$fg[blue]%}$(git branch --show-current 2&> /dev/null | xargs -I branch echo "(branch)")%{$reset_color%}❱ '

# nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
# [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
nvm() { . "$NVM_DIR/nvm.sh" ; nvm $@ ; }
export PATH=$HOME/.nvm/versions/node/v14.17.3/bin/:$PATH

# alias
alias proxy="export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;export ALL_PROXY=socks5://127.0.0.1:1080 && curl ip.sb"
alias unproxy="unset http_proxy https_proxy ALL_PROXY && curl ip.sb"
alias brewUpdate='brew update && brew upgrade && brew cu -a -y && brew cleanup && brew cleanup --prune 0'
alias vi="nvim"
alias vim="nvim"
alias g="git"
alias ssh='TERM=xterm ssh'

