#!/usr/bin/env bash
# write-colors.sh — always run in bash, sources themes.sh properly
# Usage: bash ~/.config/hypr/scripts/write-colors.sh [theme]

THEME="${1:-$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)}"

# Source themes in bash (not fish)
# Dynamic themes — source override files instead of themes.sh
if [ "${THEME}" = "iris" ] && [ -f ~/.config/hypr/themes/iris-override.sh ]; then
    source ~/.config/hypr/themes/iris-override.sh
elif [ "${THEME}" = "matugen" ] && [ -f ~/.config/hypr/themes/matugen-override.sh ]; then
    source ~/.config/hypr/themes/matugen-override.sh
elif [ "${THEME}" != "iris" ] && [ "${THEME}" != "matugen" ]; then
    source ~/.config/hypr/themes/themes.sh "$THEME"
fi

# Verify vars loaded
if [ -z "$BG" ] || [ -z "$ACCENT" ]; then
    echo "ERROR: Theme vars not loaded for $THEME" >&2
    exit 1
fi

# ── colors.rasi ───────────────────────────────────────────────────────────────
cat > ~/.config/rofi/colors.rasi << EOF
* {
    background:               ${BG};
    on-background:            ${TEXT};
    surface:                  ${SURFACE};
    on-surface:               ${TEXT};
    on-surface-variant:       ${SUB};
    primary:                  ${ACCENT};
    primary-fixed:            ${ACCENT};
    primary-fixed-dim:        ${ACCENT2};
    on-primary:               ${BG};
    on-primary-fixed:         ${BG};
    on-primary-fixed-variant: ${SURFACE};
    primary-container:        ${SURFACE};
    on-primary-container:     ${TEXT};
    secondary:                ${ACCENT2};
    on-secondary:             ${BG};
    secondary-container:      ${SURFACE};
    on-secondary-container:   ${TEXT};
    tertiary:                 ${TEAL};
    on-tertiary:              ${BG};
    tertiary-container:       ${SURFACE};
    on-tertiary-container:    ${TEXT};
    error:                    ${RED};
    on-error:                 ${BG};
    error-container:          ${SURFACE2};
    on-error-container:       ${RED};
    surface-dim:              ${BG2};
    surface-bright:           ${SURFACE2};
    surface-container:        ${BG};
    surface-container-high:   ${SURFACE};
    surface-container-highest:${SURFACE2};
    outline:                  ${SUB};
    outline-variant:          ${SURFACE2};
    inverse-surface:          ${TEXT};
    inverse-on-surface:       ${BG};
    inverse-primary:          ${BG};
    shadow:                   #000000;
    scrim:                    #000000;
}
EOF

# ── waybar theme.css ──────────────────────────────────────────────────────────
cat > ~/.config/waybar/theme.css << EOF
@define-color bar-bg ${BAR_BG};
@define-color main-bg ${MAIN_BG};
@define-color main-fg ${MAIN_FG};
@define-color wb-act-bg ${WB_ACT_BG};
@define-color wb-act-fg ${WB_ACT_FG};
@define-color wb-hvr-bg ${WB_HVR_BG};
@define-color wb-hvr-fg ${WB_HVR_FG};
EOF

# ── kitty theme.conf ──────────────────────────────────────────────────────────
cat > ~/.config/kitty/theme.conf << EOF
foreground              ${TEXT}
background              ${BG}
selection_foreground    ${BG}
selection_background    ${ACCENT}
cursor                  ${ACCENT}
cursor_text_color       ${BG}
url_color               ${ACCENT2}
active_border_color     ${ACCENT}
inactive_border_color   ${SURFACE}
bell_border_color       ${RED}
active_tab_foreground   ${BG}
active_tab_background   ${ACCENT}
inactive_tab_foreground ${TEXT}
inactive_tab_background ${SURFACE}
tab_bar_background      ${BG2}
color0  ${BG2}
color8  ${SURFACE}
color1  ${RED}
color9  ${RED}
color2  ${GREEN}
color10 ${GREEN}
color3  ${YELLOW}
color11 ${YELLOW}
color4  ${ACCENT2}
color12 ${ACCENT2}
color5  ${ACCENT}
color13 ${ACCENT}
color6  ${TEAL}
color14 ${TEAL}
color7  ${SUB}
color15 ${TEXT}
EOF

# ── eww.scss ──────────────────────────────────────────────────────────────────
cat > ~/.config/eww/eww.scss << EOF
* { all: unset; font-family: "JetBrainsMono Nerd Font"; }

