import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower

// CPU / RAM / Battery as three separate 6-sided cookie chips.
// /proc is polled via FileView reload(); battery comes from UPower
// (chip hides itself when there is no battery).
Row {
    id: root

    property real chipSize: 120
    property string iconsDir: ""
    property color chipColor: "#2b2930"
    property color textColor: "#e6e0e9"
    property color subColor: "#938f99"
    property color iconColor: "#1d1b20"

    spacing: chipSize * 0.16

    property real cpu: 0        // 0..1
    property real ram: 0        // 0..1
    property real battery: UPower.displayDevice ? UPower.displayDevice.percentage : 0

    StatChip {
        width: root.chipSize
        height: width
        iconSource: root.iconsDir + "cpu.svg"
        iconColor: root.iconColor
        value: Math.round(root.cpu * 100) + "%"
        label: "CPU"
        chipColor: root.chipColor
        textColor: root.textColor
        subColor: root.subColor
    }

    StatChip {
        width: root.chipSize
        height: width
        iconSource: root.iconsDir + "ram.svg"
        iconColor: root.iconColor
        value: Math.round(root.ram * 100) + "%"
        label: "RAM"
        chipColor: root.chipColor
        textColor: root.textColor
        subColor: root.subColor
    }

    StatChip {
        width: root.chipSize
        height: width
        visible: root.battery > 0
        iconSource: root.iconsDir + "battery.svg"
        iconColor: root.iconColor
        value: Math.round(root.battery * 100) + "%"
        label: "BATTERY"
        chipColor: root.chipColor
        textColor: root.textColor
        subColor: root.subColor
    }

    // ---- /proc polling -------------------------------------------------
    property int prevIdle: 0
    property int prevTotal: 0

    function parseStat() {
        var line = statView.text().split("\n", 1)[0]
        var f = line.trim().split(/\s+/)
        // cpu user nice system idle iowait irq softirq steal ...
        if (f.length < 8) return
        var idle = Number(f[4]) + Number(f[5])
        var total = 0
        for (var i = 1; i <= 8; i++) total += Number(f[i])
        var dt = total - root.prevTotal
        var di = idle - root.prevIdle
        // first sample only sets the baseline; no delta to measure yet
        if (root.prevTotal > 0 && dt > 0) root.cpu = 1 - di / dt
        root.prevTotal = total
        root.prevIdle = idle
    }

    function parseMem() {
        var t = memView.text()
        var totM = t.match(/MemTotal:\s+(\d+)/)
        var avM = t.match(/MemAvailable:\s+(\d+)/)
        if (!totM || !avM) return
        var tot = Number(totM[1]), av = Number(avM[1])
        if (tot > 0) root.ram = 1 - av / tot
    }

    FileView {
        id: statView
        path: "/proc/stat"
        onLoaded: root.parseStat()
    }

    FileView {
        id: memView
        path: "/proc/meminfo"
        onLoaded: root.parseMem()
    }

    Timer {
        interval: 2000
        triggeredOnStart: true
        running: root.visible
        repeat: true
        onTriggered: {
            statView.reload()
            memView.reload()
        }
    }
}
