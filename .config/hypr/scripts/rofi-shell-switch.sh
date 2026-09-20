#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/applet.rasi"
DEFAULT_BINDS="$HOME/.config/hypr/keybindings.lua"
NOTHING_CONF="$HOME/.config/quickshell/nothingshell/hypr/nothingshell.lua"
TIDE_BINDS="$HOME/.config/hypr/chill.conf"
CURRENT_BINDS="$HOME/.config/hypr/current_profile_binds.lua"

# Menu options list
OPTION_DEFAULT="  Default Shell (Waybar)"
OPTION_NOTHING="  NothingShell (Quickshell)"
OPTION_TIDE="  ChillPill-Shell (Dynamic Layout)"

OPTIONS="$OPTION_DEFAULT\n$OPTION_NOTHING\n$OPTION_TIDE"
SELECTION=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Select Desktop Layout" -theme "$ROFI_THEME")

# Function to kill any active quickshell windows cleanly before swapping
cleanup_quickshell() {
    killall quickshell 2>/dev/null
    PIDS=$(hyprctl layers -j | jq -r '.[] | .levels[].sublevels[]? | select(.namespace == "qs-notch" or .namespace == "qs-bar") | .pid' 2>/dev/null)
    if [ -n "$PIDS" ] && [ "$PIDS" != "null" ]; then
        echo "$PIDS" | xargs kill -9 2>/dev/null
    fi
}

case "$SELECTION" in
    "$OPTION_DEFAULT")
        echo "Activating Default Shell..."
        cleanup_quickshell
        pkill -f chillpill
        cp "$DEFAULT_BINDS" "$CURRENT_BINDS"
        hyprctl reload
        if ! pgrep -x "waybar" > /dev/null; then
            waybar &
        fi
        ;;

    "$OPTION_NOTHING")
        echo "Activating NothingShell..."
        killall waybar 2>/dev/null
        pkill -f chillpill
        cleanup_quickshell
        bash ~/.config/hypr/scripts/theme-switch.sh matugen
        killall waybar 2>/dev/null
        cp "$NOTHING_CONF" "$CURRENT_BINDS"
        hyprctl reload
        quickshell --path "$HOME/.config/quickshell/nothingshell" &
        ;;

    "$OPTION_TIDE")
        echo "Activating Tide-Island..."
        killall waybar 2>/dev/null
        cleanup_quickshell
        
        # 1. Swap file over to use your adapted Alt-based island commands
        cp "$TIDE_BINDS" "$CURRENT_BINDS"
        
        # 2. Flush window manager configuration memory
        hyprctl reload
        
        # 3. Launch tide-island component path via Quickshell cleanly
        chillpill-shell &
        ;;
        
    *)
        exit 0
        ;;
esac
