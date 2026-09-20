#!/usr/bin/env bash
WALL="$1"
[ -z "$WALL" ] || [ ! -f "$WALL" ] && exit 1

TRANSITION=$(cat ~/.config/hypr/themes/wall-transition 2>/dev/null || echo "grow")
DURATION=$(cat ~/.config/hypr/themes/wall-transition-duration 2>/dev/null || echo "1.8")

case "$TRANSITION" in
    grow)  EXTRA="--transition-pos 0.5,0.5 --transition-bezier 0.25,1,0.25,1" ;;
    wave)  EXTRA="--transition-wave-dir right --transition-wave-width 400 --transition-wave-height 200" ;;
    wipe)  EXTRA="--transition-angle 45" ;;
    fade)  EXTRA="--transition-step 90" ;;
    outer) EXTRA="--transition-pos 0.5,0.5 --transition-bezier 0.5,0,0.75,0" ;;
    *)     EXTRA="--transition-pos 0.5,0.5" ;;
esac

if ! pgrep awww-daemon > /dev/null 2>&1; then
    mkdir -p ~/.cache/awww
    awww-daemon &
    sleep 0.8
fi

awww img "$WALL" \
    --transition-type "$TRANSITION" \
    --transition-duration "$DURATION" \
    --transition-fps 60 \
    $EXTRA 2>/dev/null || \
    (pkill swaybg 2>/dev/null; swaybg -i "$WALL" -m fill &)
