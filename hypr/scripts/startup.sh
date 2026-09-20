#!/usr/bin/env bash
# Startup — init awww daemon, apply theme, launch waybar
mkdir -p ~/.cache/awww
awww-daemon 2>/dev/null &
sleep 0.5
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo "catppuccin")
source ~/.config/hypr/themes/themes.sh "$THEME"
# Apply waybar theme.css on startup
cat > ~/.config/waybar/theme.css << WAYBAR
@define-color bar-bg ${BAR_BG};
@define-color main-bg ${MAIN_BG};
@define-color main-fg ${MAIN_FG};
@define-color wb-act-bg ${WB_ACT_BG};
@define-color wb-act-fg ${WB_ACT_FG};
@define-color wb-hvr-bg ${WB_HVR_BG};
@define-color wb-hvr-fg ${WB_HVR_FG};
WAYBAR
qs -c ~/.config/hypr/topbar
sleep 0.5
WALL=$(find ~/.config/hypr/wallpapers/$WALL_DIR \
    -type f \( -iname "*.png" -o -iname "*.jpg" \) 2>/dev/null | shuf -n 1)
[ -n "$WALL" ] && bash ~/.config/hypr/scripts/swww.sh "$WALL"

# Start quickshell sidebar (hidden until ALT+A)
qs -c ~/.config/quickshell/sidebar &

# Keybinds popup
qs -c ~/.config/quickshell/keybinds &

# Clipboard watchers
wl-paste --type text  --watch cliphist store &
wl-paste --type image --watch cliphist store &

# Volume/Brightness OSD
qs -c ~/.config/quickshell/osd &
qs -c ~/.config/quickshell/overview &
qs -c ~/.config/quickshell/settings &

# QS standalone pickers
qs -c ~/.config/quickshell/theme-switcher &
qs -c ~/.config/quickshell/wallpaper-picker &
qs -c ~/.config/quickshell/launcher &
qs -c ~/.config/quickshell/applets &
