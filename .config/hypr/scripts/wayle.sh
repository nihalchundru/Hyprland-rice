#!/bin/bash
# 1. Expand the image to a full absolute path
WP_PATH=$(realpath "$1")

# 2. Update the wallpaper path in Wayle's config file
sed -i "s|wallpaper = .*|wallpaper = \"$WP_PATH\"|" ~/.config/wayle/config.toml

# 3. Force Matugen to generate colors without crashing
matugen image "$WP_PATH" --source-color-index 0