.sidebar {
    background-color: ${BG};
    border: 2px solid ${ACCENT};
    border-radius: 16px;
    padding: 16px;
    color: ${TEXT};
}
.sidebar-header { font-size: 14px; font-weight: bold; color: ${ACCENT}; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid ${SURFACE2}; }
.clock-time { font-size: 42px; font-weight: bold; color: ${ACCENT}; }
.clock-date { font-size: 13px; color: ${SUB}; margin-bottom: 16px; }
.section { background-color: ${SURFACE}; border-radius: 12px; padding: 12px; margin-bottom: 8px; }
.section-title { font-size: 11px; font-weight: bold; color: ${SUB}; margin-bottom: 8px; }
.stat-label { font-size: 11px; color: ${SUB}; margin-bottom: 2px; }
.stat-bar { background-color: ${SURFACE2}; border-radius: 6px; min-height: 6px; margin-bottom: 6px; }
.stat-fill-cpu  { background-color: ${TEAL};    border-radius: 6px; min-height: 6px; }
.stat-fill-ram  { background-color: ${ACCENT};  border-radius: 6px; min-height: 6px; }
.stat-fill-disk { background-color: ${ACCENT2}; border-radius: 6px; min-height: 6px; }
.stat-value { font-size: 10px; color: ${SUB}; }
.media-title { font-size: 12px; font-weight: bold; color: ${TEXT}; }
.media-artist { font-size: 11px; color: ${SUB}; margin-bottom: 8px; }
.media-btn { background-color: ${SURFACE2}; border-radius: 8px; padding: 4px 12px; color: ${TEXT}; font-size: 14px; margin: 0 2px; }
.volume-slider slider { background-color: ${ACCENT}; border-radius: 6px; min-height: 6px; min-width: 6px; }
.volume-slider trough { background-color: ${SURFACE2}; border-radius: 6px; min-height: 6px; }
.theme-btn { background-color: ${SURFACE}; border-radius: 8px; padding: 4px 10px; color: ${TEXT}; font-size: 10px; margin: 2px; }
.theme-btn-active { background-color: ${ACCENT}; color: ${BG}; border-radius: 8px; padding: 4px 10px; font-size: 10px; margin: 2px; }
.action-btn { background-color: ${SURFACE}; border-radius: 10px; padding: 8px 10px; color: ${TEXT}; font-size: 16px; margin: 2px; }
EOF

# ── mako ──────────────────────────────────────────────────────────────────────
cat > ~/.config/mako/config << EOF
background-color=${BG}ee
text-color=${TEXT}
border-color=${ACCENT}
border-radius=10
border-size=1
font=JetBrainsMono Nerd Font 11
padding=12,16
margin=8
width=320
height=100
layer=overlay
anchor=top-right
default-timeout=4000
max-visible=3

[urgency=high]
border-color=${RED}
EOF

echo "Colors written for theme: $THEME"

# ── eww.scss (update colors only, keep structure) ─────────────────────────────
sed -i "s/background-color: #[0-9a-fA-F]\{6\};/background-color: ${BG};/1" ~/.config/eww/eww.scss
sed -i "s/border: 2px solid #[0-9a-fA-F]\{6\};/border: 2px solid ${ACCENT};/" ~/.config/eww/eww.scss
sed -i "s/color: #CDD6F4;$/color: ${TEXT};/g" ~/.config/eww/eww.scss
sed -i "s/color: #CBA6F7/color: ${ACCENT}/g" ~/.config/eww/eww.scss
sed -i "s/color: #6C7086/color: ${SUB}/g" ~/.config/eww/eww.scss
sed -i "s/background-color: #313244/background-color: ${SURFACE}/g" ~/.config/eww/eww.scss
sed -i "s/background-color: #45475A/background-color: ${SURFACE2}/g" ~/.config/eww/eww.scss
sed -i "s/background-color: #94E2D5/background-color: ${TEAL}/g" ~/.config/eww/eww.scss
sed -i "s/background-color: #CBA6F7/background-color: ${ACCENT}/g" ~/.config/eww/eww.scss
sed -i "s/background-color: #89B4FA/background-color: ${ACCENT2}/g" ~/.config/eww/eww.scss
sed -i "s/color: #F38BA8/color: ${RED}/g" ~/.config/eww/eww.scss
eww reload 2>/dev/null || true

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell sidebar colors.json ────────────────────────────────────────────
cat > ~/.config/quickshell/sidebar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── Quickshell topbar colors.json ─────────────────────────────────────────────
cat > ~/.config/quickshell/topbar/colors.json << EOF
{
    "bg":      "${BG}",
    "bg2":     "${BG2}",
    "surface": "${SURFACE}",
    "surface2":"${SURFACE2}",
    "text":    "${TEXT}",
    "sub":     "${SUB}",
    "accent":  "${ACCENT}",
    "accent2": "${ACCENT2}",
    "green":   "${GREEN}",
    "red":     "${RED}",
    "yellow":  "${YELLOW}",
    "teal":    "${TEAL}",
    "orange":  "${ORANGE:-$ACCENT2}",
    "purple":  "${PURPLE:-$ACCENT}",
    "theme":   "${THEME}"
}
EOF

# ── config-adi.rasi colors (adi1090x layout) ─────────────────────────────────
cat > ~/.config/rofi/config-adi.rasi << EOF
/**
 * Adi1090x-style launcher — HyDE ARM themed
 **/

configuration {
    modi:               "drun,run,filebrowser,window";
    show-icons:         true;
    display-drun:       "";
    display-run:        "";
    display-filebrowser:"";
    display-window:     "";
    drun-display-format:"{name}";
    window-format:      "{w} · {c} · {t}";
}

* {
    font:             "JetBrainsMono Nerd Font 10";
    background:       ${BG};
    background-alt:   ${SURFACE};
    foreground:       ${TEXT};
    selected:         ${ACCENT};
    active:           ${ACCENT2};
    urgent:           ${RED};
    background-color: transparent;
    text-color:       @foreground;
}

window {
    transparency:     "real";
    location:         center;
    anchor:           center;
    fullscreen:       false;
    width:            700px;
    enabled:          true;
    border-radius:    20px;
    cursor:           "default";
    background-color: @background;
}

mainbox {
    enabled:          true;
    spacing:          0px;
    background-color: transparent;
    orientation:      vertical;
    children:         ["inputbar", "listbox"];
}

listbox {
    spacing:          20px;
    padding:          20px;
    background-color: transparent;
    orientation:      vertical;
    children:         ["message", "listview"];
}

inputbar {
    enabled:          true;
    spacing:          10px;
    padding:          80px 60px;
    background-color: transparent;
    background-image: url("~/.config/rofi/images/a.png", width);
    text-color:       @foreground;
    orientation:      horizontal;
    children:         ["textbox-prompt-colon", "entry", "dummy", "mode-switcher"];
}

textbox-prompt-colon {
    enabled:          true;
    expand:           false;
    str:              "";
    padding:          12px 15px;
    border-radius:    100%;
    background-color: @background-alt;
    text-color:       inherit;
}

entry {
    enabled:          true;
    expand:           false;
    width:            250px;
    padding:          12px 16px;
    border-radius:    100%;
    background-color: @background-alt;
    text-color:       inherit;
    cursor:           text;
    placeholder:      "Search";
    placeholder-color:inherit;
}

dummy { expand: true; background-color: transparent; }

mode-switcher {
    enabled:          true;
    spacing:          10px;
    background-color: transparent;
    text-color:       @foreground;
}

button {
    width:            45px;
    padding:          12px;
    border-radius:    100%;
    background-color: @background-alt;
    text-color:       inherit;
    cursor:           pointer;
}

button selected { background-color: @selected; text-color: @foreground; }

listview {
    enabled:          true;
    columns:          1;
    lines:            7;
    cycle:            true;
    dynamic:          true;
    scrollbar:        false;
    layout:           vertical;
    reverse:          false;
    fixed-height:     true;
    fixed-columns:    true;
    spacing:          10px;
    background-color: transparent;
    text-color:       @foreground;
    cursor:           "default";
}

element {
    enabled:          true;
    spacing:          10px;
    padding:          4px;
    border-radius:    100%;
    background-color: transparent;
    text-color:       @foreground;
    cursor:           pointer;
}

element normal normal   { background-color: inherit; text-color: inherit; }
element normal urgent   { background-color: @urgent; text-color: @foreground; }
element normal active   { background-color: @active; text-color: @foreground; }
element selected normal { background-color: @selected; text-color: @foreground; }
element selected urgent { background-color: @urgent; text-color: @foreground; }
element selected active { background-color: @urgent; text-color: @foreground; }

element-icon { background-color: transparent; text-color: inherit; size: 32px; cursor: inherit; }
element-text { background-color: transparent; text-color: inherit; cursor: inherit; vertical-align: 0.5; horizontal-align: 0.0; }

message { background-color: transparent; }
textbox { padding: 12px; border-radius: 100%; background-color: @background-alt; text-color: @foreground; vertical-align: 0.5; horizontal-align: 0.0; }
error-message { padding: 12px; border-radius: 20px; background-color: @background; text-color: @foreground; }
EOF

# ── config-grid.rasi colors (adi1090x grid layout) ───────────────────────────
cat > ~/.config/rofi/config-grid.rasi << EOF
/**
 * Adi1090x grid launcher — HyDE ARM themed
 **/

configuration {
    modi:                "drun,run,filebrowser,window";
    show-icons:           true;
    display-drun:         "APPS";
    display-run:          "RUN";
    display-filebrowser:  "FILES";
    display-window:       "WINDOWS";
    drun-display-format:  "{name}";
    window-format:        "{w} · {c}";
}

* {
    font:             "JetBrainsMono Nerd Font 10";
    background:       ${BG};
    background-alt:   ${SURFACE};
    foreground:       ${TEXT};
    selected:         ${ACCENT};
    active:           ${ACCENT2};
    urgent:           ${RED};
    background-color: transparent;
    text-color:       @foreground;
}

