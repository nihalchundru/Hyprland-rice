#!/usr/bin/env bash
# Feeds the music visualizer: runs cava and prints one line per frame, "12;34;56;...;"
# (values 0-100). Tries PipeWire first, then PulseAudio.
# Exit codes: 3 = cava is not installed, 4 = cava would not start with either input.
bars="${1:-10}"
command -v cava >/dev/null 2>&1 || exit 3

dir="$HOME/.cache/quickshell/pill"
mkdir -p "$dir"
cfg="$dir/cava.conf"

pid=""
trap '[ -n "$pid" ] && kill "$pid" 2>/dev/null; exit 0' TERM INT HUP

for method in pipewire pulse; do
    cat > "$cfg" <<CFG
[general]
bars = $bars
framerate = 30

[input]
method = $method
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
frame_delimiter = 10

[smoothing]
noise_reduction = 60
CFG
    start=$(date +%s)
    cava -p "$cfg" 2>/dev/null &
    pid=$!
    wait "$pid"
    rc=$?
    pid=""
    # it ran for a while: that was a normal end, not a failure to start
    [ $(( $(date +%s) - start )) -ge 3 ] && exit "$rc"
done
exit 4
