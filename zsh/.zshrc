export ZSH="/Users/zouzonghua/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
. $ZSH_CUSTOM/plugins/z/z.sh


# Alias
alias proxy="export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;export ALL_PROXY=socks5://127.0.0.1:1080 && curl ip.sb"
alias unproxy="unset http_proxy https_proxy ALL_PROXY && curl ip.sb"

alias brewUpdate='brew update && brew upgrade && brew cu -a -y && brew cleanup && brew cleanup --prune 0'

alias vi="nvim"
alias vim="nvim"

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

