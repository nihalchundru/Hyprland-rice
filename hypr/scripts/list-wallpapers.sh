#!/usr/bin/env bash
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)
WALL_DIR="$HOME/.config/hypr/wallpapers/$THEME"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs/$THEME"

mkdir -p "$THUMB_DIR"

python3 - "$WALL_DIR" "$THUMB_DIR" << 'PYEOF'
import json, sys, os, subprocess

d = sys.argv[1]
thumb_dir = sys.argv[2]

files = []
if os.path.isdir(d):
    for f in sorted(os.listdir(d)):
        if f.lower().endswith((".png", ".jpg", ".jpeg")):
            src = os.path.join(d, f)
            thumb = os.path.join(thumb_dir, f + ".jpg")

            # generate thumbnail if missing or outdated
            if not os.path.exists(thumb) or os.path.getmtime(src) > os.path.getmtime(thumb):
                os.makedirs(thumb_dir, exist_ok=True)
                subprocess.run([
                    "magick", src,
                    "-resize", "500x300^",
                    "-gravity", "center",
                    "-extent", "500x300",
                    "-strip",
                    thumb
                ])

            files.append({
                "name": os.path.splitext(f)[0],
                "path": src,
                "thumb": thumb
            })

print(json.dumps(files))
PYEOF
