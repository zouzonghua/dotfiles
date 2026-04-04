# ─────────────────────────────────────────────
# git_prompt.sh  — bash & zsh universal prompt
# ─────────────────────────────────────────────

_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null) \
    || return
  echo "$branch"
}

_git_dirty() {
  git diff-index --quiet HEAD -- 2>/dev/null || return 0
  [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]
}

_git_prompt() {
  git rev-parse --git-dir &>/dev/null || return

  local branch
  branch=$(_git_branch) || return

  local color_open color_close
  if _git_dirty; then
    if [ -n "$ZSH_VERSION" ]; then
      color_open="%F{red}" color_close="%f"
    else
      color_open="\[\033[31m\]" color_close="\[\033[0m\]"
    fi
  else
    if [ -n "$ZSH_VERSION" ]; then
      color_open="%F{green}" color_close="%f"
    else
      color_open="\[\033[32m\]" color_close="\[\033[0m\]"
    fi
  fi

  echo " ${color_open}[${branch}]${color_close}"
}

if [ -n "$ZSH_VERSION" ]; then
  setopt PROMPT_SUBST
  autoload -Uz add-zsh-hook

  _set_git_ps1() {
    [ -z "$_ORIGINAL_PS1" ] && _ORIGINAL_PS1="$PS1"
    local git_part
    git_part=$(_git_prompt)
    if [ -n "$git_part" ]; then
      PS1="${_ORIGINAL_PS1%% \%#*}${git_part} %# "
    else
      PS1="$_ORIGINAL_PS1"
    fi
  }

  add-zsh-hook precmd _set_git_ps1

elif [ -n "$BASH_VERSION" ]; then
  _ORIGINAL_PS1="$PS1"

  _set_git_ps1() {
    local git_part stripped
    git_part=$(_git_prompt)
    if [ -n "$git_part" ]; then
      stripped=$(echo "$_ORIGINAL_PS1" | sed 's/\\$ $//')
      PS1="${stripped}${git_part} \\$ "
    else
      PS1="$_ORIGINAL_PS1"
    fi
  }

  PROMPT_COMMAND="_set_git_ps1${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