window {
    transparency:     "real";
    location:         center;
    anchor:           center;
    fullscreen:       false;
    width:            1000px;
    enabled:          true;
    border-radius:    15px;
    cursor:           "default";
    background-color: @background;
}

mainbox {
    enabled:          true;
    spacing:          0px;
    background-color: transparent;
    orientation:      vertical;
    children:         ["inputbar", "listbox"];
}

listbox {
    spacing:          20px;
    padding:          20px;
    background-color: transparent;
    orientation:      vertical;
    children:         ["message", "listview"];
}

inputbar {
    enabled:          true;
    spacing:          10px;
    padding:          100px 60px;
    background-color: transparent;
    background-image: url("~/.config/rofi/images/f.png", width);
    text-color:       @foreground;
    orientation:      horizontal;
    children:         ["textbox-prompt-colon", "entry", "dummy", "mode-switcher"];
}

textbox-prompt-colon {
    enabled:          true;
    expand:           false;
    str:              "";
    padding:          12px 15px;
    border-radius:    100%;
    background-color: @background-alt;
    text-color:       inherit;
}

entry {
    enabled:          true;
    expand:           false;
    width:            300px;
    padding:          12px 16px;
    border-radius:    100%;
    background-color: @background-alt;
    text-color:       inherit;
    cursor:           text;
    placeholder:      "Search";
    placeholder-color:inherit;
}

dummy { expand: true; background-color: transparent; }

mode-switcher {
    enabled:          true;
    spacing:          10px;
    background-color: transparent;
    text-color:       @foreground;
}

button {
    width:            80px;
    padding:          12px;
    border-radius:    100%;
    background-color: @background-alt;
    text-color:       inherit;
    cursor:           pointer;
}

button selected { background-color: @selected; text-color: @foreground; }

listview {
    enabled:          true;
    columns:          6;
    lines:            3;
    cycle:            true;
    dynamic:          true;
    scrollbar:        false;
    layout:           vertical;
    reverse:          false;
    fixed-height:     true;
    fixed-columns:    true;
    spacing:          10px;
    background-color: transparent;
    text-color:       @foreground;
    cursor:           "default";
}

element {
    enabled:          true;
    spacing:          10px;
    padding:          10px;
    border-radius:    15px;
    background-color: transparent;
    text-color:       @foreground;
    cursor:           pointer;
    orientation:      vertical;
}

element normal normal   { background-color: inherit; text-color: inherit; }
element normal urgent   { background-color: @urgent; text-color: @foreground; }
element normal active   { background-color: @active; text-color: @foreground; }
element selected normal { background-color: @selected; text-color: @foreground; }
element selected urgent { background-color: @urgent; text-color: @foreground; }
element selected active { background-color: @urgent; text-color: @foreground; }

element-icon {
    background-color: transparent;
    text-color:       inherit;
    size:             64px;
    cursor:           inherit;
}

element-text {
    background-color: transparent;
    text-color:       inherit;
    cursor:           inherit;
    vertical-align:   0.5;
    horizontal-align: 0.5;
}

message { background-color: transparent; }

textbox {
    padding:          15px;
    border-radius:    15px;
    background-color: @background-alt;
    text-color:       @foreground;
    vertical-align:   0.5;
    horizontal-align: 0.0;
}

error-message {
    padding:          15px;
    border-radius:    15px;
    background-color: @background;
    text-color:       @foreground;
}
EOF

# ── config-simple-grid.rasi colors ───────────────────────────────────────────
cat > ~/.config/rofi/config-simple-grid.rasi << EOF
/**
 * Adi1090x simple grid launcher — HyDE ARM themed
 **/

configuration {
    modi:           "drun";
    show-icons:     true;
    display-drun:   " Applications";
    drun-display-format: "{name}";
}

* {
    font:             "JetBrainsMono Nerd Font 10";
    background:       ${BG};
    background-alt:   ${SURFACE};
    foreground:       ${TEXT};
    selected:         ${ACCENT};
    background-color: transparent;
    text-color:       @foreground;
}

window {
    transparency:     "real";
    location:         center;
    anchor:           center;
    fullscreen:       false;
    width:            450px;
    enabled:          true;
    margin:           0px;
    padding:          0px;
    border:           1px solid;
    border-radius:    16px;
    border-color:     @selected;
    background-color: @background;
    cursor:           "default";
}

mainbox {
    enabled:          true;
    spacing:          0px;
    margin:           0px;
    padding:          0px;
    border:           0px solid;
    border-radius:    0px;
    background-color: transparent;
    children:         ["listview", "entry"];
}

entry {
    enabled:          true;
    expand:           false;
    padding:          20px 0px;
    background-color: @selected;
    text-color:       @background;
    cursor:           text;
    placeholder:      "Search...";
    placeholder-color:inherit;
    vertical-align:   0.5;
    horizontal-align: 0.5;
}

