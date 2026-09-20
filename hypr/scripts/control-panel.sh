#!/usr/bin/env bash
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)

if [ "$BAR" = "notch" ]; then
    qs ipc -c ~/.config/quickshell/notch call notch toggleControl
fi

if [ "$BAR" = "quickshell" ] || [ "$BAR" = "pill" ] ; then
    qs ipc -c ~/.config/quickshell/topbar call topbar toggleControl
else
    # Fallback for waybar/hyprpanel
    pavucontrol &
fi
