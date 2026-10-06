#!/usr/bin/env bash
# Apply a theme the same way the rest of the rice does.
t="$1"
d="$HOME/.config/hypr"
[ -n "$t" ] || exit 1

case "$t" in
    iris)
        w=$(cat "$d/themes/iris-current-wall" 2>/dev/null)
        if [ -n "$w" ] && [ -f "$w" ]; then bash "$d/scripts/iris-apply.sh" "$w"
        else bash "$d/scripts/write-colors.sh" iris; fi
        ;;
    matugen)
        w=$(cat "$d/themes/matugen-current-wall" 2>/dev/null)
        if [ -n "$w" ] && [ -f "$w" ]; then bash "$d/scripts/matugen-apply.sh" "$w"
        else bash "$d/scripts/write-colors.sh" matugen; fi
        ;;
    *)
        bash "$d/scripts/write-colors.sh" "$t"
        ;;
esac
