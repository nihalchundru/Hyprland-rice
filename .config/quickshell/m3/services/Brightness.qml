pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Needs brightnessctl. available=false on machines without a backlight (VMs, desktops).
Singleton {
    id: root
    property bool available: false
    property real value: 0   // 0..1

    function refresh() { if (!get.running) get.running = true }
    function set(v) {
        setp.command = ["brightnessctl", "set", Math.round(Math.max(0.01, Math.min(1, v)) * 100) + "%"]
        setp.running = true
    }

    Process {
        id: get
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(",")
                if (p.length >= 5) { root.available = true; root.value = parseFloat(p[3]) / 100 }
                else root.available = false
            }
        }
        onExited: code => { if (code !== 0) root.available = false }
    }
    Process { id: setp; onExited: root.refresh() }
    Timer { interval: 4000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refresh() }
    readonly property string icon: value < 0.34 ? "brightness_low" : value < 0.67 ? "brightness_medium" : "brightness_high"
}
