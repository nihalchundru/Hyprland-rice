import QtQuick
import Quickshell
import Quickshell.Io

// Spawns `cava` in raw ASCII output mode and exposes the current frame as a
// list of values normalized to 0..1 in `values`.
//
// cava writes one frame per line, formatted as `v0;v1;v2;...;` where each `v`
// is an integer in 0..ascii_max_range (see cava.ini). SplitParser hands us one
// complete line per read, so parsing is a plain split on ";".
//
// NOTE: QtObject has no default property, so Process/Timer are held in named
// properties instead of being declared as bare children.
QtObject {
    id: root

    // Must match `ascii_max_range` in cava.ini.
    property int maxValue: 1000
    // Extra gain applied on top of cava's own autosens output.
    property real gain: 1.0
    // true while the cava process is alive.
    readonly property bool active: process.running
    // Human readable state for debugging / UI hints.
    property string status: "starting"

    // Latest frame: raw integers as printed by cava.
    property var rawValues: []
    // Latest frame: normalized 0..1 values used for rendering.
    property var values: []

    readonly property string configPath: Quickshell.shellPath("cava.ini")

    function applyFrame(line) {
        if (!line)
            return;

        const parts = line.split(";");
        const raw = [];
        const out = [];

        for (let i = 0; i < parts.length; i++) {
            if (parts[i] === "")
                continue; // cava appends a trailing ";" -> empty final field
            let v = Number(parts[i]);
            if (!isFinite(v))
                v = 0;
            raw.push(v);

            let n = (v / root.maxValue) * root.gain;
            n = n > 1 ? 1 : n < 0 ? 0 : n;
            out.push(n);
        }

        if (out.length === 0)
            return;

        root.rawValues = raw;
        root.values = out;
        root.status = "running";
    }

    property Process process: Process {
        id: cavaProcess
        running: true
        command: ["cava", "-p", root.configPath]

        stdout: SplitParser {
            onRead: (line) => root.applyFrame(line)
        }

        // If cava dies (audio device change, missing binary, ...) retry with a
        // small exponential backoff instead of hammering it in a tight loop.
        onExited: (exitCode, exitStatus) => {
            root.status = exitCode === 0 ? "stopped" : "cava exited (" + exitCode + ")";
            root.retryTimer.interval = Math.min(root.retryTimer.interval * 2, 10000);
            root.retryTimer.restart();
        }
        onRunningChanged: {
            if (running) {
                root.retryTimer.interval = 1000;
                root.status = "running";
            }
        }
    }

    property Timer retryTimer: Timer {
        id: retryTimer
        interval: 1000
        repeat: false
        onTriggered: root.process.running = true
    }
}
