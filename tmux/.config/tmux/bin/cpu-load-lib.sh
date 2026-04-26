#!/bin/bash

CPU_CACHE_FILE="${TMPDIR:-/tmp}/tmux_cpu_load_${USER:-user}_${OSTYPE%%[0-9]*}.cache"

tmux_cpu_load_get_cpus() {
    local cpus

    if [ -r "$CPU_CACHE_FILE" ]; then
        read -r cpus < "$CPU_CACHE_FILE" || true
    fi

    if [ -z "${cpus:-}" ]; then
        if [[ "$OSTYPE" == darwin* ]]; then
            cpus=$(sysctl -n hw.ncpu)
        else
            cpus=$(nproc)
        fi
        printf '%s\n' "$cpus" > "$CPU_CACHE_FILE"
    fi

    printf '%s\n' "${cpus:-1}"
}

tmux_cpu_load_get_load() {
    local loads load

    if [[ "$OSTYPE" == darwin* ]]; then
        loads=$(sysctl -n vm.loadavg)
        loads="${loads#\{}"
        loads="${loads%\}}"
        set -- $loads
        load="$1"
    else
        read -r load _ < /proc/loadavg
    fi

    printf '%s\n' "$load"
}

tmux_cpu_load_format() {
    local load="$1"
    local cpus="$2"
    local normal="$3"
    local warn="$4"
    local crit="$5"
    local load_whole load_fraction load_tenths pct_tenths pct_int pct_dec color

    load_whole="${load%%.*}"
    load_fraction="${load#*.}"
    if [ "$load_fraction" = "$load" ]; then
        load_fraction=0
    fi

    load_tenths=$((load_whole * 10 + ${load_fraction%%${load_fraction#?}}))
    pct_tenths=$(((load_tenths * 100 + cpus / 2) / cpus))
    pct_int=$((pct_tenths / 10))
    pct_dec=$((pct_tenths % 10))

    if [ "$pct_tenths" -gt 800 ]; then
        color="$crit"
    elif [ "$pct_tenths" -gt 500 ]; then
        color="$warn"
    else
        color="$normal"
    fi

    case "$color" in
        \#*) printf '#[fg=%s]%s.%s%%#[default]\n' "$color" "$pct_int" "$pct_dec" ;;
        *) printf '#[fg=colour%s]%s.%s%%#[default]\n' "$color" "$pct_int" "$pct_dec" ;;
    esac
}

tmux_cpu_load_render() {
    local cpus="$1"
    local normal="$2"
    local warn="$3"
    local crit="$4"

    tmux_cpu_load_format "$(tmux_cpu_load_get_load)" "$cpus" "$normal" "$warn" "$crit"
}
