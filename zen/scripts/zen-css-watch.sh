#!/usr/bin/env bash

CSS="/home/nihal/.config/zen/o5lc5mru.Default (release)/chrome/userChrome.css"

while inotifywait -e close_write "$CSS"; do
    echo "Zen CSS updated"
done