listview {
    enabled:          true;
    columns:          3;
    lines:            3;
    cycle:            true;
    dynamic:          true;
    scrollbar:        false;
    layout:           vertical;
    reverse:          false;
    fixed-height:     true;
    fixed-columns:    true;
    spacing:          0px;
    margin:           0px;
    padding:          20px;
    border:           0px solid;
    border-radius:    0px;
    background-color: transparent;
    text-color:       @foreground;
    cursor:           "default";
}

scrollbar {
    handle-width:     5px;
    handle-color:     @selected;
    border-radius:    0px;
    background-color: @background-alt;
}

element {
    enabled:          true;
    spacing:          15px;
    margin:           0px;
    padding:          20px 10px;
    border:           0px solid;
    border-radius:    12px;
    background-color: transparent;
    text-color:       @foreground;
    orientation:      vertical;
    cursor:           pointer;
}

element normal normal   { background-color: @background;     text-color: @foreground; }
element selected normal { background-color: @background-alt; text-color: @foreground; }

element-icon {
    background-color: transparent;
    text-color:       inherit;
    size:             64px;
    cursor:           inherit;
}

element-text {
    background-color: transparent;
    text-color:       inherit;
    cursor:           inherit;
    vertical-align:   0.5;
    horizontal-align: 0.5;
}

error-message {
    padding:          15px;
    border:           0px solid;
    border-radius:    0px;
    background-color: @background;
    text-color:       @foreground;
}

textbox {
    background-color: @background;
    text-color:       @foreground;
    vertical-align:   0.5;
    horizontal-align: 0.0;
}
EOF

# ── powermenu.rasi colors ─────────────────────────────────────────────────────
cat > ~/.config/rofi/powermenu.rasi << EOF
/**
 * Adi1090x powermenu — HyDE ARM themed
 **/
configuration { show-icons: false; }
* {
    font:             "JetBrainsMono Nerd Font 10";
    background:       ${BG};
    background-alt:   ${SURFACE};
    foreground:       ${TEXT};
    selected:         ${ACCENT};
    active:           ${ACCENT2};
    urgent:           ${RED};
}
window {
    transparency:     "real";
    location:         center;
    anchor:           center;
    fullscreen:       false;
    width:            1000px;
    padding:          0px;
    border:           0px solid;
    border-radius:    24px;
    border-color:     @selected;
    cursor:           "default";
    background-color: @background;
}
mainbox { background-color: transparent; orientation: horizontal; children: ["imagebox", "listview"]; }
imagebox {
    spacing:           20px;
    padding:           20px;
    background-color:  transparent;
    background-image:  url("~/.config/rofi/images/d.png", height);
    children:          ["inputbar", "dummy", "message"];
}
userimage {
    margin:            0px 0px;
    border:            10px;
    border-radius:     10px;
    border-color:      @background-alt;
    background-color:  transparent;
    background-image:  url("~/.config/rofi/images/d.png", height);
}
inputbar { padding: 15px; border-radius: 100%; background-color: @urgent; text-color: @foreground; children: ["dummy", "prompt", "dummy"]; }
dummy { background-color: transparent; }
prompt { background-color: inherit; text-color: inherit; }
message { enabled: true; margin: 0px; padding: 15px; border-radius: 100%; background-color: @active; text-color: @foreground; }
textbox { background-color: inherit; text-color: inherit; vertical-align: 0.5; horizontal-align: 0.5; }
listview {
    enabled: true; columns: 3; lines: 2; cycle: true; dynamic: true; scrollbar: false;
    layout: vertical; reverse: false; fixed-height: true; fixed-columns: true;
    spacing: 20px; margin: 20px; background-color: transparent; cursor: "default";
}
element { enabled: true; padding: 40px 10px; border-radius: 100%; background-color: @background-alt; text-color: @foreground; cursor: pointer; }
element-text { font: "JetBrainsMono Nerd Font 24"; background-color: transparent; text-color: inherit; cursor: inherit; vertical-align: 0.5; horizontal-align: 0.5; }
element selected normal { background-color: @selected; text-color: @background; }
EOF

# ── applet.rasi colors ────────────────────────────────────────────────────────
cat > ~/.config/rofi/applet.rasi << EOF
/**
 * Adi1090x applet launcher — HyDE ARM themed
 **/
