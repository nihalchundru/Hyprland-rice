#!/usr/bin/env bash
# Lists wallpapers for a theme:
#   iris / matugen  -> every folder under ~/.config/hypr/wallpapers
#   anything else   -> only ~/.config/hypr/wallpapers/<theme>
# Usage: wall-list.sh [theme]   (defaults to the contents of current-name)
d="$HOME/.config/hypr"

# Strip trailing newlines or whitespace from the current-name file
t="${1:-$(cat "$d/themes/current-name" 2>/dev/null | tr -d '\n' || echo catppuccin)}"

if [ "$t" = "iris" ] || [ "$t" = "matugen" ]; then
    root="$d/wallpapers"
else
    root="$d/wallpapers/$t"
fi

[ -d "$root" ] || exit 0
find "$root" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort
