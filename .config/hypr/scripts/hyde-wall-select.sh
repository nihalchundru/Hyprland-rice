#!/usr/bin/env bash
# hyde-wall-select.sh
# HyDE's Wall_Select method adapted for ARM rofi-git
# Uses -theme-str to override columns/sizing at runtime (no static rasi needed)

THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
WALL_DIR="$HOME/.config/hypr/wallpapers/$THEME"
THUMB_DIR="/tmp/hyde-thumbs-sq/$THEME"
mkdir -p "$THUMB_DIR"


# Check if the theme is matugen or iris
if [ "$THEME" = "matugen" ] || [ "$THEME" = "iris" ]; then
    WALL_DIR="$HOME/.config/hypr/wallpapers"
else
    WALL_DIR="$HOME/.config/hypr/wallpapers/$THEME"
fi


if ! command -v convert &>/dev/null; then
    notify-send "HyDE" "imagemagick required" 2>/dev/null
    exit 1
fi

mapfile -t WALLS < <(find "$WALL_DIR" \
    -type f \( -iname "*.png" -o -iname "*.jpg" \) | sort)

[ ${#WALLS[@]} -eq 0 ] && notify-send "HyDE" "No wallpapers in $WALL_DIR" && exit 1

# Square thumbnails + rounded overlay (HyDE stable method)
for wall in "${WALLS[@]}"; do
    name=$(basename "$wall")
    thumb="$THUMB_DIR/$name"

    if [ ! -f "$thumb" ]; then

        # Step 1: base square crop (same as HyDE working logic)
        convert "$wall" \
            -thumbnail 400x400^ \
            -gravity center \
            -extent 400x400 \
            "$thumb"

        # Step 2: apply rounding (stable overlay method)
        convert "$thumb" \
            \( -size 400x400 xc:none \
               -fill white \
               -draw "roundrectangle 0,0 399,399 35,35" \) \
            -alpha set \
            -compose DstIn \
            -composite \
            "$thumb"
    fi
done

# Calculate columns from monitor width (like HyDE does)
MON_W=$(hyprctl -j monitors 2>/dev/null | \
    python3 -c "import json,sys; m=[x for x in json.load(sys.stdin) if x.get('focused')]; print(m[0]['width'] if m else 1920)" 2>/dev/null || echo 1920)
FONT_SCALE=10
ELM_W=$(( (28 + 8 + 5) * FONT_SCALE ))
MAX_AV=$(( MON_W - (4 * FONT_SCALE) ))
COL_COUNT=$(( MAX_AV / ELM_W ))
[ "$COL_COUNT" -lt 2 ] && COL_COUNT=3
[ "$COL_COUNT" -gt 8 ] && COL_COUNT=8

# Build dmenu input: "name:::full_path:::thumb_path"
INPUT=""
for wall in "${WALLS[@]}"; do
    name=$(basename "$wall")
    label="${name%.*}"
    thumb="$THUMB_DIR/$name"
    # rofi icon via \x00icon\x1f (rofi-git native icon syntax)
    INPUT+="${label}\x00icon\x1f${thumb}\n"
done

# HyDE's r_override approach — inject layout via -theme-str
R_OVERRIDE="
window   { width: 95%; background-color: rgba(40, 44, 52, 35%); border: 0em; border-radius: 5em; }
mainbox  { background-color: transparent; orientation: horizontal;
           children: [\"dummy\",\"frame\",\"dummy\"]; }
frame    { children: [\"listview\"]; background-color: transparent; }
listview { columns: 3; lines: 1; spacing: 3em; padding: 1.5em;
           dynamic: true; fixed-height: false; fixed-columns: true;
           background-color: transparent; text-color: @main-fg; }
dummy    { width: 2em; expand: false; background-color: transparent; }
element  { orientation: vertical; border-radius: 12px; padding: 0.5em;
           cursor: pointer; background-color: transparent; text-color: @main-fg; }
element normal normal   { background-color: transparent; text-color: @main-fg; }
element selected normal { background-color: @select-bg; text-color: @select-fg;
                          border-radius: 35px; }
element-icon { size: 28em; background-color: transparent; cursor: inherit; }
element-text { padding: 0.5em; vertical-align: 0.5; horizontal-align: 0.5;
               background-color: transparent; text-color: inherit;
               font: \"JetBrainsMono Nerd Font 9\"; }
"

SELECTED=$(printf "$INPUT" | rofi \
    -dmenu \
    -p "" \
    -show-icons \
    -icon-size 160 \
    -no-custom \
    -theme ~/.config/rofi/selector.rasi \
    -theme-str "$R_OVERRIDE")

[ -z "$SELECTED" ] && exit 0

# Match back to full path
for wall in "${WALLS[@]}"; do
    name=$(basename "$wall")
    label="${name%.*}"
    if [ "$label" = "$SELECTED" ]; then
        bash ~/.config/hypr/scripts/set-wallpaper.sh "$wall"
        cat > ~/.config/rofi/current_wallpaper.rasi << EOF
* { current-image: url("${wall}", width); }
EOF
        # Also sync rofi background images
        cp "$wall" ~/.config/rofi/images/a.png 2>/dev/null || true
        cp "$wall" ~/.config/rofi/images/d.png 2>/dev/null || true
        cp "$wall" ~/.config/rofi/images/f.png 2>/dev/null || true
        break
    fi
done
