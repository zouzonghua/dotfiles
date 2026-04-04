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
  setopt HIST_IGNORE_SPACE

  # Clean up whitespace in stored commands without aggressively rewriting history.
  setopt HIST_REDUCE_BLANKS

elif [ -n "$BASH_VERSION" ]; then
  # Match the zsh history size closely while keeping bash defaults intact.
  HISTSIZE=50000
  HISTFILESIZE=50000

  # Append to ~/.bash_history instead of overwriting it on shell exit.
  shopt -s histappend

  # Ignore commands prefixed with a space and avoid obvious duplicate noise.
  HISTCONTROL=ignoreboth

  # On each new prompt, write this session's new commands and then import
  # commands written by other bash sessions. In tmux this means another pane's
  # history usually becomes visible after you hit Enter and return to a prompt.
  PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
