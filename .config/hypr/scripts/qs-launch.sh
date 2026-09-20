#!/usr/bin/env bash

BAR="$1"

echo "$BAR" > ~/.config/hypr/bar/active-bar

# Get running Quickshell PIDs
NOTCH_PID=$(hyprctl layers | grep -B 2 "namespace: qs-notch" | grep "pid:" | awk '{print $NF}')
BAR_PID=$(hyprctl layers | grep -B 2 "namespace: qs-bar" | grep "pid:" | awk '{print $NF}')
ISLAND_PID=$(hyprctl layers | grep -B 2 "namespace: qs-island" | grep "pid:" | awk '{print $NF}')

# Kill existing instances
[ -n "$NOTCH_PID" ] && kill -9 "$NOTCH_PID" 2>/dev/null
[ -n "$BAR_PID" ] && kill -9 "$BAR_PID" 2>/dev/null
[ -n "$ISLAND_PID" ] && kill -9 "$ISLAND_PID" 2>/dev/null
sleep 2

# Launch selected bar
case "$BAR" in
    pill)
        quickshell -c "$HOME/.config/quickshell/topbar"
        ;;
    notch)
        quickshell -c "$HOME/.config/quickshell/notch"
        ;;
    island)
	quickshell -c "$HOME/.config/quickshell/island"
        ;;
    *)
        echo "Unknown BAR: $BAR"
        exit 1
        ;;
esac
