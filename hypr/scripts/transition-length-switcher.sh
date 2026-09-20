#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call transition-duration toggle 2>/dev/null || true
    exit 0
fi

CHOICE=$(printf \
"0.5  — instant (snappy)\n1.0  — fast\n1.8  — smooth (default)\n2.5  — slow and cinematic\n4.0  — very slow and dreamy" | \
    rofi -dmenu \
         -p "Transition Duration" \
         -theme ~/.config/rofi/applet.rasi \
         -no-custom)

[ -z "$CHOICE" ] && exit 0

DURATION=$(echo "$CHOICE" | awk '{print $1}')
echo "$DURATION" > ~/.config/hypr/themes/wall-transition-duration
notify-send "HyDE" "Transition Duration → ${DURATION}s" -t 2000 2>/dev/null || true

# Preview immediately
WALL=$(grep -oP '(?<=url\(")[^"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1)
[ -n "$WALL" ] && [ -f "$WALL" ] && bash ~/.config/hypr/scripts/swww.sh "$WALL"
