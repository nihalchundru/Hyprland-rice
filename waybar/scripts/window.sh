#!/usr/bin/env bash
# Active window title for waybar custom/active_window
title=$(hyprctl activewindow -j 2>/dev/null | python3 -c "
import json,sys
try:
    d = json.load(sys.stdin)
    t = d.get('title','')
    if len(t) > 30: t = t[:28] + '…'
    print(json.dumps({'text': t, 'tooltip': d.get('title',''), 'class': 'active'}))
except:
    print(json.dumps({'text': '', 'tooltip': '', 'class': ''}))
" 2>/dev/null)
echo "${title:-\{\"text\":\"\",\"class\":\"\"\}}"
