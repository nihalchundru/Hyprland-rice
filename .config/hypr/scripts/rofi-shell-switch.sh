#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/applet.rasi"
DEFAULT_BINDS="$HOME/.config/hypr/keybindings.lua"
CURRENT_BINDS="$HOME/.config/hypr/current_profile_binds.lua"
M3_BINDS="$HOME/.config/hypr/m3.lua"

# Menu options list
OPTION_DEFAULT="  Default Shell (Dynamic Island)"
OPTION_M3="Material 3 Shell"


OPTIONS="$OPTION_DEFAULT\n$OPTION_M3"

# accept a 1-2 argument from the Quickshell switcher,
# otherwise fall back to the original rofi menu
if [ -n "$1" ]; then
    SELECTION=$(echo -e "$OPTIONS" | sed -n "${1}p")
else
    SELECTION=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Select Desktop Layout" -theme "$ROFI_THEME")
fi

pkill -f '/home/nihal/.config/quickshell/pill'
pkill -f '/home/nihal/.config/quickshell/notch'
pkill -f '/home/nihal/.config/quickshell/material'
pkill -f '/home/nihal/.config/quickshell/island'
killall quickshell
killall qs
pkill -f '/home/nihal/.config/quickshell/pill'
pkill -f '/home/nihal/.config/quickshell/notch'
pkill -f '/home/nihal/.config/quickshell/material'
pkill -f '/home/nihal/.config/quickshell/island'
pkill -f '/home/nihal/.config/quickshell/m3'

qs -c ~/.config/quickshell/applets &
qs -c ~/.config/quickshell/theme-switcher &
qs -c ~/.config/quickshell/wallpaper-picker &
qs -c ~/.config/quickshell/osd &

case "$SELECTION" in
    "$OPTION_DEFAULT")
        echo "Activating Default Shell..."
        cleanup_quickshell
        pkill -f chillpill
        cp "$DEFAULT_BINDS" "$CURRENT_BINDS"
        hyprctl reload
	qs -p ~/.config/quickshell/pill &
	qs -p ~/.config/quickshell/widgets &
	qs -p ~/.config/quickshell/cava-visualizer &
        if ! pgrep -x "waybar" > /dev/null; then
            waybar &
        fi
        ;;

   "$OPTION_M3")
    echo "Activating Material 3 Shell"
    cp "$M3_BINDS" "$CURRENT_BINDS"
    hyprctl reload
    quickshell --path "$HOME/.config/quickshell/m3" &
    ;;

   *)
        exit 0
        ;;
esac