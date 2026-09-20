#!/usr/bin/env bash
# Quick applet — 4 large icon tiles

CHOICE=$(printf "󰐥\n\n\n󰕾" | rofi \
    -dmenu \
    -p "" \
    -theme ~/.config/rofi/applets/applet.rasi \
    -no-custom)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "󰐥") bash ~/.config/hypr/scripts/powermenu.sh ;;
    "")  thunar & ;;
    "")  kitty & ;;
    "󰕾") pavucontrol & ;;
esac
