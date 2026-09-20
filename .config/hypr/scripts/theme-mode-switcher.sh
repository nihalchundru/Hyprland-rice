#!/usr/bin/env bash

THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)

declare -A LIGHT_MAP=(
    [gruvbox]="gruvbox-light"
    [gruvbox-light]="gruvbox"
    [nord]="nord-light"
    [nord-light]="nord"
    [solarized]="solarized-light"
    [solarized-light]="solarized"
)

TARGET="${LIGHT_MAP[$THEME]}"

if [[ -n "$TARGET" ]]; then
    bash ~/.config/hypr/scripts/theme-switch.sh "$TARGET"
    notify-send "HyDE" "Mode switched" -t 1500
else
    notify-send "HyDE" "Theme '$THEME' doesn't support light/dark mode." -t 2500
fi
