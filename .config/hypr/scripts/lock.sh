#!/usr/bin/env bash
LOCKSCREEN=$(cat ~/.config/hypr/active-lockscreen 2>/dev/null || echo hyprlock)

# Always copy current wallpaper before locking
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
source ~/.config/hypr/themes/themes.sh "$THEME" 2>/dev/null || true

mkdir -p ~/.config/hypr/assets
printf "\$lock_bg = rgb(%s)\n"  "${BG#\#}"     > ~/.config/hypr/assets/extracted_colors.conf
printf "\$lock_fg = rgb(%s)\n"  "${TEXT#\#}"   >> ~/.config/hypr/assets/extracted_colors.conf
printf "\$lock_acc = rgb(%s)\n" "${ACCENT#\#}" >> ~/.config/hypr/assets/extracted_colors.conf

WALL=$(grep -oP '(?<=url\(")[^"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1)
[ -n "$WALL" ] && [ -f "$WALL" ] && cp "$WALL" ~/.config/hypr/assets/current_wallpaper.png 2>/dev/null || true

case "$LOCKSCREEN" in
    quickshell)
        # Copy wallpaper to QS cache
        mkdir -p ~/.cache/quickshell/wallpaper_picker
        cp ~/.config/hypr/assets/current_wallpaper.png \
           ~/.cache/quickshell/wallpaper_picker/current_wallpaper.png 2>/dev/null || true
        qs -c ~/.config/quickshell/lockscreen
        ;;
    *)
        export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe
        export LIBGL_ALWAYS_SOFTWARE=1
        fish -c "hyprlock"
        ;;
esac
