# shell/history.sh
#
# Keep history behavior predictable across zsh and bash:
# - keep more history
# - append instead of overwrite
# - reduce obvious duplicates
# - keep shell-specific behavior conservative

if [ -n "$ZSH_VERSION" ]; then
  # Keep enough history to be useful without changing zsh defaults too much.
  HISTSIZE=50000
  SAVEHIST=50000

  # Share history across zsh sessions, including tmux panes and windows.
  setopt SHARE_HISTORY

  # Skip repeated commands and commands prefixed with a space.
  setopt HIST_IGNORE_DUPS
  setopt HIST_IGNORE_ALL_DUPS
  setopt HIST_IGNORE_SPACE

  # Clean up whitespace in stored commands and prefer dropping duplicates first.
  setopt HIST_REDUCE_BLANKS
  setopt HIST_EXPIRE_DUPS_FIRST

elif [ -n "$BASH_VERSION" ]; then
  # Match the zsh history size closely while keeping bash defaults intact.
  HISTSIZE=50000
  HISTFILESIZE=50000

  # Append to ~/.bash_history instead of overwriting it on shell exit.
  shopt -s histappend

  # Ignore commands prefixed with a space and erase older duplicate entries.
  HISTCONTROL=ignoreboth:erasedups
fi
