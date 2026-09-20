#!/usr/bin/env bash
THEME="${1:-$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)}"
source ~/.config/hypr/themes/themes.sh "$THEME"

[ -z "$BG" ] && exit 1

HP_CONFIG="$HOME/.config/hyprpanel/config.json"

# Generate hyprpanel config if missing
if [ ! -f "$HP_CONFIG" ]; then
    mkdir -p ~/.config/hyprpanel
    # Start hyprpanel briefly to generate config
    hyprpanel & sleep 3; pkill hyprpanel 2>/dev/null; sleep 1
fi

if [ -f "$HP_CONFIG" ]; then
    python3 - << PYEOF
import json, sys

path = "$HP_CONFIG"
try:
    with open(path) as f:
        c = json.load(f)
except:
    c = {}

# Set bar colors
c.setdefault("bar", {})
c["bar"]["background"] = "${BG}cc"
c["bar"]["buttons"] = c["bar"].get("buttons", {})
c["bar"]["buttons"]["style"] = "default"

# Set theme
c.setdefault("theme", {})
c["theme"].setdefault("bar", {})
c["theme"]["bar"]["background"] = "${BG}cc"
c["theme"]["bar"]["border"] = "${SURFACE}"

c.setdefault("palette", {})
c["palette"]["colors"] = {
    "color1":  "${ACCENT}",
    "color2":  "${ACCENT2}",
    "color3":  "${GREEN}",
    "color4":  "${TEAL}",
    "color5":  "${YELLOW}",
    "color6":  "${RED}",
    "color7":  "${TEXT}",
    "color8":  "${SUB}",
    "color9":  "${BG}",
    "color10": "${BG2}",
    "color11": "${SURFACE}",
    "color12": "${SURFACE2}",
}

with open(path, "w") as f:
    json.dump(c, f, indent=2)
print("HyprPanel config updated")
PYEOF

    # Restart hyprpanel if active bar
    BAR=\$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo "waybar")
    if [ "\$BAR" = "hyprpanel" ] && pgrep hyprpanel > /dev/null 2>&1; then
        pkill hyprpanel 2>/dev/null || true
        sleep 0.5
        hyprpanel &
    fi
fi
