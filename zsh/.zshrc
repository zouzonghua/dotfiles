
#===============================================================================
# \time zsh -i -c exit
#===============================================================================
  export ZSH="~/.zsh"

#===============================================================================
# plugins
#===============================================================================
  source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  . ~/.zsh/plugins/z/z.sh

#===============================================================================
# enable color
#===============================================================================
  autoload -U colors && colors

#===============================================================================
# prompt config
#===============================================================================
  git_prompt_info() {
    local ref=$(git symbolic-ref --short HEAD 2> /dev/null)
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
  # PROMPT='%{$fg[green]%}%n%{$reset_color%} %{$fg[green]%}➜ %{$fg[yellow]%}%1~%{$reset_color%}$(git_prompt_info) '
   PROMPT="%(?:%{$fg[green]%}%n% :%{$fg[red]%}%n% ) "
  # PROMPT+="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
   PROMPT+="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
   PROMPT+='%{$fg[yellow]%}%c%{$reset_color%}$(git_prompt_info) '

  # add 24h time the right side
  # RPROMPT="%(?:%{$fg[green]%}%D{%k:%M:%S} :%{$fg[red]%}%D{%k:%M:%S} )"
  # RPROMPT='%D{%k:%M:%S}'

#===============================================================================
# nvm config
#===============================================================================
  # export NVM_DIR="$HOME/.nvm"
  # [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  # [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
  export NVM_DIR="$HOME/.nvm"
  nvm() { . "$NVM_DIR/nvm.sh" ; nvm $@ ; }
  export PATH=$HOME/.nvm/versions/node/v14.18.3/bin/:$PATH

#===============================================================================
# alias
#===============================================================================
  alias proxy="export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;export ALL_PROXY=socks5://127.0.0.1:1080 && curl ip.sb"
  alias unproxy="unset http_proxy https_proxy ALL_PROXY && curl ip.sb"
  alias brewUpdate='brew update && brew upgrade && brew cu -a -y && brew cleanup && brew cleanup --prune 0'

  alias vi="nvim"
  alias vim="nvim"
  alias g="git"
  alias ssh='TERM=xterm ssh'
  alias ll='ls -lhAF'

  alias t='trans'
  alias ten='trans :en'
  alias tcn='trans :zh-CN'
  alias ttw='trans :zh-TW'

#===============================================================================
# locale
#===============================================================================
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8

  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

#===============================================================================
# android sdk
#===============================================================================
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools

#===============================================================================
# set tmux-spotify to use Apple Music instead of Spotify
#===============================================================================
export MUSIC_APP="Spotify"

#===============================================================================
# other
#===============================================================================
export PATH="/usr/local/sbin:$PATH"

