#!/bin/bash

set -euo pipefail

ALACRITTY_DIR="${HOME}/.config/alacritty"
THEME_FILE="${ALACRITTY_DIR}/theme-active.generated.toml"
LIGHT_THEME="${ALACRITTY_DIR}/theme-light.toml"
DARK_THEME="${ALACRITTY_DIR}/theme-dark.toml"
WATCH_INTERVAL=5
PID_FILE="${ALACRITTY_DIR}/.theme-sync.pid"

write_theme_file() {
  local theme_path="$1"
  local tmp_file

  mkdir -p "$ALACRITTY_DIR"
  tmp_file="$(mktemp "${THEME_FILE}.XXXXXX")"
  cat >"$tmp_file" <<EOF
general.import = ["${theme_path}"]
EOF
  mv "$tmp_file" "$THEME_FILE"
}

current_theme_path() {
  case "$(uname -s)" in
    Darwin)
      if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
        printf '%s\n' "$DARK_THEME"
      else
        printf '%s\n' "$LIGHT_THEME"
      fi
      ;;
    *)
      printf '%s\n' "$DARK_THEME"
      ;;
  esac
}

sync_once() {
  write_theme_file "$(current_theme_path)"
}

run_watch() {
  local existing_pid
  local last_theme_path=""
  local theme_path

  mkdir -p "$ALACRITTY_DIR"
  existing_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [ -n "$existing_pid" ] && kill -0 "$existing_pid" >/dev/null 2>&1; then
    exit 0
  fi

  printf '%s\n' "$$" >"$PID_FILE"
  trap 'rm -f "$PID_FILE"' EXIT

  while true; do
    theme_path="$(current_theme_path)"
    if [ "$theme_path" != "$last_theme_path" ] || [ ! -f "$THEME_FILE" ]; then
      write_theme_file "$theme_path"
      last_theme_path="$theme_path"
    fi
    sleep "$WATCH_INTERVAL"
  done
}

case "${1:-}" in
  --watch)
    run_watch
    ;;
  "")
    sync_once
    ;;
  *)
    echo "usage: $(basename "$0") [--watch]" >&2
    exit 1
    ;;
esac
