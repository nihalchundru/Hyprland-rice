#!/usr/bin/env bash
# Toggle scratchpad — spawns kitty if not running, else shows/hides

SCRATCH_CLASS="kitty-scratchpad"

# Check if scratchpad window exists
if hyprctl clients -j 2>/dev/null | python3 -c "
import json,sys
clients = json.load(sys.stdin)
exists = any(c.get('class','') == '$SCRATCH_CLASS' for c in clients)
sys.exit(0 if exists else 1)
" 2>/dev/null; then
    # Toggle visibility via special workspace
    hyprctl dispatch togglespecialworkspace scratchpad
else
    # Spawn fresh scratchpad
    kitty --class "$SCRATCH_CLASS" --title "Scratchpad" &
fi
