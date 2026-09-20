#!/usr/bin/env bash
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)
STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)

if [ "$BAR" = "pill" ]; then
    qs ipc -c ~/.config/quickshell/topbar call topbar toggleWallpaper
    exit 0
fi

if [ "$BAR" = "notch" ]; then
    qs ipc -c ~/.config/quickshell/notch call notch toggleWallpaper
    exit 0
fi

if [ "$BAR" = "island" ]; then
    qs ipc -c ~/.config/quickshell/applets call wallpaper-switcher toggle
    exit 0
fi

WALL_BASE="$HOME/.config/hypr/wallpapers"
THUMB_DIR="/tmp/hyde-thumbs-matugen"
mkdir -p "$THUMB_DIR"

mapfile -t WALLS < <(find "$WALL_BASE" -type f \( -iname "*.png" -o -iname "*.jpg" \) | sort)
[ ${#WALLS[@]} -eq 0 ] && notify-send "Matugen" "No wallpapers found" && exit 1

for wall in "${WALLS[@]}"; do
    hash=$(echo "$wall" | md5sum | cut -c1-8)
    thumb="$THUMB_DIR/$hash.png"
    [ -f "$thumb" ] || magick "$wall" \
        -thumbnail 320x180^ -gravity center -extent 320x180 \
        "$thumb" 2>/dev/null || cp "$wall" "$thumb"
done

INPUT=""
for wall in "${WALLS[@]}"; do
    hash=$(echo "$wall" | md5sum | cut -c1-8)
    thumb="$THUMB_DIR/$hash.png"
    rel="${wall#$WALL_BASE/}"
    label="${rel%.*}"
    INPUT+="${label}\x00icon\x1f${thumb}\n"
done

case "$STYLE" in
    hyde)
        R_OVERRIDE="
window   { width: 95%; background-color: rgba(40, 44, 52, 35%); border: 0em; border-radius: 5em; }
mainbox  { background-color: transparent; orientation: horizontal;
           children: [\"dummy\",\"frame\",\"dummy\"]; }
frame    { children: [\"listview\"]; background-color: transparent; }
listview { columns: 3; lines: 1; spacing: 3em; padding: 3em;
           dynamic: true; fixed-height: false; fixed-columns: true;
           background-color: transparent; text-color: @main-fg; }
dummy    { width: 2em; expand: false; background-color: transparent; }
element  { orientation: vertical; border-radius: 12px; padding: 0.5em;
           cursor: pointer; background-color: transparent; text-color: @main-fg; }
element normal normal   { background-color: transparent; text-color: @main-fg; }
element selected normal { background-color: @select-bg; text-color: @select-fg; border-radius: 35px; }
element-icon { size: 28em; background-color: transparent; cursor: inherit; }
element-text { padding: 0.5em; vertical-align: 0.5; horizontal-align: 0.5;
               background-color: transparent; text-color: inherit;
               font: \"JetBrainsMono Nerd Font 9\"; }
"
        SELECTED=$(printf "$INPUT" | rofi \
            -dmenu -p "" -show-icons -icon-size 160 -no-custom \
            -theme ~/.config/rofi/selector.rasi \
            -theme-str "$R_OVERRIDE")
        ;;
    quickshell)
        qs ipc -c ~/.config/quickshell/applets call wallpaper-switcher toggle
        ;;
    *)
        SELECTED=$(printf "$INPUT" | rofi \
            -dmenu -p "󰸉 Iris Wallpaper" \
            -theme ~/.config/rofi/wallpaper.rasi \
            -show-icons -icon-size 160 -no-custom)
        ;;
esac

[ -z "$SELECTED" ] && exit 0

for wall in "${WALLS[@]}"; do
    rel="${wall#$WALL_BASE/}"
    label="${rel%.*}"
    if [ "$label" = "$SELECTED" ]; then
        bash ~/.config/hypr/scripts/matugen-apply.sh "$wall"
        break
    fi
done
