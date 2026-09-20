#!/usr/bin/env bash
# hyprlock-weather.sh — fetches weather for lock screen
WEATHER=$(curl -sf --max-time 5 "wttr.in/?format=%c+%t+%C" 2>/dev/null | \
    sed 's/+/ /g; s/  / /g')
[ -z "$WEATHER" ] && WEATHER="  Weather unavailable"
echo "$WEATHER"
