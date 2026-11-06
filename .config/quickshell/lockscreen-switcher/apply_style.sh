#!/usr/bin/env bash
# Switch active quickshell lockscreen style
# Usage: ./apply_style.sh [veil|tessera]

STYLE="${1:-veil}"
QS_DIR="$HOME/.config/quickshell"
CONFIG_FILE="$QS_DIR/lockscreen.json"
LINK_TARGET="$QS_DIR/current_lockscreen"

mkdir -p "$QS_DIR"

if [ "$STYLE" = "tessera" ]; then
    SRC_DIR="$QS_DIR/lockscreen2"
elif [ "$STYLE" = "deck" ]; then
    SRC_DIR="$QS_DIR/lockscreen3"
else
    STYLE="veil"
    SRC_DIR="$QS_DIR/lockscreen"
fi

# Update symlink
ln -sfn "$SRC_DIR" "$LINK_TARGET"

# Update config JSON
echo "{\"current_style\": \"$STYLE\"}" > "$CONFIG_FILE"

echo "Switched active lockscreen to: $STYLE ($SRC_DIR)"
