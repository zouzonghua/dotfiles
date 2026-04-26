#!/bin/bash

set -euo pipefail

INTERVAL="${TMUX_CPU_LOAD_INTERVAL:-1}"
TMUX_SOCKET="${TMUX%%,*}"
SERVER_KEY="${TMUX_SOCKET//\//_}"
PID_FILE="${TMPDIR:-/tmp}/tmux_cpu_load_daemon_${USER:-user}_${SERVER_KEY}.pid"
C_NORMAL="${1:-76}"
C_WARN="${2:-142}"
C_CRIT="${3:-160}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

. "$SCRIPT_DIR/cpu-load-lib.sh"

if [ -z "${TMUX_SOCKET}" ]; then
    exit 1
fi

if [ -r "$PID_FILE" ]; then
    read -r EXISTING_PID < "$PID_FILE" || true
    if [ -n "${EXISTING_PID:-}" ] && kill -0 "$EXISTING_PID" 2>/dev/null; then
        exit 0
    fi
fi

printf '%s\n' "$$" > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

CPUS=$(tmux_cpu_load_get_cpus)

while tmux has-session 2>/dev/null; do
    tmux set-option -gq @cpu_load "$(tmux_cpu_load_render "$CPUS" "$C_NORMAL" "$C_WARN" "$C_CRIT")"
    sleep "$INTERVAL"
done