configuration { show-icons: false; }
* {
    font:             "JetBrainsMono Nerd Font 10";
    background:       ${BG};
    background-alt:   ${SURFACE};
    foreground:       ${TEXT};
    selected:         ${ACCENT};
    active:           ${ACCENT2};
    urgent:           ${RED};
}
window {
    transparency:     "real";
    location:         center;
    anchor:           center;
    fullscreen:       false;
    width:            400px;
    margin:           0px;
    padding:          0px;
    border:           1px solid;
    border-radius:    12px;
    border-color:     @selected;
    cursor:           "default";
    background-color: @background;
}
mainbox { enabled: true; spacing: 10px; margin: 0px; padding: 20px; background-color: transparent; children: ["inputbar", "message", "listview"]; }
inputbar {
    enabled: true; spacing: 10px; padding: 0px; border: 0px; border-radius: 0px;
    background-color: transparent; text-color: @foreground; children: ["textbox-prompt-colon", "prompt"];
}
textbox-prompt-colon { enabled: true; expand: false; str: ""; padding: 10px 13px; border-radius: 12px; background-color: @urgent; text-color: @background; }
prompt { enabled: true; padding: 10px; border-radius: 12px; background-color: @active; text-color: @background; }
message { enabled: true; margin: 0px; padding: 10px; border: 0px solid; border-radius: 12px; background-color: @background-alt; text-color: @foreground; }
textbox { background-color: inherit; text-color: inherit; vertical-align: 0.5; horizontal-align: 0.0; }
listview { enabled: true; columns: 1; lines: 6; cycle: true; scrollbar: false; layout: vertical; spacing: 5px; background-color: transparent; cursor: "default"; }
element { enabled: true; padding: 10px; border: 0px solid; border-radius: 12px; background-color: transparent; text-color: @foreground; cursor: pointer; }
element-text { background-color: transparent; text-color: inherit; cursor: inherit; vertical-align: 0.5; horizontal-align: 0.0; }
element normal normal, element alternate normal { background-color: @background; text-color: @foreground; }
element normal urgent, element alternate urgent, element selected active { background-color: @urgent; text-color: @background; }
element normal active, element alternate active, element selected urgent { background-color: @active; text-color: @background; }
element selected normal { background-color: @selected; text-color: @background; }
EOF

# ── powermenu-sidebar.rasi colors ────────────────────────────────────────────
cat > ~/.config/rofi/powermenu-sidebar.rasi << EOF
/**
 * Adi1090x powermenu (sidebar style) — HyDE ARM themed
 **/
configuration { show-icons: false; }
* {
    font:             "JetBrainsMono Nerd Font 10";
    background:       ${BG}; background-alt: ${SURFACE}; foreground: ${TEXT};
    selected:         ${ACCENT}; active: ${ACCENT2}; urgent: ${RED};
}
window {
    transparency: "real"; location: center; anchor: center; fullscreen: false;
    width: 1000px; padding: 0px; border: 0px solid; border-radius: 24px;
    border-color: @selected; cursor: "default"; background-color: @background;
}
mainbox { background-color: transparent; orientation: horizontal; children: ["imagebox", "listview"]; }
imagebox {
    spacing: 20px; padding: 20px; background-color: transparent;
    background-image: url("~/.config/rofi/images/d.png", height);
    children: ["inputbar", "dummy", "message"];
}
userimage {
    margin: 0px 0px; border: 10px; border-radius: 10px; border-color: @background-alt;
    background-color: transparent; background-image: url("~/.config/rofi/images/d.png", height);
}
inputbar { padding: 15px; border-radius: 100%; background-color: @urgent; text-color: @foreground; children: ["dummy", "prompt", "dummy"]; }
dummy { background-color: transparent; }
prompt { background-color: inherit; text-color: inherit; }
message { enabled: true; margin: 0px; padding: 15px; border-radius: 100%; background-color: @active; text-color: @foreground; }
textbox { background-color: inherit; text-color: inherit; vertical-align: 0.5; horizontal-align: 0.5; }
listview {
    enabled: true; columns: 3; lines: 2; cycle: true; dynamic: true; scrollbar: false;
    layout: vertical; reverse: false; fixed-height: true; fixed-columns: true;
    spacing: 20px; margin: 20px; background-color: transparent; cursor: "default";
}
element { enabled: true; padding: 40px 10px; border-radius: 100%; background-color: @background-alt; text-color: @foreground; cursor: pointer; }
element-text { font: "JetBrainsMono Nerd Font 24"; background-color: transparent; text-color: inherit; cursor: inherit; vertical-align: 0.5; horizontal-align: 0.5; }
element selected normal { background-color: @selected; text-color: @background; }
EOF

# ── powermenu-fullscreen.rasi colors ─────────────────────────────────────────
cat > ~/.config/rofi/powermenu-fullscreen.rasi << EOF
/**
 * Adi1090x powermenu (fullscreen style) — HyDE ARM themed
 **/
