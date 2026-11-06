#!/usr/bin/env bash
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)

if [ "$BAR" = "notch" ]; then
    qs ipc -c ~/.config/quickshell/notch call notch toggleControl
else 
    qs -c ~/.config/quickshell/pill ipc call pill toggle control
fi


 #   qs ipc -c ~/.config/quickshell/topbar call topbar toggleControl
#else
    # Fallback for waybar/hyprpanel
#    pavucontrol &
#fi
