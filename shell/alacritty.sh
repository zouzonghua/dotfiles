# shell/alacritty.sh
#
# Keep Alacritty theme syncing separate from the main shell bootstrap.

THEME_SYNC="${HOME}/.config/alacritty/bin/theme_sync.sh"
THEME_SYNC_PID_FILE="${HOME}/.config/alacritty/.theme-sync.pid"

restart_theme_watcher() {
  local existing_pid

  existing_pid="$(cat "$THEME_SYNC_PID_FILE" 2>/dev/null || true)"
  if [ -n "$existing_pid" ]; then
    kill "$existing_pid" >/dev/null 2>&1 || true
    rm -f "$THEME_SYNC_PID_FILE"
  fi
}

if [ -x "$THEME_SYNC" ]; then
  case "$(uname -s)" in
    Darwin)
      "$THEME_SYNC" >/dev/null 2>&1
      if [ -n "${ZSH_VERSION:-}" ]; then
        if [[ -o login ]]; then
          restart_theme_watcher
          eval "nohup \"$THEME_SYNC\" --watch >/dev/null 2>&1 </dev/null &!"
        fi
      elif [ -n "${BASH_VERSION:-}" ]; then
        if shopt -q login_shell; then
          restart_theme_watcher
          nohup "$THEME_SYNC" --watch >/dev/null 2>&1 </dev/null &
          disown "$!" 2>/dev/null || true
        fi
      fi
      ;;
    Linux)
      "$THEME_SYNC" >/dev/null 2>&1
      ;;
  esac
fi
