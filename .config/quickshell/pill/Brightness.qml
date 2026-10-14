pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Backlight via brightnessctl. `available` is false when there is no backlight
// device (most desktops / VMs); the slider then shows as disabled.
Singleton {
    id: root

    property bool available: false
    property real value: 0          // 0..1
    property real pending: -1

    function refresh() {
        if (!readProc.running) readProc.running = true;
    }

    function set(v) {
        value = Math.max(0.01, Math.min(1, v));
        pending = value;
    }

    Process {
        id: readProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim().split("\n")[0];
                if (!line) { root.available = false; return; }
                const pct = parseInt(line.split(",")[3]);
                if (isNaN(pct)) { root.available = false; return; }
                root.available = true;
                if (root.pending < 0) root.value = pct / 100;
            }
        }
    }

    Process { id: setProc }

    // throttle writes while dragging
    Timer {
        interval: 70
        repeat: true
        running: root.pending >= 0
        onTriggered: {
            if (setProc.running) return;
            setProc.command = ["brightnessctl", "set", Math.round(root.pending * 100) + "%"];
            setProc.running = true;
            root.pending = -1;
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!readProc.running) readProc.running = true
    }
}
