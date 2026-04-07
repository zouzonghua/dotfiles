#!/bin/bash
# Parameters: $1=normal, $2=warning, $3=critical (256 color codes)
normalize_color() {
    local c="$1"
    c="${c#colour}"
    echo "$c"
}

# Define the color codes.
C_NORMAL=$(normalize_color "${1:-76}")
C_WARN=$(normalize_color "${2:-142}")
C_CRIT=$(normalize_color "${3:-160}")

# Get the number of cores and load.
if [[ "$OSTYPE" == "darwin"* ]]; then
    CPUS=$(sysctl -n hw.ncpu)
    LOADS=$(uptime | awk -F'load averages: ' '{print $2}' | sed 's/,//g')
else
    CPUS=$(nproc)
    LOADS=$(uptime | awk -F'load average: ' '{print $2}' | sed 's/,//g')
fi

# Calculate the 1 minute load percentage.
CPUS=${CPUS:-1}
L1=$(echo $LOADS | awk '{print $1}')
PCT_VAL=$(awk -v l="$L1" -v c="$CPUS" 'BEGIN {printf "%.0f", (l/c)*100}')

# Determine the color.
if [ "$PCT_VAL" -gt 80 ]; then
    COLOR=$C_CRIT
elif [ "$PCT_VAL" -gt 50 ]; then
    COLOR=$C_WARN
else
    COLOR=$C_NORMAL
fi

# Format the 1 minute load average as a percentage.
CPU_STR=$(echo "$LOADS" | awk -v cpus="$CPUS" '{printf "%.1f%%", $1/cpus*100}')

# Format the output string with the color.
echo "#[fg=colour${COLOR}]${CPU_STR}#[default]"
