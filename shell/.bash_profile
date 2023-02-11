#
# ~/.bash_profile
#

# Load my configs
[ -f "$HOME"/.bashrc ] && . "$HOME"/.bashrc

# Autostart X (see my .xinitrc)
if [ -f "$HOME"/.xinitrc ]; then
    if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
        startx
    fi
fi
