#!/usr/bin/env bash
# clipboard-picker.sh
# Shows clipboard history via rofi, pastes selected entry

STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)

case "$STYLE" in
    hyde)
        SELECTED=$(cliphist list | rofi \
            -dmenu \
            -p "󰅍 Clipboard" \
            -font "JetBrainsMono Nerd Font 10" \
            -theme /tmp/hyde-clipboard.rasi \
            -no-custom)
        ;;
    *)
        SELECTED=$(cliphist list | rofi \
            -dmenu \
            -p "󰅍 Clipboard" \
            -theme ~/.config/rofi/applet.rasi \
            -no-custom)
        ;;
esac

[ -z "$SELECTED" ] && exit 0

# Decode and copy to clipboard
echo "$SELECTED" | cliphist decode | wl-copy

notify-send "HyDE" "Clipboard entry copied!" -t 1500 2>/dev/null || true
