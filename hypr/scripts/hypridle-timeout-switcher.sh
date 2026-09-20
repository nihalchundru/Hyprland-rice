#!/usr/bin/env bash

CONFIG="$HOME/.config/hypr/hypridle.conf"

# Read the first timeout value
CURRENT=$(awk '/^[[:space:]]*timeout[[:space:]]*=/{print $3; exit}' "$CONFIG")

# Convert to friendly text
case "$CURRENT" in
    30)       CURRENT_TEXT="30 Seconds" ;;
    60)       CURRENT_TEXT="1 Minute" ;;
    120)      CURRENT_TEXT="2 Minutes" ;;
    300)      CURRENT_TEXT="5 Minutes" ;;
    600)      CURRENT_TEXT="10 Minutes" ;;
    900)      CURRENT_TEXT="15 Minutes" ;;
    1800)     CURRENT_TEXT="30 Minutes" ;;
    99999999) CURRENT_TEXT="Never" ;;
    *)
        if (( CURRENT < 60 )); then
            CURRENT_TEXT="${CURRENT} Seconds"
        elif (( CURRENT % 60 == 0 )); then
            CURRENT_TEXT="$((CURRENT / 60)) Minutes"
        else
            CURRENT_TEXT="${CURRENT} Seconds"
        fi
        ;;
esac

CHOICE=$(printf \
"30 Seconds\n1 Minute\n2 Minutes\n5 Minutes\n10 Minutes\n15 Minutes\n30 Minutes\nNever" | \
rofi \
    -dmenu \
    -p "Current: $CURRENT_TEXT" \
    -theme ~/.config/rofi/applet.rasi \
    -no-custom)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "30 Seconds") LOCK=30 ;;
    "1 Minute")   LOCK=60 ;;
    "2 Minutes")  LOCK=120 ;;
    "5 Minutes")  LOCK=300 ;;
    "10 Minutes") LOCK=600 ;;
    "15 Minutes") LOCK=900 ;;
    "30 Minutes") LOCK=1800 ;;
    "Never")      LOCK=99999999 ;;
    *) exit 0 ;;
esac

DISPLAY=$((LOCK + 60))

awk -v lock="$LOCK" -v display="$DISPLAY" '
BEGIN { count = 0 }
/^[[:space:]]*timeout[[:space:]]*=/ {
    count++
    if (count == 1)
        sub(/[0-9]+/, lock)
    else if (count == 2)
        sub(/[0-9]+/, display)
}
{ print }
' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

pkill hypridle
hypridle &

notify-send "Hypridle" "Idle timeout set to $CHOICE"
