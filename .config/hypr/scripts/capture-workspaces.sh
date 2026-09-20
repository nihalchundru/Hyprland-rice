#!/usr/bin/env bash
mkdir -p /tmp/hyde-overview
grim /tmp/hyde-overview/ws-current.png 2>/dev/null || \
    cp ~/.config/hypr/assets/current_wallpaper.png \
       /tmp/hyde-overview/ws-current.png 2>/dev/null || true
echo "captured"
