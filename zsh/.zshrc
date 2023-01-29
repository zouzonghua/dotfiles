#===============================================================================
# \time zsh -i -c exit
#===============================================================================
export ZSH=~/.zsh

#===============================================================================
# enabled history
#===============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

#===============================================================================
# enable color
#===============================================================================
autoload -U colors && colors

#===============================================================================
# plugins
#===============================================================================
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
. ~/.zsh/plugins/z/z.sh

#===============================================================================
# prompt
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
# PROMPT='%{$fg[green]%}%n%{$reset_color%} %{$fg[green]%}➜ %{$fg[yellow]%}%1~%{$reset_color%}$(git_prompt_info) '
PROMPT="%(?:%{$fg[green]%}%n% :%{$fg[red]%}%n% ) "
# PROMPT+="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+='%{$fg[blue]%}%c%{$reset_color%}$(git_prompt_info) '

#===============================================================================
# alias
#===============================================================================
alias ls='ls -v -F --color=auto'
alias ll='ls -al'
alias la='ls -A'
alias cp='cp -ip'
alias mv='mv -i'
alias rm='rm -i'
alias du='du -h'
alias df='df -h'
alias g="git"
alias et='emacsclient -a "" -t'
alias ec='emacsclient -a "" -c -n'
alias eq='emacsclient -e "(kill-emacs)"'

alias proxy="export http_proxy=http://127.0.0.1:7890;export https_proxy=http://127.0.0.1:7890;export ALL_PROXY=socks5://127.0.0.1:7890 && curl ip.sb"
alias unproxy="unset http_proxy https_proxy ALL_PROXY && curl ip.sb"


#===============================================================================
# locale
#===============================================================================
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


#===============================================================================
# bin
#===============================================================================
export PATH=$HOME/bin:$HOME/.local/bin:$PATH


