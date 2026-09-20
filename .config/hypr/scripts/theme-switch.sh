STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)
if [[ "$STYLE" == "quickshell" && ( "$BAR" == "hyprpanel" || "$BAR" == "waybar" ) && -z "$1" ]]; then
    qs ipc -c ~/.config/quickshell/theme-switcher call theme-picker toggle 2>/dev/null
    exit 0
fi

#!/usr/bin/env bash

if [ -n "$1" ]; then
    THEME="$1"
else
    BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)
    STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)

    if [ "$BAR" = "pill" ]; then
        qs ipc -c ~/.config/quickshell/topbar call topbar toggleTheme
        exit 0
    fi


    if [ "$BAR" = "notch" ]; then
        qs ipc -c ~/.config/quickshell/notch call notch toggleTheme
        exit 0
    fi

    case "$STYLE" in
        hyde)
            bash ~/.config/hypr/scripts/hyde-theme-select.sh
            exit 0
            ;;
        quickshell)
            qs ipc -c ~/.config/quickshell/theme-switcher call theme-picker toggle
            ;;
        *)
            THEME=$(printf "catppuccin\ntokyonight\ngruvbox\nnord\nrosepine\neverforest\nonedark\neverblush\naozora\nlatte\nastrabloom\ncrimson\nsolarized\niris\nmatugen" | \
                rofi -dmenu -p "Select Theme" \
                     -theme ~/.config/rofi/applet.rasi -no-custom)
            ;;
    esac
fi

[ -z "$THEME" ] && exit 0

    if [ "$THEME" = "iris\nmatugen" ] && [ -z "$1" ]; then
        bash ~/.config/hypr/scripts/iris-picker.sh
        exit 0
    fi


echo "$THEME" > ~/.config/hypr/themes/current-name
notify-send "HyDE" "Theme → $THEME" -t 2000 2>/dev/null || true

bash ~/.config/hypr/scripts/write-colors.sh "$THEME"

source ~/.config/hypr/themes/themes.sh "$THEME"

WALL=$(find ~/.config/hypr/wallpapers/$WALL_DIR \
    -type f \( -iname "*.png" -o -iname "*.jpg" \) 2>/dev/null | shuf -n 1)
if [ -n "$WALL" ]; then
    cat > ~/.config/rofi/current_wallpaper.rasi << EOF
* { current-image: url("${WALL}", width); }
EOF
    bash ~/.config/hypr/scripts/set-wallpaper.sh "$WALL"
fi

# Loop through every active Kitty window socket and force the update
for socket in /tmp/kitty-*; do
    if [ -S "$socket" ]; then
        kitty @ --to "unix:$socket" set-colors --all --configured ~/.config/kitty/theme.conf
    fi
done

bash ~/.config/hypr/scripts/update-hyprpanel-theme.sh "$THEME" 2>/dev/null || true

hyprctl reload 2>/dev/null || true

BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo "waybar")
LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo "hyde-default")
echo "hello"
if [ "$BAR" = "notch" ] || [ "$BAR" = "pill" ] || [ "$BAR" = "island" ]; then
    bash ~/.config/hypr/scripts/qs-bar-layout-switch.sh "$BAR"
fi

if [ "$BAR" !== "quickshell" ] || [ "$BAR" !== "pill" ] || [ "$BAR" !== "island" ] || [ "$BAR" !== "notch" ]; then
    pkill waybar 2>/dev/null || true
    pkill hyprpanel 2>/dev/null || true
    sleep 0.3
    bash ~/.config/hypr/scripts/bar-launch.sh "$BAR" "$LAYOUT"
fi
