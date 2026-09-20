#!/usr/bin/env bash
# update-ags-theme.sh — updates AGS colors and restarts
THEME="${1:-$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)}"
source ~/.config/hypr/themes/themes.sh "$THEME"

[ -z "$BG" ] && echo "ERROR: themes.sh failed" >&2 && exit 1

CORNERS=$(cat ~/.config/hypr/themes/corner-style 2>/dev/null || echo "rounded")
case "$CORNERS" in
    sharp)   BR="0px"  ;;
    rounded) BR="12px" ;;
esac

# Update colors.js
cat > ~/.config/ags/colors.js << EOF
export const colors = {
    bg:      "${BG}",
    bg2:     "${BG2}",
    surface: "${SURFACE}",
    surface2:"${SURFACE2}",
    text:    "${TEXT}",
    sub:     "${SUB}",
    accent:  "${ACCENT}",
    accent2: "${ACCENT2}",
    green:   "${GREEN}",
    red:     "${RED}",
    yellow:  "${YELLOW}",
    teal:    "${TEAL}",
};
EOF

# Update style.css
cat > ~/.config/ags/style.css << EOF
* { all: unset; font-family: "JetBrainsMono Nerd Font"; }

.sidebar-window { background: transparent; border: none; }

.sidebar { background-color: ${BG}; border-left: 2px solid ${ACCENT}; padding: 16px; color: ${TEXT}; min-width: 260px; }
.sidebar-header { font-size: 14px; font-weight: bold; color: ${ACCENT}; padding-bottom: 8px; border-bottom: 1px solid ${SURFACE2}; }
.clock-box { padding: 8px 0; }
.clock-time { font-size: 42px; font-weight: bold; color: ${ACCENT}; }
.clock-date { font-size: 13px; color: ${SUB}; }
.section { background-color: ${SURFACE}; border-radius: ${BR}; padding: 12px; }
.section-title { font-size: 10px; font-weight: bold; color: ${SUB}; margin-bottom: 8px; }
.stat-row { margin-bottom: 6px; }
.stat-label { font-size: 11px; color: ${SUB}; }
.stat-value { font-size: 10px; color: ${SUB}; }
.stat-bar { background-color: ${SURFACE2}; border-radius: 6px; min-height: 6px; }
.stat-fill { border-radius: 6px; min-height: 6px; }
.stat-fill-cpu  { background-color: ${TEAL}; }
.stat-fill-ram  { background-color: ${ACCENT}; }
.stat-fill-disk { background-color: ${ACCENT2}; }
.media-title  { font-size: 12px; font-weight: bold; color: ${TEXT}; }
.media-artist { font-size: 11px; color: ${SUB}; }
.media-btn { background-color: ${SURFACE2}; border-radius: ${BR}; padding: 4px 12px; color: ${TEXT}; font-size: 14px; }
.volume-slider slider { background-color: ${ACCENT}; border-radius: 6px; min-height: 6px; min-width: 6px; }
.volume-slider trough { background-color: ${SURFACE2}; border-radius: 6px; min-height: 6px; }
.theme-btn        { background-color: ${SURFACE}; border-radius: ${BR}; padding: 4px 10px; color: ${TEXT}; font-size: 10px; margin: 2px; }
.theme-btn-active { background-color: ${ACCENT}; color: ${BG}; border-radius: ${BR}; padding: 4px 10px; font-size: 10px; margin: 2px; }
.action-btn { background-color: ${SURFACE}; border-radius: ${BR}; padding: 8px 10px; color: ${TEXT}; font-size: 16px; margin: 2px; }
EOF

# Restart AGS
pkill ags 2>/dev/null || true
sleep 0.5
ags &
echo "AGS restarted with theme: $THEME"
