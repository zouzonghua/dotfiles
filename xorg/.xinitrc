pgrep -x fcitx5 > /dev/null || fcitx5 &

export INPUT_METHOD=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export SDL_IM_MODULE=fcitx

#### Session selection

# xfce is the default.
session=${1:-xfce}

#### Sessions

# Map arguments to commands.
case $session in
    bspwm ) exec bspwm        ;;
    xfce  ) exec startxfce4   ;;
    *) echo "Unknown session" ;;
esac
