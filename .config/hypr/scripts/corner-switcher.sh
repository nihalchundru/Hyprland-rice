#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call corner-style toggle 2>/dev/null || true
    exit 0
fi

CURRENT=$(cat ~/.config/hypr/themes/corner-style 2>/dev/null || echo "rounded")

CHOICE=$(printf "rounded\nsharp" | \
    rofi -dmenu \
         -p "Corner Style" \
         -theme ~/.config/rofi/applet.rasi \
         -no-custom)

[ -z "$CHOICE" ] && exit 0

echo "$CHOICE" > ~/.config/hypr/themes/corner-style

case "$CHOICE" in
    sharp)
        ROUNDING=0
        WB_WS_RADIUS="0px"
        WB_MOD_RADIUS="0px"
        WB_BAR_RADIUS="0px"
        ROFI_WIN_RADIUS="0px"
        ROFI_EL_RADIUS="0px"
        ROFI_BTN_RADIUS="0px"
        ;;
    rounded)
        ROUNDING=10
        WB_WS_RADIUS="20px"
        WB_MOD_RADIUS="10px"
        WB_BAR_RADIUS="14px"
        ROFI_WIN_RADIUS="14px"
        ROFI_EL_RADIUS="10px"
        ROFI_BTN_RADIUS="18px"
        ;;
esac

# ── Hyprland ──────────────────────────────────────────────────────────────────
hyprctl keyword decoration:rounding $ROUNDING 2>/dev/null || true

# ── Waybar style.css ──────────────────────────────────────────────────────────
# Use a marker-based replacement so it always works regardless of current value
python3 - << PYEOF
import re

files = [
    "$HOME/.config/waybar/style.css",
    "$HOME/.config/waybar/layouts/custom.css",
    "$HOME/.config/waybar/layouts/dock.css",
]

for path in files:
    try:
        with open(path, 'r') as f:
            css = f.read()

        # workspace buttons
        css = re.sub(
            r'(#workspaces\s+button\s*\{[^}]*?)border-radius:\s*[^;]+;',
            r'\1border-radius: ${WB_WS_RADIUS};',
            css, flags=re.DOTALL
        )
        css = re.sub(
            r'(#workspaces\s+button\.active\s*\{[^}]*?)border-radius:\s*[^;]+;',
            r'\1border-radius: ${WB_WS_RADIUS};',
            css, flags=re.DOTALL
        )
        # window bar
        css = re.sub(
            r'(window#waybar\s*\{[^}]*?)border-radius:\s*[^;]+;',
            r'\1border-radius: ${WB_BAR_RADIUS};',
            css, flags=re.DOTALL
        )
        # module pills
        css = re.sub(
            r'(\.(pill|leaf)\s*\{[^}]*?)border-radius:\s*[^;]+;',
            r'\1border-radius: ${WB_MOD_RADIUS};',
            css, flags=re.DOTALL
        )

        with open(path, 'w') as f:
            f.write(css)
        print(f"Updated: {path}")
    except Exception as e:
        print(f"Skip {path}: {e}")
PYEOF

# ── Rofi ──────────────────────────────────────────────────────────────────────
for f in ~/.config/rofi/config.rasi \
         ~/.config/rofi/config-compact.rasi \
         ~/.config/rofi/applet.rasi \
         ~/.config/rofi/wallpaper.rasi; do
    [ -f "$f" ] || continue
    # window border-radius
    sed -i "s/border-radius:.*14px.*;\(.*window\)/border-radius:    ${ROFI_WIN_RADIUS};\1/" "$f" 2>/dev/null || true
    python3 - "$f" "${ROFI_WIN_RADIUS}" "${ROFI_EL_RADIUS}" "${ROFI_BTN_RADIUS}" << 'PYEOF'
import re, sys
path, win_r, el_r, btn_r = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
try:
    with open(path, 'r') as f: css = f.read()
    # window
    css = re.sub(r'(window\s*\{[^}]*?)border-radius:\s*[^;]+;', r'\1border-radius: ' + win_r + ';', css, flags=re.DOTALL)
    # element
    css = re.sub(r'(element\s*\{[^}]*?)border-radius:\s*[^;]+;', r'\1border-radius: ' + el_r + ';', css, flags=re.DOTALL)
    # button (circular)
    css = re.sub(r'(button\s*\{[^}]*?)border-radius:\s*[^;]+;', r'\1border-radius: ' + btn_r + ';', css, flags=re.DOTALL)
    with open(path, 'w') as f: f.write(css)
    print(f"Updated: {path}")
except Exception as e: print(f"Skip {path}: {e}")
PYEOF
done

# ── EWW ───────────────────────────────────────────────────────────────────────
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo "catppuccin")
bash ~/.config/hypr/scripts/write-eww-colors.sh "$THEME"

# ── Restart waybar ────────────────────────────────────────────────────────────
BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo "waybar")
LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo "hyde-default")
pkill waybar 2>/dev/null || true
sleep 0.3
bash ~/.config/hypr/scripts/bar-launch.sh "$BAR" "$LAYOUT"

notify-send "HyDE" "Corners → $CHOICE" -t 2000 2>/dev/null || true