configuration { show-icons: false; }
* {
    font:             "JetBrainsMono Nerd Font 10";
    background:       ${BG}; background-alt: ${SURFACE}; foreground: ${TEXT};
    selected:         ${ACCENT}; active: ${ACCENT2}; urgent: ${RED};
    box-spacing:      50px; box-margin: 300px 200px; inputbar-spacing: 0px;
    list-spacing:     30px; general-padding: 20px; element-padding: 80px 10px;
    element-radius:   100%; general-radius: 100%; element-font: "JetBrainsMono Nerd Font 64";
}
window {
    transparency: "real"; location: center; anchor: center; fullscreen: true;
    width: 1366px; enabled: true; margin: 0px; padding: 0px; border: 0px solid;
    border-radius: 0px; border-color: @selected; cursor: "default"; background-color: @background;
}
mainbox {
    enabled: true; spacing: @box-spacing; margin: 0px; padding: @box-margin;
    border: 0px solid; border-radius: 0px; border-color: @selected;
    background-color: transparent; children: ["inputbar", "listview"];
}
inputbar {
    enabled: true; spacing: @inputbar-spacing; margin: 0px; padding: 0px; border: 0px;
    border-radius: 0px; border-color: @selected; background-color: transparent;
    text-color: @foreground; children: ["dummy", "textbox-prompt-colon", "prompt", "dummy"];
}
dummy { background-color: transparent; }
textbox-prompt-colon {
    enabled: true; expand: false; str: "SYSTEM"; padding: @general-padding;
    border-radius: 100% 0px 0px 100%; background-color: @urgent; text-color: @background;
}
prompt { enabled: true; padding: @general-padding; border-radius: 0px 100% 100% 0px; background-color: @active; text-color: @background; }
message {
    enabled: true; margin: 0px; padding: @general-padding; border: 0px solid;
    border-radius: @general-radius; border-color: @selected; background-color: @background-alt; text-color: @foreground;
}
textbox { background-color: inherit; text-color: inherit; vertical-align: 0.5; horizontal-align: 0.5; placeholder-color: @foreground; blink: true; markup: true; }
error-message { padding: @general-padding; border: 0px solid; border-radius: @general-radius; border-color: @selected; background-color: @background; text-color: @foreground; }
listview {
    enabled: true; columns: 5; lines: 1; cycle: true; dynamic: true; scrollbar: false;
    layout: vertical; reverse: false; fixed-height: true; fixed-columns: true;
    spacing: @list-spacing; margin: 0px; padding: 0px; border: 0px solid; border-radius: 0px;
    border-color: @selected; background-color: transparent; text-color: @foreground; cursor: "default";
}
element {
    enabled: true; spacing: 0px; margin: 0px; padding: @element-padding; border: 0px solid;
    border-radius: @element-radius; border-color: @selected; background-color: @background-alt;
    text-color: @foreground; cursor: pointer;
}
element-text { font: @element-font; background-color: transparent; text-color: inherit; cursor: inherit; vertical-align: 0.5; horizontal-align: 0.5; }
element selected normal { background-color: @selected; text-color: @background; }
EOF

# ── Aozora Ink: extra soft rounding + muted borders ───────────────────────────
if [ "${THEME}" = "aozora" ]; then
    hyprctl keyword decoration:rounding 14 2>/dev/null || true
    hyprctl keyword general:border_size 1 2>/dev/null || true
fi

# ── theme.rasi (HyDE color bridge) ───────────────────────────────────────────
cat > ~/.config/rofi/theme.rasi << EOF
* {
    main-bg:   ${BG};
    main-fg:   ${TEXT};
    select-bg: ${ACCENT};
    select-fg: ${BG};
    main-br:   ${ACCENT};
}
EOF

# ── gradient-pill.css — regenerate gradient colors on theme switch ────────────
if [ -f ~/.config/waybar/layouts/gradient-pill.css ]; then
    sed -i "s|linear-gradient(\s*135deg,\s*#[0-9a-fA-F]\{6\} 0%,\s*#[0-9a-fA-F]\{6\} 100%)|linear-gradient(135deg, ${ACCENT} 0%, ${ACCENT2} 100%)|g" \
        ~/.config/waybar/layouts/gradient-pill.css 2>/dev/null || true
    sed -i "s/color:         #[0-9a-fA-F]\{6\};$/color:         ${BG};/" \
        ~/.config/waybar/layouts/gradient-pill.css 2>/dev/null || true
fi

# ── hyprlock extracted_colors.conf ───────────────────────────────────────────
mkdir -p ~/.config/hypr/assets
printf "\$lock_bg = rgb(%s)\n" "${BG#\#}"  > ~/.config/hypr/assets/extracted_colors.conf
printf "\$lock_fg = rgb(%s)\n" "${TEXT#\#}" >> ~/.config/hypr/assets/extracted_colors.conf
printf "\$lock_acc = rgb(%s)\n" "${ACCENT#\#}" >> ~/.config/hypr/assets/extracted_colors.conf

