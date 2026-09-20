#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call rofi-layout toggle 2>/dev/null || true
    exit 0
fi

STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)

if [ "$STYLE" = "hyde" ]; then
    notify-send "HyDE" "Layout switcher not used in HyDE picker style\nSwitch to compact style (ALT+SHIFT+S) to change layouts" -t 3000 2>/dev/null || true
    exit 0
fi

LABELS=(
    "ML4W (two-panel)"
    "Compact (top pill)"
    "Adi1090x (image header)"
    "Grid (6-col icons)"
    "Simple Grid (3x3 minimal)"
)

CHOICE=$(printf '%s\n' "${LABELS[@]}" | \
    rofi -dmenu -p "Rofi Layout" \
         -theme ~/.config/rofi/applet.rasi -no-custom)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    *ML4W*)        LAYOUT="ml4w" ;;
    *Compact*)     LAYOUT="compact" ;;
    *Adi1090x*)    LAYOUT="adi1090x" ;;
    *Simple\ Grid*)LAYOUT="simple-grid" ;;
    *Grid*)        LAYOUT="grid" ;;
    *)             exit 0 ;;
esac

echo "$LAYOUT" > ~/.config/rofi/current-layout
notify-send "HyDE" "Rofi Layout → $LAYOUT" -t 2000 2>/dev/null || true
