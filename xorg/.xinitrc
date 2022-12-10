pgrep -x fcitx5 > /dev/null || fcitx5 &

export INPUT_METHOD=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export SDL_IM_MODULE=fcitx

[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

exec bspwm
