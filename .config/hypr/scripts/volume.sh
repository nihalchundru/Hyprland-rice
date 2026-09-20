#!/usr/bin/env bash
# volume.sh --inc / --dec / --mute

case "$1" in
    --inc)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2*100}')
        qs ipc -c osd call osd "showVolume(\"${VOL}\")" 2>/dev/null || true
        ;;
    --dec)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2*100}')
        qs ipc -c osd call osd "showVolume(\"${VOL}\")" 2>/dev/null || true
        ;;
    --mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED || true)
        if [ "$MUTED" -gt 0 ]; then
            qs ipc -c osd call osd "showMuted()" 2>/dev/null || true
        else
            VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2*100}')
            qs ipc -c osd call osd "showVolume(\"${VOL}\")" 2>/dev/null || true
        fi
        ;;
esac
