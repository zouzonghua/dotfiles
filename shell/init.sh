# shell/init.sh
#
# Single entry point for shell customizations managed by this repo.

[ -f "${HOME}/.config/shell/history.sh" ] && . "${HOME}/.config/shell/history.sh"
[ -f "${HOME}/.config/shell/aliases.sh" ] && . "${HOME}/.config/shell/aliases.sh"
[ -f "${HOME}/.config/shell/prompt.sh" ] && . "${HOME}/.config/shell/prompt.sh"
