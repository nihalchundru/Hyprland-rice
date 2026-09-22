#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/applet.rasi"
DEFAULT_BINDS="$HOME/.config/hypr/keybindings.lua"
NOTHING_CONF="$HOME/.config/quickshell/nothingshell/hypr/nothingshell.lua"
TIDE_BINDS="$HOME/.config/hypr/chill.conf"
SERPANTINUM_BINDS="$HOME/serpantinum/compositors/hyprland/config/keybinds.lua"
CURRENT_BINDS="$HOME/.config/hypr/current_profile_binds.lua"

# Menu options list
OPTION_DEFAULT="  Default Shell (Waybar)"
OPTION_NOTHING="  NothingShell (Quickshell)"
OPTION_TIDE="  ChillPill-Shell (Dynamic Layout)"
OPTION_SERPANTINUM="Serpantinum shell"

OPTIONS="$OPTION_DEFAULT\n$OPTION_NOTHING\n$OPTION_TIDE\n$OPTION_SERPANTINUM"
SELECTION=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Select Desktop Layout" -theme "$ROFI_THEME")

# Function to kill any active quickshell windows cleanly before swapping

# 2. Extract and force-kill any running Quickshell processes
NOTCH_PID=$(hyprctl layers | grep -B 2 "namespace: qs-notch" | grep "pid:" | awk '{print $NF}')
BAR_PID=$(hyprctl layers | grep -B 2 "namespace: qs-pill-bar" | grep "pid:" | awk '{print $NF}')
ISLAND_PID=$(hyprctl layers | grep -B 2 "namespace: qs-island" | grep "pid:" | awk '{print $NF}')

[ -n "$NOTCH_PID" ] && kill -9 "$NOTCH_PID" 2>/dev/null
[ -n "$BAR_PID" ] && kill -9 "$BAR_PID" 2>/dev/null
[ -n "$ISLAND_PID" ] && kill -9 "$ISLAND_PID" 2>/dev/null

killall quickshell
killall qs
qs -c ~/.config/quickshell/applets &
qs -c ~/.config/quickshell/theme-switcher &
qs -c ~/.config/quickshell/wallpaper-picker &
qs -c ~/.config/quickshell/osd &
#notify-send "Debug Selection" "[$SELECTION]"

case "$SELECTION" in
    "$OPTION_DEFAULT")
        echo "Activating Default Shell..."
        cleanup_quickshell
        pkill -f chillpill
        cp "$DEFAULT_BINDS" "$CURRENT_BINDS"
        hyprctl reload
	qs -p ~/.config/quickshell/topbar
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
        
   "$OPTION_SERPANTINUM")
	echo "Activating Serpantinum"
	#notify-send "hello"
	cp "$SERPANTINUM_BINDS" "$CURRENT_BINDS"
	hyprctl reload

	/home/nihal/.local/bin/serpantinumd & 
	disown


	;;
   *)
        exit 0
        ;;
esac
