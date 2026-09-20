#!/usr/bin/env bash
WALL="$1"
MODE="${2:-dark}"
SCHEME="${3:-$(cat ~/.config/hypr/themes/matugen-scheme-type 2>/dev/null || echo scheme-tonal-spot)}"
[ -z "$WALL" ] || [ ! -f "$WALL" ] && echo "Usage: matugen-apply.sh <wallpaper> [dark|light]" && exit 1

echo "Running matugen on: $WALL (mode: $MODE)"

# Run matugen — generates all template outputs via config.toml
matugen image "$WALL" \
    --source-color-index 0 \
    --mode "$MODE" \
    --type "$SCHEME" 2>/dev/null || { echo "[!] matugen failed"; exit 1; }

# Source the generated override file
source ~/.config/hypr/themes/matugen-override.sh 2>/dev/null || \
    { echo "[!] matugen override not generated"; exit 1; }

# Convert hex to rgb for BAR_BG
R=$(printf '%d' 0x${BG:1:2} 2>/dev/null || echo 30)
G=$(printf '%d' 0x${BG:3:2} 2>/dev/null || echo 30)
B=$(printf '%d' 0x${BG:5:2} 2>/dev/null || echo 46)
BAR_BG_VAL="rgba($R,$G,$B,0.88)"

# Append BAR_BG to override file
echo "BAR_BG=\"$BAR_BG_VAL\"" >> ~/.config/hypr/themes/matugen-override.sh

# Kitty — symlink generated colors
if [ -f ~/.cache/matugen/kitty-colors.conf ]; then
    ln -sf ~/.cache/matugen/kitty-colors.conf ~/.config/kitty/current-theme.conf
    kitty @ set-colors --all ~/.cache/matugen/kitty-colors.conf 2>/dev/null || true
fi

# Hyprland live border update
#hyprctl keyword "general:col.active_border" \
#    "rgba(${ACCENT#\#}ff) rgba(${ACCENT2#\#}ff) 45deg" 2>/dev/null || true
#hyprctl keyword "general:col.inactive_border" \
#    "rgba(${SURFACE#\#}ff)" 2>/dev/null || true

hyprctl eval "hl.config({ general = { col = { active_border = { colors = { 'rgba(${ACCENT#\#}ff)', 'rgba(${ACCENT2#\#}ff)' }, angle = 45 } } } })" >/dev/null || true
hyprctl eval "hl.config({ general = { col = { inactive_border = 'rgba(${SURFACE#\#}ff)' } } })" >/dev/null || true

# Swaync reload
swaync-client --reload-css 2>/dev/null || true

# Wallpaper + rofi sync
bash ~/.config/hypr/scripts/swww.sh "$WALL"
cp "$WALL" ~/.config/rofi/images/a.png 2>/dev/null || true
cp "$WALL" ~/.config/rofi/images/d.png 2>/dev/null || true
cp "$WALL" ~/.config/rofi/images/f.png 2>/dev/null || true
cat > ~/.config/rofi/current_wallpaper.rasi << EOF
* { current-image: url("${WALL}", width); }
EOF

# Save state
echo "matugen" > ~/.config/hypr/themes/current-name
echo "$WALL"   > ~/.config/hypr/themes/matugen-current-wall

# Run write-colors.sh with matugen override
bash ~/.config/hypr/scripts/write-colors.sh matugen

if [ "$BAR" == "notch" ] || [ "$BAR" == "pill" ] [ "$BAR" == "island" ]; then
     bash ~/.config/hypr/scripts/qs-bar-layout-switch.sh "$BAR"
fi

# Restart bar
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)
LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo hyde-default)
if [ "$BAR" == "notch" ] || [ "$BAR" == "pill" ] [ "$BAR" == "island" ]; then
     bash ~/.config/hypr/scripts/qs-bar-layout-switch.sh "$BAR"
fi

#if [ "$BAR" != "quickshell" ]; then
#    pkill waybar 2>/dev/null || true
#    sleep 0.3
#    bash ~/.config/hypr/scripts/bar-launch.sh "$BAR" "$LAYOUT"
#fi

if [ "$BAR" !== "quickshell" ] || [ "$BAR" !== "notch" ] || [ "$BAR" !== "pill" ] [ "$BAR" !== "island" ]; then
    pkill waybar 2>/dev/null || true
    sleep 0.3
    bash ~/.config/hypr/scripts/bar-launch.sh "$BAR" "$LAYOUT"
fi

notify-send "Matugen" "Material You colors from $(basename $WALL)" -t 2000 2>/dev/null || true
echo "Done!"

# Write wallpaper-theme.json for QS theme switcher wallpaper mode
python3 - << PYEOF
import json, os
colors_path = os.path.expanduser("~/.config/quickshell/topbar/colors.json")
out_path = os.path.expanduser("~/.config/quickshell/theme-switcher/wallpaper-theme.json")
try:
    with open(colors_path) as f:
        c = json.load(f)
    wt = {
        "name": "wallpaper", "family": "Dynamic",
        "bgBase": c.get("bg","#1E1E2E"), "bgSurface": c.get("surface","#313244"),
        "bgHover": c.get("surface2","#45475A"), "bgSelected": c.get("surface2","#45475A"),
        "bgBorder": c.get("surface2","#45475A"), "textPrimary": c.get("text","#CDD6F4"),
        "textSecondary": c.get("sub","#9399B2"), "textMuted": c.get("sub","#6C7086"),
        "accentPrimary": c.get("accent","#CBA6F7"), "accentCyan": c.get("teal","#94E2D5"),
        "accentGreen": c.get("green","#A6E3A1"), "accentOrange": c.get("yellow","#F9E2AF"),
        "accentRed": c.get("red","#F38BA8"),
    }
    with open(out_path, "w") as f:
        json.dump(wt, f, indent=2)
except: pass
PYEOF

# Write wallpaper-theme.json for QS theme switcher wallpaper mode
python3 - << PYEOF
import json, os
colors_path = os.path.expanduser("~/.config/quickshell/topbar/colors.json")
out_path = os.path.expanduser("~/.config/quickshell/theme-switcher/wallpaper-theme.json")
try:
    with open(colors_path) as f:
        c = json.load(f)
    wt = {
        "name": "wallpaper", "family": "Dynamic",
        "bgBase": c.get("bg","#1E1E2E"), "bgSurface": c.get("surface","#313244"),
        "bgHover": c.get("surface2","#45475A"), "bgSelected": c.get("surface2","#45475A"),
        "bgBorder": c.get("surface2","#45475A"), "textPrimary": c.get("text","#CDD6F4"),
        "textSecondary": c.get("sub","#9399B2"), "textMuted": c.get("sub","#6C7086"),
        "accentPrimary": c.get("accent","#CBA6F7"), "accentCyan": c.get("teal","#94E2D5"),
        "accentGreen": c.get("green","#A6E3A1"), "accentOrange": c.get("yellow","#F9E2AF"),
        "accentRed": c.get("red","#F38BA8"),
    }
    with open(out_path, "w") as f:
        json.dump(wt, f, indent=2)
except: pass
PYEOF
