pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi via nmcli.
Singleton {
    id: root

    property bool hasWifi: false
    property bool radioOn: true
    property string device: ""

    // the connected network
    property bool connected: false
    property int signal: 0
    property string ssid: ""
    property string security: ""

    property var networks: []      // other networks: {ssid, signal, security}
    property string busy: ""       // ssid currently being connected
    property string error: ""

    // nmcli -t escapes ':' as '\:'
    function splitTerse(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const ch = line[i];
            if (ch === "\\" && i + 1 < line.length) cur += line[++i];
            else if (ch === ":") { out.push(cur); cur = ""; }
            else cur += ch;
        }
        out.push(cur);
        return out;
    }

    function refresh() {
        if (!devProc.running) devProc.running = true;
        if (!radioProc.running) radioProc.running = true;
        if (!listProc.running) listProc.running = true;
    }

    function setRadio(on) {
        radioOn = on;
        radioSet.command = ["nmcli", "radio", "wifi", on ? "on" : "off"];
        radioSet.running = true;
    }

    function connectTo(name) {
        if (connProc.running) return;
        error = "";
        busy = name;
        connProc.command = ["nmcli", "dev", "wifi", "connect", name];
        connProc.running = true;
    }

    function disconnect() {
        if (!device) return;
        discProc.command = ["nmcli", "dev", "disconnect", device];
        discProc.running = true;
    }

    Process {
        id: devProc
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE", "dev"]
        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().split("\n").map(l => root.splitTerse(l));
                const w = rows.find(r => r[1] === "wifi");
                root.hasWifi = !!w;
                root.device = w ? w[0] : "";
            }
        }
    }

    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.radioOn = text.trim() === "enabled"
        }
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const best = {};
                let active = null;
                text.trim().split("\n").forEach(line => {
                    if (!line) return;
                    const f = root.splitTerse(line);
                    const row = { ssid: f[1], signal: parseInt(f[2]) || 0, security: f[3] || "" };
                    if (!row.ssid) return;
                    if (f[0] === "*") { active = row; return; }
                    if (!best[row.ssid] || best[row.ssid].signal < row.signal) best[row.ssid] = row;
                });
                const list = Object.keys(best).map(k => best[k]);
                list.sort((a, b) => b.signal - a.signal);
                root.networks = list;
                root.connected = active !== null;
                root.ssid = active ? active.ssid : "";
                root.signal = active ? active.signal : 0;
                root.security = active ? active.security : "";
            }
        }
    }

    Process { id: radioSet; onExited: root.refresh() }
    Process { id: discProc; onExited: root.refresh() }
    Process { id: rescanProc; command: ["nmcli", "dev", "wifi", "rescan"] }

    Process {
        id: connProc
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim()) root.error = text.trim().split("\n")[0];
            }
        }
        onExited: {
            root.busy = "";
            root.refresh();
        }
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // while the Wi-Fi page is open: rescan, then refresh the list
    Connections {
        target: Pill
        function onModeChanged() {
            if (Pill.mode === "wifi") {
                root.error = "";
                rescanProc.running = true;
                scanDelay.restart();
            }
        }
    }
    Timer { id: scanDelay; interval: 2500; onTriggered: root.refresh() }
}
