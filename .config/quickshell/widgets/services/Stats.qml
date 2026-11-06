pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int users: 0
    readonly property int historySize: 60

    // all values are 0..1
    property real cpu: 0
    property real ram: 0
    property real disk: 0
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    property var cpuHistory: []
    property var ramHistory: []

    property real prevTotal: 0
    property real prevIdle: 0

    // restart the CPU delta cleanly after a pause
    onUsersChanged: if (users <= 0) prevTotal = 0

    function poll() {
        statFile.reload();
        memFile.reload();
    }

    function parseStat(t) {
        const v = t.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        if (v.length < 4) return;
        const idle = v[3] + (v[4] ?? 0);                        // idle + iowait
        const total = v.slice(0, 8).reduce((a, b) => a + b, 0);
        if (prevTotal > 0) {
            const dt = total - prevTotal;
            const di = idle - prevIdle;
            if (dt > 0) {
                cpu = Math.max(0, Math.min(1, 1 - di / dt));
                cpuHistory = cpuHistory.concat([cpu]).slice(-historySize);
            }
        }
        prevTotal = total;
        prevIdle = idle;
    }

    function parseMem(t) {
        const get = k => {
            const m = t.match(new RegExp("^" + k + ":\\s+(\\d+)", "m"));
            return m ? Number(m[1]) : 0;
        };
        const total = get("MemTotal");
        const avail = get("MemAvailable");
        if (total <= 0) return;
        ram = 1 - avail / total;
        ramTotalGb = total / 1048576;
        ramUsedGb = (total - avail) / 1048576;
        ramHistory = ramHistory.concat([ram]).slice(-historySize);
    }

    function parseDisk(t) {
        const line = t.trim().split("\n")[1];
        if (!line) return;
        const p = line.trim().split(/\s+/).map(Number);
        if (p.length >= 2 && p[0] + p[1] > 0)
            disk = p[0] / (p[0] + p[1]);
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        onLoaded: root.parseStat(text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root.parseMem(text())
    }

    Process {
        id: dfProc
        command: ["df", "--output=used,avail", "-B1", "/"]
        stdout: StdioCollector { onStreamFinished: root.parseDisk(text) }
    }

    Timer {
        interval: 1500
        repeat: true
        running: root.users > 0
        triggeredOnStart: true
        onTriggered: root.poll()
    }

    Timer {
        interval: 30000
        repeat: true
        running: root.users > 0
        triggeredOnStart: true
        onTriggered: if (!dfProc.running) dfProc.running = true
    }
}