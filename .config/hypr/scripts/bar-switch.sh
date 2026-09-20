#!/usr/bin/env bash
STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)

if [ "$STYLE" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call bar-switcher toggle 2>/dev/null || true
    exit 0
fi

BAR=$(printf "waybar\nhyprpanel\nquickshell" | \
    rofi -dmenu -p "Active Bar" \
         -theme ~/.config/rofi/applet.rasi -no-custom)

if [ "$BAR" = "quickshell" ]; then
    BAR="pill"
fi

[ -z "$BAR" ] && exit 0

echo "$BAR" > ~/.config/hypr/bar/active-bar
[ "$BAR" = "waybar" ] && echo "hyde-default" > ~/.config/waybar/current-layout
notify-send "HyDE" "Bar → $BAR" -t 2000 2>/dev/null || true
bash ~/.config/hypr/scripts/bar-launch.sh "$BAR"
