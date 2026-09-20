#!/usr/bin/env bash
# QS applet routing
if [ "$(cat ~/.config/rofi/picker-style 2>/dev/null)" = "quickshell" ]; then
    qs ipc -c ~/.config/quickshell/applets call matugen-scheme toggle 2>/dev/null || true
    exit 0
fi

THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
WALL=$(cat ~/.config/hypr/themes/matugen-current-wall 2>/dev/null)
CURRENT_MODE=$(cat ~/.config/hypr/themes/matugen-scheme-type 2>/dev/null || echo scheme-tonal-spot)

if [ "$THEME" != "matugen" ]; then
    notify-send "HyDE" "Switch to Matugen theme first" -t 2000
    exit 0
fi

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
    notify-send "HyDE" "No matugen wallpaper selected yet\nOpen ALT+W first" -t 2000
    exit 0
fi

CHOICE=$(printf \
"tonal-spot    — Material You default\ncontent       — Matches wallpaper closely\nexpressive    — Colorful high contrast\nfidelity      — High fidelity to source\nfruit-salad   — Playful mixed palette\nmonochrome    — Single hue variations\nneutral       — Muted understated tones\nrainbow       — Full spectrum\nvibrant       — Maximum saturation" | \
    rofi -dmenu \
         -p "Palette" \
         -theme ~/.config/rofi/applet.rasi \
         -no-custom \
         -mesg "Current: ${CURRENT_MODE#scheme-}")

[ -z "$CHOICE" ] && exit 0

# Extract first word and prepend scheme-
SHORT=$(echo "$CHOICE" | awk '{print $1}')
SCHEME="scheme-${SHORT}"

echo "$SCHEME" > ~/.config/hypr/themes/matugen-scheme-type
notify-send "Matugen" "Switching to $SHORT..." -t 1500 2>/dev/null || true
bash ~/.config/hypr/scripts/matugen-apply.sh "$WALL" dark "$SCHEME"
