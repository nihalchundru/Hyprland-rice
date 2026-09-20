#!/usr/bin/env bash
# powermenu.sh — routes to sidebar or fullscreen layout

LAYOUT=$(cat ~/.config/rofi/current-powermenu-layout 2>/dev/null || echo "sidebar")

case "$LAYOUT" in
    fullscreen)
        CHOICE=$(printf "󰍃\n󰒲\n󰍁\n󰐥\n󰜉" | \
            rofi -dmenu -p "" \
                 -theme ~/.config/rofi/powermenu-fullscreen.rasi \
                 -no-custom \
                 -mesg "Lock 󰍃   Suspend 󰒲   Logout 󰍁   Shutdown 󰐥   Reboot 󰜉")
        ;;
    *)
        CHOICE=$(printf "󰍃\n󰒲\n󰍁\n󰐥\n󰜉\n󰗽" | \
            rofi -dmenu -p "" \
                 -theme ~/.config/rofi/powermenu-sidebar.rasi \
                 -no-custom \
                 -mesg "Lock 󰍃   Suspend 󰒲   Logout 󰍁   Shutdown 󰐥   Reboot 󰜉   Cancel 󰗽")
        ;;
esac

case "$CHOICE" in
    "󰍃") hyprctl dispatch exit ;;
    "󰒲") systemctl suspend ;;
    "󰍁") fish -c "hyprlock" || loginctl lock-session ;;
    "󰐥") systemctl poweroff ;;
    "󰜉") systemctl reboot ;;
    "󰗽") exit 0 ;;
esac
