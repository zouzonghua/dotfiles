#===============================================================================
# \time zsh -i -c exit
# \time zsh --no-rcs -i -c exit
#===============================================================================
export ZSH=~/.zsh

#===============================================================================
# Enable color
#===============================================================================
autoload -U colors && colors

#===============================================================================
# Plugins
#===============================================================================
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/z/z.sh

#===============================================================================
# Prompt
#===============================================================================
git_prompt_info() {
  local ref=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "${ref}" ]; then
    if [ -n "$(git status --porcelain)" ]; then
      local gitstatuscolor='%F{red}'
      local flag='✗'
    else
      local gitstatuscolor='%F{blue}'
      local flag='✔'
    fi
    echo "${gitstatuscolor}  ${ref} ${flag}%F{none}"
  else
    echo ""
  fi
}
setopt PROMPT_SUBST

PROMPT="%(?:%{$fg[green]%}%n% :%{$fg[red]%}%n% ) "
PROMPT+="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+='%{$fg[blue]%}%c%{$reset_color%}$(git_prompt_info) '

# add 24h time the right side
# RPROMPT="%(?:%{$fg[green]%}%D{%k:%M:%S} :%{$fg[red]%}%D{%k:%M:%S} )"
# RPROMPT='%D{%k:%M:%S}'

#===============================================================================
# Locale
#===============================================================================
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#===============================================================================
# Nvm
#===============================================================================
export NVM_DIR="$HOME/.nvm"
nvm() {
  . "$NVM_DIR/nvm.sh"
  nvm $@
}
export PATH=$HOME/.nvm/versions/node/v16.17.0/bin/:$PATH

#===============================================================================
# Alias
#===============================================================================
alias proxy="export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;export ALL_PROXY=socks5://127.0.0.1:1080 && curl ip.sb"
alias unproxy="unset http_proxy https_proxy ALL_PROXY && curl ip.sb"

alias brewUpdate='brew update && brew upgrade && brew cu -a -y && brew cleanup && brew cleanup --prune 0'

alias g="git"
alias ssh='TERM=xterm ssh'

alias t='trans'
alias ten='trans :en'
alias tcn='trans :zh-CN'
alias ttw='trans :zh-TW'

alias et='emacsclient -a "" -t'
alias ec='emacsclient -a "" -c -n'
alias eq='emacsclient -e "(kill-emacs)"'

#===============================================================================
# Path
#===============================================================================
export PATH="/usr/local/sbin:$PATH"
