#!/usr/bin/env bash
# ============================================================================
# m32/scripts/boot-matugen.sh
# Runs your existing ~/.config/hypr/scripts/matugen-apply.sh on
# ~/.config/rofi/images/a.png (or argument 1) without overriding your scheme,
# and copies ~/.config/quickshell/topbar/colors.json to m32/colors.json.
# ============================================================================
set -u

M32_DIR="${M32_DIR:-$HOME/.config/quickshell/m32}"
WALL="${1:-$HOME/.config/rofi/images/a.png}"

mkdir -p "$M32_DIR"

# Run the user's own matugen-apply.sh script as-is (no mode/scheme overrides)
if [[ -f "$WALL" && -f "$HOME/.config/hypr/scripts/matugen-apply.sh" ]]; then
    bash "$HOME/.config/hypr/scripts/matugen-apply.sh" "$WALL" >/dev/null 2>&1 || true
fi

# Mirror topbar/colors.json (written by write-colors.sh) to m32/colors.json
if [[ -f "$HOME/.config/quickshell/topbar/colors.json" ]]; then
    cp "$HOME/.config/quickshell/topbar/colors.json" "$M32_DIR/colors.json"
fi
