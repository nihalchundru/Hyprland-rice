BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)
STYLE=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)

# Quickshell bar always uses its own launcher
if [[ "$BAR" == "pill" && ( "$STYLE" == "hyde" || "$STYLE" == "compact" || "$STYLE" = "quickshell" ) ]]; then
    qs ipc -c ~/.config/quickshell/topbar call topbar toggleLauncher
    exit 0
fi

# Quickshell bar always uses its own launcher
if [[ "$BAR" == "notch" && ( "$STYLE" == "hyde" || "$STYLE" == "compact" || "$STYLE" = "quickshell" ) ]]; then
    qs ipc -c ~/.config/quickshell/notch call notch toggleLauncher
    exit 0
fi

case "$STYLE" in
    quickshell)
        qs ipc -c ~/.config/quickshell/launcher call launcher toggle
        ;;
    hyde)
        bash ~/.config/hypr/scripts/hyde-launcher.sh
        ;;
    *)
        # Compact — use current rofi layout
        LAYOUT=$(cat ~/.config/rofi/current-layout 2>/dev/null || echo "ml4w")
        case "$LAYOUT" in
            ml4w)
                rofi -show drun -theme ~/.config/rofi/config.rasi \
                     -show-icons -icon-theme Fluent
                ;;
            compact)
                rofi -show drun -theme ~/.config/rofi/config-compact.rasi \
                     -show-icons -icon-theme Fluent
                ;;
            adi1090x)
                rofi -show drun -theme ~/.config/rofi/config-adi.rasi \
                     -show-icons -icon-theme Fluent
                ;;
            grid)
                rofi -show drun -theme ~/.config/rofi/config-grid.rasi \
                     -show-icons -icon-theme Fluent
                ;;
            simple-grid)
                rofi -show drun -theme ~/.config/rofi/config-simple-grid.rasi \
                     -show-icons -icon-theme Fluent
                ;;
            *)
                rofi -show drun -theme ~/.config/rofi/config.rasi \
                     -show-icons -icon-theme Fluent
                ;;
        esac
        ;;
esac
