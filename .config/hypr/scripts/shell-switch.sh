#!/usr/bin/env bash

echo "INSTANCE=$HYPRLAND_INSTANCE_SIGNATURE" >> /tmp/hyprtest.log
which hyprctl >> /tmp/hyprtest.log
hyprctl instances >> /tmp/hyprtest.log

CURRENT=$(cat ~/.config/hypr/active-shell 2>/dev/null || echo "hyde")

CHOICE=$(printf "hyde    — HyDE ARM (waybar + quickshell + all menus)\nambxst  — Ambxst shell (full Ambxst experience)" | \
    rofi -dmenu \
         -p "Shell" \
         -theme ~/.config/rofi/applet.rasi \
         -no-custom)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    hyde*)   TARGET="hyde" ;;
    ambxst*) TARGET="ambxst" ;;
    *)       exit 0 ;;
esac

[ "$TARGET" = "$CURRENT" ] && \
    notify-send "HyDE" "$TARGET is already active" -t 1500 2>/dev/null && exit 0

echo "$TARGET" > ~/.config/hypr/active-shell

case "$TARGET" in
    ambxst)
        notify-send "HyDE" "Switching to Ambxst..." -t 1500 2>/dev/null || true

        # Kill all HyDE ARM shell components
        pkill waybar        2>/dev/null || true
        pkill hyprpanel     2>/dev/null || true
        pkill -f "qs -c"    2>/dev/null || true
        pkill swaync        2>/dev/null || true

        sleep 0.3

        # Suspend ALL HyDE ARM keybinds via unbind
        # Single key binds
        #for key in A D T W X M V N L P; do
            #hyprctl keyword unbind ALT, $key"        2>/dev/null || true
            #echo AFTER UNBIND:"
	    #hyprctl binds | grep -i W" >> /tmp/hyprtest.log
        #done

        # ALT+SHIFT binds
        #for key in A B C D L N P S T V W; do
            #hyprctl keyword unbind ALT SHIFT, $key"  2>/dev/null || true
        #done

        # ALT+CTRL binds

        # Start Ambxst
        ambxst & disown
 

        sleep 3

        # Suspend ALL HyDE ARM keybinds via unbind
        # Single key binds
        for key in A D T W X M V N L P; do
            hyprctl keyword unbind "ALT, $key"        2>/dev/null || true
            hyprctl keyword unbind "ALT, P"
            hyprctl keyword unbind "ALT, D"
            echo "AFTER UNBIND:"
            hyprctl binds | grep -i "W" >> /tmp/hyprtest.log
        done

        # ALT+SHIFT binds
        for key in A B C D L N P S T V W; do
            hyprctl keyword unbind "ALT SHIFT, $key"  2>/dev/null || true
        done

        # ALT+CTRL binds (except S — shell switcher stays active)
        for key in Delete; do
            hyprctl keyword unbind "CTRL ALT, $key"   2>/dev/null || true
        done

        # Window management binds that conflict with Ambxst
        for key in Q F G Return E B; do
            hyprctl keyword unbind "ALT, $key"        2>/dev/null || true
        done

	hyprctl keyword bind "ALT, Return, exec, kitty"
	hyprctl keyword bind "ALT, Q, killactive"

        notify-send "Ambxst" "Shell → Ambxst\nALT+CTRL+S to switch back" \
            -t 3000 2>/dev/null || true
        ;;

    hyde)
        notify-send "HyDE" "Switching back to HyDE ARM..." -t 1500 2>/dev/null || true

        # Kill Ambxst
        pkill -f "ambxst"   2>/dev/null || true
        sleep 0.5

        # Restore ALL keybinds via hyprctl reload
        hyprctl reload 2>/dev/null || true
        sleep 0.5

        # Restart HyDE ARM components
        BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)
        LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo hyde-default)
        bash ~/.config/hypr/scripts/bar-launch.sh "$BAR" "$LAYOUT"

        swaync &

        qs -c ~/.config/quickshell/sidebar  & 2>/dev/null || true
        qs -c ~/.config/quickshell/keybinds & 2>/dev/null || true

        THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
        bash ~/.config/hypr/scripts/write-colors.sh "$THEME"

        notify-send "HyDE" "Back to HyDE ARM 🎉" -t 2000 2>/dev/null || true
        ;;
esac
