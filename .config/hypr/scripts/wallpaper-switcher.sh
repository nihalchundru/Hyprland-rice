
#!/usr/bin/env bash

STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)
if [[ "$STYLE" == "quickshell" && ( "$BAR" == "hyprpanel" || "$BAR" == "waybar" ) ]]; then
    qs ipc -c ~/.config/quickshell/wallpaper-picker call wallpaper-picker toggle 2>/dev/null
    exit 0
fi

if [ "$BAR" = "notch" ]; then
    qs ipc -c ~/.config/quickshell/notch call notch toggleWallpaper
    exit 0
fi

if [ "$BAR" = "pill" ]; then
    qs ipc -c ~/.config/quickshell/topbar call topbar toggleWallpaper
    exit 0
fi

THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
if [ "$THEME" = "matugen" ] && { [ "$STYLE" = "compact" ] || [ "$STYLE" = "hyde" ]; }; then
    bash ~/.config/hypr/scripts/matugen-picker.sh
    exit 0
fi
echo "fh"
if [ "$THEME" = "iris" ] && { [ "$STYLE" = "compact" ] || [ "$STYLE" = "hyde" ]; }; then
    bash ~/.config/hypr/scripts/iris-picker.sh
    exit 0
fi

if [ "$THEME" = "iris" ] && [ "$STYLE" = "quickshell" ]; then
	qs ipc -c ~/.config/quickshell/wallpaper-picker call wallpaper-picker toggle
        exit 0 
fi

if [ "$THEME" = "matugen" ] && [ "$STYLE" = "quickshell" ]; then
        qs ipc -c ~/.config/quickshell/wallpaper-picker call wallpaper-picker toggle
        exit 0 
fi

if [ "$THEME" = "iris" ] && [ "$BAR" = "pill" ] || [ "$BAR" = "notch" ]; then
        qs ipc -c ~/.config/quickshell/wallpaper-picker call wallpaper-picker toggle
        exit 0 
fi

if [ "$THEME" = "matugen" ] && [ "$BAR" = "pill" ] || [ "$BAR" = "notch" ]; then
        qs ipc -c ~/.config/quickshell/wallpaper-picker call wallpaper-picker toggle
        exit 0 
fi

if [[ "$THEME" != "matugen" && "$THEME" != "iris" ]]; then
    case "$STYLE" in
        hyde) 
            bash ~/.config/hypr/scripts/hyde-wall-select.sh 
            ;; 
        quickshell) 
            qs ipc -c ~/.config/quickshell/wallpaper-picker call wallpaper-picker toggle 
            ;; 
        *) 
            # Add your default fallback here if needed
            ;;
    esac
fi
        THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
        WALL_DIR="$HOME/.config/hypr/wallpapers/$THEME"
        THUMB_DIR="/tmp/hyde-thumbs/$THEME"
        mkdir -p "$THUMB_DIR"
        
       # Check if the theme is matugen or iris
if [ "$THEME" = "matugen" ] || [ "$THEME" = "iris" ]; then
    WALL_DIR="$HOME/.config/hypr/wallpapers"
else
    WALL_DIR="$HOME/.config/hypr/wallpapers/$THEME"
fi
        mapfile -t WALLS < <(find "$WALL_DIR" \
            -type f \( -iname "*.png" -o -iname "*.jpg" \) | sort)

        [ ${#WALLS[@]} -eq 0 ] && notify-send "HyDE" "No wallpapers in $WALL_DIR" && exit 1

        for wall in "${WALLS[@]}"; do
            name=$(basename "$wall")
            thumb="$THUMB_DIR/$name"
            [ -f "$thumb" ] || convert "$wall" \
                -thumbnail 320x320^ -gravity center -extent 320x320 \
                "$thumb" 2>/dev/null || cp "$wall" "$thumb"
        done

        INPUT=""
        for wall in "${WALLS[@]}"; do
            name=$(basename "$wall")
            label="${name%.*}"
            thumb="$THUMB_DIR/$name"
            INPUT+="${label}\x00icon\x1f${thumb}\n"
        done

  #      SELECTED=$(printf "$INPUT" | rofi \
   #         -dmenu -p "Wallpaper" \
    #        -theme ~/.config/rofi/wallpaper.rasi \
     #       -show-icons -icon-size 320 -no-custom)

        [ -z "$SELECTED" ] && exit 0

        for wall in "${WALLS[@]}"; do
            name=$(basename "$wall")
            label="${name%.*}"
            if [ "$label" = "$SELECTED" ]; then
                bash ~/.config/hypr/scripts/set-wallpaper.sh "$wall"
                cat > ~/.config/rofi/current_wallpaper.rasi << EOF
* { current-image: url("${wall}", width); }
EOF
                cp "$wall" ~/.config/rofi/images/a.png 2>/dev/null || true
                cp "$wall" ~/.config/rofi/images/d.png 2>/dev/null || true
                cp "$wall" ~/.config/rofi/images/f.png 2>/dev/null || true
                break
            fi
        done
        ;;
esac
