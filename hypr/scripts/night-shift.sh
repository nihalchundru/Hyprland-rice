#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call night-shift toggle 2>/dev/null || true
    exit 0
fi

# night-shift.sh — cycles through night shift modes

STATE_FILE="$HOME/.config/hypr/themes/night-shift-state"
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "off")

# Cycle order
case "$CURRENT" in
    off)    NEXT="warm";   TEMP=4500; LABEL="Warm (4500K)"   ;;
    warm)   NEXT="warmer"; TEMP=3500; LABEL="Warmer (3500K)" ;;
    warmer) NEXT="night";  TEMP=2700; LABEL="Night (2700K)"  ;;
    night)  NEXT="off";    TEMP=0;    LABEL="Off"            ;;
    *)      NEXT="off";    TEMP=0;    LABEL="Off"            ;;
esac

echo "$NEXT" > "$STATE_FILE"

# Kill any running hyprsunset
pkill hyprsunset 2>/dev/null || true
sleep 0.2

if [ "$NEXT" = "off" ]; then
    notify-send "HyDE" "Night Shift → Off" \
        -i display-brightness -t 2000 2>/dev/null || true
else
    hyprsunset -t "$TEMP" &
    notify-send "HyDE" "Night Shift → $LABEL" \
        -i display-brightness -t 2000 2>/dev/null || true
fi
