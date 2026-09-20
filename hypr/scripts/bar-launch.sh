#!/usr/bin/env bash
BAR="${1:-$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)}"
LAYOUT="${2:-$(cat ~/.config/waybar/current-layout 2>/dev/null || echo hyde-default)}"

pkill waybar    2>/dev/null || true
pkill hyprpanel 2>/dev/null || true
hyprpanel q
NOTCH_PID=$(hyprctl layers | grep -B 2 "namespace: qs-notch" | grep "pid:" | awk '{print $NF}')
BAR_PID=$(hyprctl layers | grep -B 2 "namespace: qs-bar" | grep "pid:" | awk '{print $NF}')
ISLAND_PID=$(hyprctl layers | grep -B 2 "namespace: qs-island" | grep "pid:" | awk '{print $NF}')

[ -n "$ISLAND_PID" ] && kill -9 "$ISLAND_PID" 2>/dev/null

[ -n "$NOTCH_PID" ] && kill -9 "$NOTCH_PID" 2>/dev/null
sleep 2
[ -n "$BAR_PID" ] && kill -9 "$BAR_PID" 2>/dev/null

# Small pause for the display server layers to clear out
sleep 0.2


case "$BAR" in
    waybar)
        L="$HOME/.config/waybar/layouts"
        case "$LAYOUT" in
            hyde-default)
                THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
                if [ "$THEME" = "aozora" ]; then
                    waybar -c $L/hyde-default.jsonc -s ~/.config/waybar/layouts/aozora-style.css &
                else
                    waybar -c $L/hyde-default.jsonc -s ~/.config/waybar/style.css &
                fi
                ;;
            minimal)      waybar -c $L/minimal.jsonc       -s ~/.config/waybar/style.css & ;;
            topbar)       waybar -c $L/topbar.jsonc         -s ~/.config/waybar/style.css & ;;
            custom)       waybar -c $L/custom.jsonc         -s $L/custom.css & ;;
            custom2)      waybar -c $L/custom2.jsonc        -s $L/custom2.css & ;;
            dock)
                waybar -c $L/topbar.jsonc -s ~/.config/waybar/style.css &
                waybar -c $L/dock.jsonc   -s $L/dock.css &
                ;;
            glass-center)
                waybar -c $L/glass-center.jsonc -s $L/glass-center.css &
                ;;
            islands)
                waybar -c $L/islands-left.jsonc   -s $L/islands.css &
                waybar -c $L/islands-center.jsonc -s $L/islands.css &
                waybar -c $L/islands-right.jsonc  -s $L/islands.css &
                ;;
            dots)
                waybar -c $L/dots.jsonc -s $L/dots.css &
                ;;
            omarchy)
                waybar -c $L/omarchy.jsonc -s $L/omarchy.css &
                ;;
            omarchy2)
                waybar -c $L/omarchy2.jsonc -s $L/omarchy2.css &
                ;;
            gradient-pill)
                waybar -c $L/gradient-pill.jsonc -s $L/gradient-pill.css &
                ;;
            wal)
                waybar -c $L/wal.jsonc -s $L/wal.css &
                ;;
            polybar-classic)
                waybar -c ~/.config/waybar/layouts/polybar-classic.jsonc -s ~/.config/waybar/layouts/polybar-classic.css &
                ;;
            *) waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css & ;;
        esac
        ;;
    hyprpanel)
        hyprpanel &
        ;;
    pill)
        qs -c ~/.config/quickshell/topbar >/tmp/qs.log 2>&1 &
        sleep 2
        ;;
#    notch)
 #       qs -c ~/.config/quickshell/notch
  #      sleep 2
   #     ;;
esac
