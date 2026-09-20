#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call transition-style toggle 2>/dev/null || true
    exit 0
fi

CHOICE=$(printf \
"grow      — expands from center outward (default)\nwave      — liquid wave ripples across screen\nwipe      — sleek diagonal wipe\nfade      — smooth crossfade\nouter     — implodes from edges inward" | \
    rofi -dmenu \
         -p "Transition" \
         -theme ~/.config/rofi/applet.rasi \
         -no-custom)

[ -z "$CHOICE" ] && exit 0

TRANSITION=$(echo "$CHOICE" | awk '{print $1}')
echo "$TRANSITION" > ~/.config/hypr/themes/wall-transition
notify-send "HyDE" "Transition → $TRANSITION" -t 2000 2>/dev/null || true

# Preview the new transition immediately with current wallpaper
WALL=$(grep -oP '(?<=url\(")[^"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1)
[ -n "$WALL" ] && [ -f "$WALL" ] && bash ~/.config/hypr/scripts/swww.sh "$WALL"
