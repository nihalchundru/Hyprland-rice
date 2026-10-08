#!/usr/bin/env bash
# Apply a theme the same way the rest of the rice does.

t="$1"
d="$HOME/.config/hypr"
[ -n "$t" ] || exit 1

# --- CRITICAL FIX 1: Save the active theme name so the entire rice tracks it ---
echo "$t" > "$d/themes/current-name"

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

        dir="$d/wallpapers/$t"
        [ -d "$dir" ] || exit 0

        cur=$(sed -n 's/.*url("\([^"]*\)".*/\1/p' "$HOME/.config/rofi/current_wallpaper.rasi" 2>/dev/null | head -n 1)
        
        # --- CRITICAL FIX 2: Use a flag instead of 'exit 0' to avoid killing the script ---
        already_in_folder=false
        case "$cur" in
            "$dir"/*) already_in_folder=true ;;
        esac

        if [ "$already_in_folder" = false ]; then
            first=$(find "$dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort | head -n 1)
            [ -n "$first" ] && bash "$d/scripts/set-wallpaper.sh" "$first"
        fi
        ;;
esac
