#!/usr/bin/env bash
# hyde-launcher.sh
# HyDE-style app launcher — uses temp rasi file to avoid shell quoting issues

# Get Hyprland border radius
HYPR_BORDER=$(hyprctl getoption decoration.rounding 2>/dev/null | awk '/^int:/{print $2}')
HYPR_BORDER=${HYPR_BORDER:-10}
ELEM_BORDER=$(( HYPR_BORDER * 3 ))
WIN_BORDER=$(( HYPR_BORDER * 2 ))

# Calculate columns from monitor width
MON_W=$(hyprctl -j monitors 2>/dev/null | \
    python3 -c "
import json,sys
try:
    m=[x for x in json.load(sys.stdin) if x.get('focused')]
    print(m[0]['width'] if m else 1920)
except:
    print(1920)
" 2>/dev/null || echo 1920)

FONT_SCALE=10
ELM_W=$(( (28 + 8 + 5) * FONT_SCALE ))
MAX_AV=$(( MON_W - (4 * FONT_SCALE) ))
COL_COUNT=$(( MAX_AV / ELM_W ))
[ "$COL_COUNT" -lt 3 ] && COL_COUNT=3
[ "$COL_COUNT" -gt 8 ] && COL_COUNT=8

# Write to temp rasi file (avoids all shell quoting issues with -theme-str)
cat > /tmp/hyde-launcher.rasi << RASI
@import "${HOME}/.config/rofi/theme.rasi"

window {
    width:            85%;
    border-radius:    ${WIN_BORDER}px;
    background-color: rgba(40, 44, 52, 35%);
    border:           2px;
    border-color:     @main-br;
}

mainbox {
    orientation:      horizontal;
    children:         ["dummy", "frame", "dummy"];
    background-color: transparent;
}

frame {
    children:         ["inputbar", "listview"];
    background-color: transparent;
    padding:          2em;
    spacing:          1em;
}

dummy {
    width:            2em;
    expand:           false;
    background-color: transparent;
}

inputbar {
    background-color: @main-bg;
    border-radius:    ${ELEM_BORDER}px;
    padding:          0.8em 1.2em;
    children:         ["textbox-prompt-colon", "entry"];
    spacing:          0.6em;
}

textbox-prompt-colon {
    expand:           false;
    str:              "󰍉 ";
    background-color: transparent;
    text-color:       @main-br;
}

entry {
    background-color:  transparent;
    text-color:        @main-fg;
    placeholder:       "Search applications...";
    placeholder-color: @main-fg;
}

listview {
    columns:          ${COL_COUNT};
    lines:            3;
    spacing:          1em;
    padding:          0.5em;
    dynamic:          true;
    fixed-height:     false;
    fixed-columns:    true;
    scrollbar:        false;
    background-color: transparent;
    text-color:       @main-fg;
}

element {
    orientation:      vertical;
    border-radius:    ${ELEM_BORDER}px;
    padding:          0.8em 0.4em;
    background-color: transparent;
    text-color:       @main-fg;
    cursor:           pointer;
}

element normal normal {
    background-color: transparent;
    text-color:       @main-fg;
}

element selected normal {
    background-color: @select-bg;
    text-color:       @main-fg;
    border-radius:    ${ELEM_BORDER}px;
}

element-icon {
    size:             5em;
    background-color: transparent;
    cursor:           inherit;
}

element-text {
    horizontal-align: 0.5;
    vertical-align:   0.5;
    background-color: transparent;
    text-color:       inherit;
    padding:          0.3em 0 0 0;
}
RASI

rofi -show drun \
     -show-icons \
     -icon-theme Fluent \
     -drun-display-format "{name}" \
     -font "JetBrainsMono Nerd Font 10" \
     -theme /tmp/hyde-launcher.rasi
