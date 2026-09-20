#!/usr/bin/env bash
WALL="$1"
[ -z "$WALL" ] || [ ! -f "$WALL" ] && echo "Usage: iris-apply.sh <wallpaper>" && exit 1

echo "Running iris on: $WALL"
iris "$WALL" 2>/dev/null || { echo "[!] iris failed"; exit 1; }

source ~/.cache/iris/colors.sh 2>/dev/null || { echo "[!] No iris colors found"; exit 1; }

# Map iris vars to HyDE ARM vars
BG="$bg"
BG2="${color0:-$bg}"
SURFACE="$surface"
SURFACE2="${color8:-$surface}"
TEXT="$fg"
SUB="$dim"
ACCENT="$accent"
ACCENT2="${color4:-$accent}"
GREEN="$green"
RED="$red"
YELLOW="$yellow"
TEAL="${color6:-$accent}"

# Convert hex to rgb for BAR_BG
R=$(printf '%d' 0x${BG:1:2} 2>/dev/null || echo 30)
G=$(printf '%d' 0x${BG:3:2} 2>/dev/null || echo 30)
B=$(printf '%d' 0x${BG:5:2} 2>/dev/null || echo 46)
BAR_BG="rgba($R,$G,$B,0.88)"
MAIN_BG="$BG2"
MAIN_FG="$ACCENT"
WB_ACT_BG="$ACCENT"
WB_ACT_FG="$BG"
WB_HVR_BG="$ACCENT2"
WB_HVR_FG="$BG"

# Write override file — all vars on separate lines, no subshell needed
cat > ~/.config/hypr/themes/iris-override.sh << EOF
BG="$BG"
BG2="$BG2"
SURFACE="$SURFACE"
SURFACE2="$SURFACE2"
TEXT="$TEXT"
SUB="$SUB"
ACCENT="$ACCENT"
ACCENT2="$ACCENT2"
GREEN="$GREEN"
RED="$RED"
YELLOW="$YELLOW"
TEAL="$TEAL"
BAR_BG="$BAR_BG"
MAIN_BG="$MAIN_BG"
MAIN_FG="$MAIN_FG"
WB_ACT_BG="$WB_ACT_BG"
WB_ACT_FG="$WB_ACT_FG"
WB_HVR_BG="$WB_HVR_BG"
WB_HVR_FG="$WB_HVR_FG"
THEME="iris"
EOF

echo "iris" > ~/.config/hypr/themes/current-name
echo "$WALL" > ~/.config/hypr/themes/iris-current-wall

# Call write-colors.sh — it will source iris-override.sh
bash ~/.config/hypr/scripts/write-colors.sh iris

# Kitty symlink
[ -f ~/.cache/iris/colors-kitty.conf ] && \
    ln -sf ~/.cache/iris/colors-kitty.conf ~/.config/kitty/current-theme.conf && \
    kitty @ set-colors --all ~/.cache/iris/colors-kitty.conf 2>/dev/null || true

# Hyprland live border update
#hyprctl eval "hl.config({ general = { col = { active_border = 'rgba(${ACCENT#\#}ff) rgba(${ACCENT2#\#}ff) 45deg' } } })" >/dev/null || true
#hyprctl eval "hl.config({ general = { col = { inactive_border = 'rgba(${SURFACE#\#}ff)' } } })" >/dev/null || true
# Hyprland live border update
hyprctl eval "hl.config({ general = { col = { active_border = { colors = { 'rgba(${ACCENT#\#}ff)', 'rgba(${ACCENT2#\#}ff)' }, angle = 45 } } } })" >/dev/null || true
hyprctl eval "hl.config({ general = { col = { inactive_border = 'rgba(${SURFACE#\#}ff)' } } })" >/dev/null || true

# Wallpaper + rofi images
bash ~/.config/hypr/scripts/swww.sh "$WALL"
cp "$WALL" ~/.config/rofi/images/a.png 2>/dev/null || true
cp "$WALL" ~/.config/rofi/images/d.png 2>/dev/null || true
cp "$WALL" ~/.config/rofi/images/f.png 2>/dev/null || true
cat > ~/.config/rofi/current_wallpaper.rasi << EOF2
* { current-image: url("${WALL}", width); }
EOF2

# Restart bar
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)
LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo hyde-default)

if [ "$BAR" == "notch" ] || [ "$BAR" == "pill" ] [ "$BAR" == "island" ]; then
     bash ~/.config/hypr/scripts/qs-bar-layout-switch.sh "$BAR"
fi

if [ "$BAR" !== "quickshell" ] || [ "$BAR" !== "notch" ] || [ "$BAR" !== "pill" ] [ "$BAR" !== "island" ]; then
    pkill waybar 2>/dev/null || true
    sleep 0.3
    bash ~/.config/hypr/scripts/bar-launch.sh "$BAR" "$LAYOUT"
fi

notify-send "Iris" "Colors from $(basename $WALL)" -t 2000 2>/dev/null || true
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
