#!/usr/bin/env bash
SELECTED=$(cliphist list | rofi \
    -dmenu \
    -p "󰅍 Delete Entry" \
    -theme ~/.config/rofi/applet.rasi \
    -no-custom \
    -mesg "Select entry to remove from history")

[ -z "$SELECTED" ] && exit 0
echo "$SELECTED" | cliphist delete
notify-send "HyDE" "Entry deleted from clipboard history" -t 1500 2>/dev/null || true
