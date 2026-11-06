pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Runs cava (raw ASCII output, 64 bars, 60 fps) only while a Visualizer widget exists.
// Input backend: cavaMethod in config.json ("pulse" works with pipewire-pulse; use "pipewire" if your cava supports it).
Singleton {
    id: root
    property var values: []
    property bool failed: false
    readonly property bool wanted: M3Config.widgetsEnabled && Widgets.list.some(w => w.type === "visualizer")
    readonly property bool running: proc.running
    readonly property string script: 'f="${XDG_RUNTIME_DIR:-/tmp}/m3-cava.conf"; printf "%s\\n" "[general]" "bars = 64" "framerate = 60" "[input]" "method = ' + M3Config.cavaMethod + '" "source = auto" "[output]" "method = raw" "raw_target = /dev/stdout" "data_format = ascii" "ascii_max_range = 100" "bar_delimiter = 59" "frame_delimiter = 10" "[smoothing]" "noise_reduction = 60" > "$f"; exec cava -p "$f"'

    function restart() { failed = false; proc.running = false; proc.running = true }

    Process {
        id: proc
        command: ["sh", "-c", root.script]
        running: root.wanted
        onRunningChanged: if (running) root.failed = false
        onExited: code => { if (code !== 0 && root.wanted) root.failed = true; root.values = [] }
        stdout: SplitParser {
            onRead: data => {
                const out = []
                for (const p of data.split(";")) { if (p === "") continue; out.push(Math.min(1, (parseInt(p) || 0) / 100)) }
                root.values = out
            }
        }
    }
}
