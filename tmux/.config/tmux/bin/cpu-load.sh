#!/usr/bin/env bash

set -euo pipefail

normal="${1:-#23d18b}"
warn="${2:-#f5f543}"
crit="${3:-#f14c4c}"

case "$(uname -s)" in
  Darwin)
    cpus=$(sysctl -n hw.ncpu)
    loads=$(sysctl -n vm.loadavg)
    loads="${loads#\{}"
    loads="${loads%\}}"
    read -r load _ <<< "$loads"
    ;;
  Linux)
    cpus=$(nproc)
    read -r load _ < /proc/loadavg
    ;;
  *)
    exit 1
    ;;
esac

LC_ALL=C awk \
  -v load="$load" \
  -v cpus="$cpus" \
  -v normal="$normal" \
  -v warn="$warn" \
  -v crit="$crit" '
    BEGIN {
      percent = load * 100 / cpus
      color = percent > 80 ? crit : (percent > 50 ? warn : normal)
      printf "#[fg=%s]%.1f%%#[default]\n", color, percent
    }
  '
