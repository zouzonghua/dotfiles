#!/bin/sh

# Emit an explicit OSC 52 clipboard update through the current tmux layer.
payload=$(base64 | tr -d '\r\n')
printf '\033Ptmux;\033\033]52;c;%s\007\033\\' "$payload"
