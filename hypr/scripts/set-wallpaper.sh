#!/usr/bin/env bash
WALL="$1"
[ -z "$WALL" ] || [ ! -f "$WALL" ] && exit 1
bash ~/.config/hypr/scripts/swww.sh "$WALL"

# ── Sync rofi background images to match new wallpaper ───────────────────────
mkdir -p ~/.config/rofi/images
cp "$WALL" ~/.config/rofi/images/a.png 2>/dev/null || true
cp "$WALL" ~/.config/rofi/images/f.png 2>/dev/null || true
cp "$WALL" ~/.config/rofi/images/d.png 2>/dev/null || true
