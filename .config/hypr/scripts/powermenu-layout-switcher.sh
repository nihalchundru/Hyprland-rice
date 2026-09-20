#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call powermenu-layout toggle 2>/dev/null || true
    exit 0
fi

# powermenu-layout-switcher.sh — choose between sidebar / fullscreen styles

LABELS=("Sidebar (wallpaper + 3x2 grid)" "Fullscreen (5-col giant circles)")

CHOICE=$(printf '%s\n' "${LABELS[@]}" | \
    rofi -dmenu -p "Powermenu Layout" \
         -theme ~/.config/rofi/applet.rasi -no-custom)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *Sidebar*)    LAYOUT="sidebar" ;;
    *Fullscreen*) LAYOUT="fullscreen" ;;
    *)            exit 0 ;;
esac

echo "$LAYOUT" > ~/.config/rofi/current-powermenu-layout
notify-send "HyDE" "Powermenu Layout → $LAYOUT" -t 2000 2>/dev/null || true
