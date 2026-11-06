import QtQuick
import Quickshell
import Quickshell.Io

// Top-Right: 2x2 Circular Resource Gauges for lockscreen2
Rectangle {
    id: root

    property real cpuVal: 0.32
    property real tempVal: 0.45
    property real ramVal: 0.54
    property real diskVal: 0.62

    Process {
        id: statProc
        command: ["sh", "-c", "cpu=$(awk '/^cpu / {print int(($2+$4)*100/($2+$4+$5))}' /proc/stat 2>/dev/null || echo 25); temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 45000); ram=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {print int(100*(t-a)/t)}' /proc/meminfo 2>/dev/null || echo 40); disk=$(df / --output=pcent 2>/dev/null | tail -1 | tr -d ' %' || echo 50); echo \"$cpu|$((temp/1000))|$ram|$disk\""]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s.includes("|")) {
                    const p = s.split("|");
                    const c = parseFloat(p[0]) || 0;
                    const t = parseFloat(p[1]) || 0;
                    const r = parseFloat(p[2]) || 0;
                    const d = parseFloat(p[3]) || 0;

                    root.cpuVal = Math.max(0, Math.min(1.0, c / 100));
                    root.tempVal = Math.max(0, Math.min(1.0, t / 100));
                    root.ramVal = Math.max(0, Math.min(1.0, r / 100));
                    root.diskVal = Math.max(0, Math.min(1.0, d / 100));
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: statProc.running = true
    }

    implicitWidth: 210
    implicitHeight: 200
    radius: 18
    color: Colors.cardBg
    border.width: 1
    border.color: Colors.cardBorder

    Grid {
        anchors.centerIn: parent
        columns: 2
        spacing: 12

        CircularGauge {
            value: root.cpuVal
            iconType: "cpu"
        }

        CircularGauge {
            value: root.tempVal
            iconType: "temp"
            gaugeColor: root.tempVal > 0.8 ? Colors.red : Colors.accent
        }

        CircularGauge {
            value: root.ramVal
            iconType: "ram"
        }

        CircularGauge {
            value: root.diskVal
            iconType: "disk"
        }
    }
}
