
#!/usr/bin/env bash
# hyde-theme-select.sh
# Generates fake .desktop files per theme so rofi drun shows
# them as icon+name in HyDE's global selector style
# NOW: includes rounded icon generation for theme previews

DESKTOP_DIR="$HOME/.local/share/applications/hyde-themes"
ICON_DIR="/tmp/hyde-theme-icons"

mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

THEMES=(catppuccin tokyonight gruvbox nord rosepine everforest onedark everblush aozora latte astrabloom crimson solarized gruvbox-material iris matugen)
LABELS=("Catppuccin" "Tokyo Night" "Gruvbox" "Nord" "Rosé Pine" "Everforest" "One Dark" "Everblush" "Aozora Ink" "Latte" "Astra Bloom" "Crimson Twilight" "Solarized" "Gruvbox Material" "Iris(Dynamic)" "Matugen(Dynamic)")

# Generate .desktop file per theme
for i in "${!THEMES[@]}"; do
    t="${THEMES[$i]}"
    label="${LABELS[$i]}"

    WALL=$(find "$HOME/.config/hypr/wallpapers/$t" \
        -type f \( -iname "*.png" -o -iname "*.jpg" \) 2>/dev/null | head -1)

    ICON="$ICON_DIR/${t}.png"

    # Create rounded icon (cached)
    if [ -n "$WALL" ]; then
        if [ ! -f "$ICON" ]; then
            convert "$WALL" \
                -thumbnail 600x400^ \
                -gravity center \
                -extent 600x400 \
                \( +clone \
                    -alpha transparent \
                    -fill white \
                    -draw "roundrectangle 0,0 599,399 90,90" \
                \) \
                -compose CopyOpacity \
                -composite \
                "$ICON" 2>/dev/null || cp "$WALL" "$ICON"
        fi
    else
        ICON="image-missing"
    fi

    cat > "$DESKTOP_DIR/hyde-theme-${t}.desktop" << DESK
[Desktop Entry]
Name=${label}
Exec=bash -c 'bash ~/.config/hypr/scripts/theme-switch.sh ${t} && rm -rf ~/.local/share/applications/hyde-themes'
Icon=${ICON}
Type=Application
Categories=HyDE;
NoDisplay=false
DESK
done

# Launch rofi in drun mode pointing only at our fake desktop dir
XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS" \
rofi -show drun \
     -drun-categories HyDE \
     -theme ~/.config/rofi/selector.rasi \
     -show-icons

# Cleanup desktop files after selection (or on cancel)
rm -rf "$DESKTOP_DIR" 2>/dev/null || true
