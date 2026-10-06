#!/usr/bin/env bash
# Lists wallpapers for the active theme (all folders for iris / matugen).
d="$HOME/.config/hypr"
t=$(cat "$d/themes/current-name" 2>/dev/null || echo catppuccin)
if [ "$t" = "iris" ] || [ "$t" = "matugen" ]; then
    root="$d/wallpapers"
else
    root="$d/wallpapers/$t"
fi
[ -d "$root" ] || exit 0
find "$root" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort
