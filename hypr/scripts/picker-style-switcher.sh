#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call picker-style toggle 2>/dev/null || true
    exit 0
fi

CHOICE=$(printf "compact     — rofi list/grid style\nhyde        — HyDE fullscreen horizontal\nwalker      — Walker launcher\nquickshell  — Quickshell native pickers" | \
    rofi -dmenu \
         -p "Picker Style" \
         -theme ~/.config/rofi/applet.rasi \
         -no-custom)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    compact*)    STYLE="compact" ;;
    hyde*)       STYLE="hyde" ;;
    walker*)     STYLE="walker" ;;
    quickshell*) STYLE="quickshell" ;;
    *)           exit 0 ;;
esac

echo "$STYLE" > ~/.config/rofi/picker-style
notify-send "HyDE" "Picker Style → $STYLE" -t 2000 2>/dev/null || true

# Start/stop walker service as needed
if [ "$STYLE" = "walker" ]; then
    walker --gapplication-service & disown
elif [ "$STYLE" = "quickshell" ]; then
    pkill -f "qs -c.*theme-switcher"   2>/dev/null || true
    pkill -f "qs -c.*wallpaper-picker" 2>/dev/null || true
    sleep 0.3
    qs -c ~/.config/quickshell/theme-switcher &
    qs -c ~/.config/quickshell/wallpaper-picker &
else
    pkill -f "walker --gapplication-service" 2>/dev/null || true
fi
