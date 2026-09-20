#!/usr/bin/env bash
CURRENT=$(cat ~/.config/hypr/active-lockscreen 2>/dev/null || echo hyprlock)

CHOICE=$(printf \
"hyprlock    — VMware compatible, themed, analog clock\nquickshell  — Animated intro, orbiting blobs, PAM auth" | \
    rofi -dmenu \
         -p "Lock Screen" \
         -theme ~/.config/rofi/applet.rasi \
         -no-custom \
         -mesg "Current: $CURRENT")

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    hyprlock*)   TARGET="hyprlock" ;;
    quickshell*) TARGET="quickshell" ;;
    *) exit 0 ;;
esac

echo "$TARGET" > ~/.config/hypr/active-lockscreen
notify-send "HyDE" "Lock screen → $TARGET" -t 2000 2>/dev/null || true
