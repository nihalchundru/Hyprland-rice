#!/usr/bin/env bash
# colorpicker.sh — picks a color from screen using hyprpicker or grim+slurp

if [ "$1" = "-j" ]; then
    # Return current accent color as JSON for waybar
    THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
    source ~/.config/hypr/themes/themes.sh "$THEME" 2>/dev/null || true
    echo "{\"text\":\"\",\"tooltip\":\"${ACCENT}\",\"class\":\"\"}"
    exit 0
fi

# Pick color from screen
if command -v hyprpicker &>/dev/null; then
    COLOR=$(hyprpicker -a 2>/dev/null)
elif command -v grim &>/dev/null && command -v slurp &>/dev/null; then
    COLOR=$(grim -g "$(slurp -p)" - | \
        python3 -c "
import sys
from PIL import Image
import io
img = Image.open(io.BytesIO(sys.stdin.buffer.read()))
r,g,b = img.getpixel((0,0))[:3]
print(f'#{r:02X}{g:02X}{b:02X}')
" 2>/dev/null)
else
    notify-send "HyDE" "Install hyprpicker for color picking" -t 2000
    exit 1
fi

if [ -n "$COLOR" ]; then
    echo -n "$COLOR" | wl-copy
    notify-send "HyDE" "Color copied: $COLOR" -t 1500 2>/dev/null || true
    pkill -SIGRTMIN+1 waybar 2>/dev/null || true
fi
