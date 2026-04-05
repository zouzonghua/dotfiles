# shell/alacritty.sh
#
# Keep Alacritty theme syncing separate from the main shell bootstrap.

if [ -x "${HOME}/.config/alacritty/bin/theme_sync.sh" ]; then
  case "$(uname -s)" in
    Darwin)
      if [ -n "${ZSH_VERSION:-}" ]; then
        if [[ -o login ]]; then
          eval "nohup \"${HOME}/.config/alacritty/bin/theme_sync.sh\" --watch >/dev/null 2>&1 </dev/null &!"
        fi
      elif [ -n "${BASH_VERSION:-}" ]; then
        if shopt -q login_shell; then
          nohup "${HOME}/.config/alacritty/bin/theme_sync.sh" --watch >/dev/null 2>&1 </dev/null &
          disown "$!" 2>/dev/null || true
        fi
      fi
      ;;
    Linux)
      "${HOME}/.config/alacritty/bin/theme_sync.sh" >/dev/null 2>&1
      ;;
  esac
fi
