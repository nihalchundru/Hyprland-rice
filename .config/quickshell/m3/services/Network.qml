pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// nmcli based (no extra deps). Polls every 5s.
Singleton {
    id: root
    property bool connected: false
    property string type: ""          // wifi | ethernet | ""
    property string name: ""
    property int signal: 0            // 0..100 (wifi)
    property bool wifiEnabled: false
    property bool available: false

    function refresh() { if (!poll.running) poll.running = true }
    function setWifi(on) { wifiSet.command = ["nmcli", "radio", "wifi", on ? "on" : "off"]; wifiSet.running = true }
    function toggleWifi() { setWifi(!wifiEnabled) }

    Process {
        id: poll
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device; echo '---'; nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null; echo '---'; nmcli radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("---\n")
                root.available = parts.length >= 3
                let conn = false, type = "", name = ""
                for (const line of (parts[0] || "").split("\n")) {
                    const i = line.indexOf(":"), j = line.indexOf(":", i + 1)
                    if (i < 0 || j < 0) continue
                    const t = line.slice(0, i), st = line.slice(i + 1, j), c = line.slice(j + 1)
                    if ((t === "wifi" || t === "ethernet") && st === "connected") {
                        if (!conn || t === "ethernet") { conn = true; type = t; name = c.replace(/\\:/g, ":") }
                    }
                }
                let sig = 0
                for (const line of (parts[1] || "").split("\n"))
                    if (line.startsWith("*:")) sig = parseInt(line.slice(2)) || 0
                root.connected = conn; root.type = type; root.name = name; root.signal = sig
                root.wifiEnabled = (parts[2] || "").trim() === "enabled"
            }
        }
    }
    Process { id: wifiSet; onExited: root.refresh() }
    Timer { interval: 5000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refresh() }
    readonly property string icon: !connected ? "signal_wifi_off" : type === "ethernet" ? "lan" : signal > 75 ? "wifi" : signal > 40 ? "wifi_2_bar" : "wifi_1_bar"
}
