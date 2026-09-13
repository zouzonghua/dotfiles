# shell/prompt.sh
#
# Keep the prompt close to the familiar Debian style:
# - user@host in green
# - cwd in blue
# - git branch appended when inside a repository

prompt_git_state() {
  local status line branch oid
  status=$(git status --porcelain=v2 --branch --no-ahead-behind 2>/dev/null) || return

  PROMPT_GIT_BRANCH=''
  PROMPT_GIT_DIRTY=0
  while IFS= read -r line; do
    case "$line" in
      "# branch.head "*) branch=${line#\# branch.head }; PROMPT_GIT_BRANCH=$branch ;;
      "# branch.oid "*) oid=${line#\# branch.oid } ;;
      "# "*) ;;
      *) PROMPT_GIT_DIRTY=1 ;;
    esac
  done <<< "$status"

  if [ "$PROMPT_GIT_BRANCH" = '(detached)' ]; then
    PROMPT_GIT_BRANCH=${oid:0:7}
  fi
  [ -n "$PROMPT_GIT_BRANCH" ]
}

prompt_git_segment_bash() {
  local color_open color_close
  prompt_git_state || return

  if [ "$PROMPT_GIT_DIRTY" -eq 1 ]; then
    color_open=$'\001\033[31m\002'
  else
    color_open=$'\001\033[32m\002'
  fi
  color_close=$'\001\033[0m\002'

  printf '%s[%s]%s' "$color_open" "$PROMPT_GIT_BRANCH" "$color_close"
}

prompt_git_segment_zsh() {
  local color_open color_close
  prompt_git_state || return

  if [ "$PROMPT_GIT_DIRTY" -eq 1 ]; then
    color_open='%F{red}'
  else
    color_open='%F{green}'
  fi
  color_close='%f'

  printf '%s[%s]%s' "$color_open" "$PROMPT_GIT_BRANCH" "$color_close"
}

if [ -n "${ZSH_VERSION-}" ]; then
  setopt PROMPT_SUBST
  PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b$(prompt_git_segment_zsh)%# '

elif [ -n "${BASH_VERSION-}" ]; then
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(prompt_git_segment_bash)\$ '
fi
