#!/usr/bin/env bash
# QS applet routing

# 1. Read what bar is active right now
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo "waybar")
STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo "compact")


# 2. If picker-style is quickshell, manage symlinks and flip the IPC trigger
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
   
    # Establish the absolute layouts folder target
    if [ "$BAR" = "notch" ] || [ "$BAR" = "quickshell" ]; then
        TARGET_DIR="$HOME/.config/quickshell/notch"
    else
        TARGET_DIR="$HOME/.config/quickshell/topbar"
    fi

    # Update the layout pointer safely
    rm -f "$HOME/.config/quickshell/active-layout-dir"
    ln -s "$TARGET_DIR" "$HOME/.config/quickshell/active-layout-dir"

    # Fire the exact clean toggle sequence
    qs ipc -c ~/.config/quickshell/applets call layout-switcher toggle 2>/dev/null || true
    exit 0
fi

if [ -n "$1" ]; then
    LAYOUT="$1"
else
    case "$BAR" in
        waybar)
            LAYOUT=$(printf "hyde-default\nminimal\ntopbar\ncustom\ncustom2\ndock\nglass-center\nislands\ndots\nomarchy\nomarchy2\ngradient-pill\nwal\npolybar-classic" | \
                rofi -dmenu -p "Waybar Layout" \
                     -theme ~/.config/rofi/applet.rasi -no-custom)
            ;;
        hyprpanel)
            notify-send "HyDE" "HyprPanel manages its own layout" -t 2000 2>/dev/null || true
            exit 0
            ;;
        quickshell|notch|pill|island)
            BAR=$(printf "notch\npill\nisland" | \
                rofi -dmenu -p "Quickshell Layout" \
                     -theme ~/.config/rofi/applet.rasi -no-custom)
            LAYOUT="$BAR"
            ;;
    esac
fi

[ -z "$LAYOUT" ] && exit 0
echo "$LAYOUT" > ~/.config/waybar/current-layout
notify-send "HyDE" "Layout → $LAYOUT" -t 2000 2>/dev/null || true
#notify-send "HyDE DEBUG" "BAR=[$BAR]" -t 3000

case "$BAR" in
    pill|notch|island)
        bash "$HOME/.config/hypr/scripts/qs-launch.sh" "$BAR"
#        echo> ~/.config/hypr/bar/active-bar 
        ;;
    *)
        bash "$HOME/.config/hypr/scripts/bar-launch.sh" "$BAR" "$LAYOUT"
        ;;
esac
