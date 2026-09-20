#!/usr/bin/env bash
pkill waybar 2>/dev/null || true
sleep 0.2
waybar &
