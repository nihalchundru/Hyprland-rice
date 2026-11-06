pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real cpu: 0          // 0..1
    property real mem: 0          // 0..1
    property real memUsedGb: 0
    property real memTotalGb: 0
    property int uptimeSeconds: 0
    readonly property string uptime: {
        const d = Math.floor(uptimeSeconds / 86400), h = Math.floor(uptimeSeconds % 86400 / 3600), m = Math.floor(uptimeSeconds % 3600 / 60)
        return (d > 0 ? d + "d " : "") + h + "h " + m + "m"
    }
    property real _idle: 0
    property real _total: 0

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
            const total = f.slice(0, 8).reduce((a, b) => a + b, 0)
            const idle = f[3] + f[4]
            if (root._total > 0 && total > root._total) root.cpu = 1 - (idle - root._idle) / (total - root._total)
            root._idle = idle; root._total = total
        }
    }
    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const t = text()
            const get = k => parseInt((t.match(new RegExp(k + ":\\s+(\\d+)")) || [0, 0])[1])
            const total = get("MemTotal"), avail = get("MemAvailable")
            root.memTotalGb = total / 1048576
            root.memUsedGb = (total - avail) / 1048576
            root.mem = total > 0 ? (total - avail) / total : 0
        }
    }
    FileView {
        id: up
        path: "/proc/uptime"
        onLoaded: root.uptimeSeconds = Math.floor(parseFloat(text().split(" ")[0]) || 0)
    }
    Timer {
        interval: 2000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: { stat.reload(); meminfo.reload(); up.reload() }
    }
    property real disk: 0   // root filesystem, 0..1
    Process {
        id: dfp
        command: ["df", "-P", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.trim().split("\n")[1]
                if (l) root.disk = (parseInt(l.trim().split(/\s+/)[4]) || 0) / 100
            }
        }
    }
    Timer { interval: 60000; repeat: true; running: true; triggeredOnStart: true; onTriggered: dfp.running = true }
}