# Copy current wallpaper for hyprlock background
WALL=$(grep -oP '(?<=url\(")[^"]+' ~/.config/rofi/current_wallpaper.rasi 2>/dev/null | head -1)
if [ -n "$WALL" ] && [ -f "$WALL" ]; then
    cp "$WALL" ~/.config/hypr/assets/current_wallpaper.png 2>/dev/null || true
fi

# ── swaync style.css (theme-following) ───────────────────────────────────────
cat > ~/.config/swaync/style.css << EOF
/* HyDE ARM Swaync — theme: ${THEME} */
/* Transparent bg so Hyprland blur shows through */

.control-center {
    background:    rgba(${BG:1:2}, ${BG:3:2}, ${BG:5:2}, 0) !important;
    background-color: transparent !important;
    border:        1px solid rgba($(printf '%d' 0x${ACCENT:1:2}), $(printf '%d' 0x${ACCENT:3:2}), $(printf '%d' 0x${ACCENT:5:2}), 0.4);
    border-radius: 16px;
    color:         ${TEXT};
    box-shadow:    none;
    padding:       8px;
}

.notification-row .notification {
    background-color: rgba($(printf '%d' 0x${SURFACE:1:2}), $(printf '%d' 0x${SURFACE:3:2}), $(printf '%d' 0x${SURFACE:5:2}), 0.6);
    border:        1px solid rgba($(printf '%d' 0x${ACCENT:1:2}), $(printf '%d' 0x${ACCENT:3:2}), $(printf '%d' 0x${ACCENT:5:2}), 0.25);
    border-radius: 12px;
    padding:       12px;
    margin:        4px 0;
    color:         ${TEXT};
    box-shadow:    none;
}

.notification-row .notification .summary {
    font-weight: bold;
    color:       ${TEXT};
    font-size:   13px;
}

.notification-row .notification .body {
    color:     ${SUB};
    font-size: 12px;
}

.notification-row .notification .time {
    color:     ${SUB};
    font-size: 11px;
}

.notification-row .close-button {
    background:    rgba($(printf '%d' 0x${RED:1:2}), $(printf '%d' 0x${RED:3:2}), $(printf '%d' 0x${RED:5:2}), 0.5);
    border-radius: 50%;
    color:         ${TEXT};
    border:        none;
    padding:       2px 6px;
}

button {
    background:    rgba($(printf '%d' 0x${ACCENT:1:2}), $(printf '%d' 0x${ACCENT:3:2}), $(printf '%d' 0x${ACCENT:5:2}), 0.18);
    border:        none;
    border-radius: 10px;
    color:         ${TEXT};
    padding:       6px 14px;
    font-size:     12px;
    transition:    all 0.2s ease;
}

button:hover {
    background: rgba($(printf '%d' 0x${ACCENT:1:2}), $(printf '%d' 0x${ACCENT:3:2}), $(printf '%d' 0x${ACCENT:5:2}), 0.35);
}

.widget-title {
    color:       ${ACCENT};
    font-weight: bold;
    font-size:   14px;
    padding:     6px 10px 4px;
}

.widget-dnd {
    background:    rgba($(printf '%d' 0x${SURFACE:1:2}), $(printf '%d' 0x${SURFACE:3:2}), $(printf '%d' 0x${SURFACE:5:2}), 0.5);
    border-radius: 12px;
    margin:        4px;
    padding:       8px;
    color:         ${TEXT};
}

.widget-mpris {
    background:    rgba($(printf '%d' 0x${SURFACE:1:2}), $(printf '%d' 0x${SURFACE:3:2}), $(printf '%d' 0x${SURFACE:5:2}), 0.5);
    border-radius: 12px;
    margin:        4px;
    padding:       8px;
    color:         ${TEXT};
}

progressbar trough {
    background: rgba($(printf '%d' 0x${SURFACE2:1:2}), $(printf '%d' 0x${SURFACE2:3:2}), $(printf '%d' 0x${SURFACE2:5:2}), 0.5);
    border-radius: 6px;
    min-height: 6px;
}

progressbar progress {
    background: ${ACCENT};
    border-radius: 6px;
    min-height: 6px;
}
EOF

ZEN_PROFILE="$HOME/.config/zen/o5lc5mru.Default (release)"
mkdir -p "$ZEN_PROFILE/chrome"

cat > "$ZEN_PROFILE/chrome/userChrome.css" <<EOF
:root {
    --bg: ${BG};
    --surface: ${SURFACE};
    --surface2: ${SURFACE2};
    --text: ${TEXT};
    --accent: ${ACCENT};
}

#navigator-toolbox {
    background: var(--bg) !important;
}
EOF


# ── Restart Zen to apply userChrome changes ─────────────────────────────
if pgrep -x zen-bin >/dev/null; then
    echo "Restarting Zen to apply theme..."
    
    pkill -x zen-bin
    
    sleep 1.5
    
    zen-browser &
fi

hyprpanel r

# Reload swaync CSS immediately
swaync-client --reload-css 2>/dev/null || true
