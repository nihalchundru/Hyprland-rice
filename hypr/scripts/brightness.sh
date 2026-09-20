#!/usr/bin/env bash
# brightness.sh --inc / --dec

case "$1" in
    --inc)
        brightnessctl set 5%+ 2>/dev/null || true
        ;;
    --dec)
        brightnessctl set 5%- 2>/dev/null || true
        ;;
esac

BRI=$(brightnessctl get 2>/dev/null || echo 1)
MAX=$(brightnessctl max 2>/dev/null || echo 1)
PCT=$(python3 -c "print(round($BRI/$MAX*100))" 2>/dev/null || echo 50)
qs ipc -c osd call osd "showBrightness(\"${PCT}\")" 2>/dev/null || true
