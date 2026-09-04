#!/bin/sh

# Emit an explicit OSC 52 clipboard update.
tmp=$(mktemp "${TMPDIR:-/tmp}/osc52-copy.XXXXXX") || exit 1
trap 'rm -f "$tmp"' EXIT HUP INT TERM
cat > "$tmp"
payload=$(base64 < "$tmp" | tr -d '\r\n')

emit_plain() {
  printf '\033]52;c;%s\007' "$payload"
}

emit_tmux_passthrough() {
  printf '\033Ptmux;\033\033]52;c;%s\007\033\\' "$payload"
}

if [ "$1" = "--to-ttys" ]; then
  # 1) Through pane tty: lets the current tmux layer unwrap DCS passthrough.
  [ -n "$2" ] && emit_tmux_passthrough > "$2"
  # 2) Direct to client tty: works when passthrough is blocked or unnecessary.
  [ -n "$3" ] && emit_plain > "$3"
else
  emit_tmux_passthrough
fi
