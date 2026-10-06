#!/usr/bin/env bash
# Same routing as wallpaper-switcher.sh: iris / matugen extract colors too.
w="$1"
d="$HOME/.config/hypr"
[ -f "$w" ] || exit 1
t=$(cat "$d/themes/current-name" 2>/dev/null || echo catppuccin)

case "$t" in
    iris)    bash "$d/scripts/iris-apply.sh" "$w" ;;
    matugen) bash "$d/scripts/matugen-apply.sh" "$w" ;;
    *)       bash "$d/scripts/set-wallpaper.sh" "$w" ;;
esac
