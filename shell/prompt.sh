# shell/prompt.sh
#
# Keep the prompt close to the familiar Debian style:
# - user@host in green
# - cwd in blue
# - git branch appended when inside a repository

prompt_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null) \
    || return
  printf '%s\n' "$branch"
}

prompt_git_dirty() {
  git diff-index --quiet HEAD -- 2>/dev/null || return 0
  [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]
}

prompt_git_segment_bash() {
  git rev-parse --git-dir >/dev/null 2>&1 || return

  local branch color_open color_close
  branch=$(prompt_git_branch) || return

  if prompt_git_dirty; then
    color_open=$'\001\033[31m\002'
  else
    color_open=$'\001\033[32m\002'
  fi
  color_close=$'\001\033[0m\002'

  printf '%s[%s]%s' "$color_open" "$branch" "$color_close"
}

prompt_git_segment_zsh() {
  git rev-parse --git-dir >/dev/null 2>&1 || return

  local branch color_open color_close
  branch=$(prompt_git_branch) || return

  if prompt_git_dirty; then
    color_open='%F{red}'
  else
    color_open='%F{green}'
  fi
  color_close='%f'

  printf '%s[%s]%s' "$color_open" "$branch" "$color_close"
}

if [ -n "$ZSH_VERSION" ]; then
  setopt PROMPT_SUBST
  PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b$(prompt_git_segment_zsh)%# '

elif [ -n "$BASH_VERSION" ]; then
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(prompt_git_segment_bash)\$ '
fi
