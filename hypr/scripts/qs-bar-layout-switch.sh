#!/bin/bash

# Force proper graphical environment variables so Quickshell can find Hyprland
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

BAR="$1"

# 1. Save the active selection
#mkdir -p "$HOME/.config/hypr/bar"
echo "$BAR" > "$HOME/.config/hypr/bar/active-bar"

# 2. Extract and force-kill any running Quickshell processes
NOTCH_PID=$(hyprctl layers | grep -B 2 "namespace: qs-notch" | grep "pid:" | awk '{print $NF}')
BAR_PID=$(hyprctl layers | grep -B 2 "namespace: qs-bar" | grep "pid:" | awk '{print $NF}')
ISLAND_PID=$(hyprctl layers | grep -B 2 "namespace: qs-island" | grep "pid:" | awk '{print $NF}')

[ -n "$NOTCH_PID" ] && kill -9 "$NOTCH_PID" 2>/dev/null
[ -n "$BAR_PID" ] && kill -9 "$BAR_PID" 2>/dev/null
[ -n "$ISLAND_PID" ] && kill -9 "$ISLAND_PID" 2>/dev/null

# Clean up any remaining zombie qs processes
#pkill -9 -x qs 2>/dev/null

# 3. Rest a moment for the display server to clean the layers
sleep 0.2


# 4. Target the correct configuration directory
# 4. Target the correct configuration directory
if [ "$BAR" = "notch" ]; then
    export QUICKSHELL_DIR="$HOME/.config/quickshell/notch"
elif [ "$BAR" = "island" ]; then
    export QUICKSHELL_DIR="$HOME/.config/quickshell/island"
else
    export QUICKSHELL_DIR="$HOME/.config/quickshell/topbar"
fi


# 5. Launch Quickshell without any trailing path arguments
if [ -d "$QUICKSHELL_DIR" ]; then
    # Launching qs by passing the directory via the dedicated -p parameter 
    qs -p "$QUICKSHELL_DIR" > /tmp/qs-script.log 2>&1 & disown
else
    echo "Directory $QUICKSHELL_DIR not found!" > /tmp/qs-script.log
fi
