pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string type: "none"     // wifi | ethernet | none
    property string name: ""
    readonly property bool connected: type !== "none"
    readonly property string icon: type === "wifi" ? "wifi"
                                 : type === "ethernet" ? "lan" : "signal_wifi_off"

    function refresh() { if (!query.running) query.running = true }

    Process {
        id: query
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                let t = "none", n = ""
                for (const line of text.trim().split("\n")) {
                    const p = line.split(":")
                    if (p[1] === "connected" && (p[0] === "wifi" || p[0] === "ethernet")) {
                        t = p[0]; n = p.slice(2).join(":"); break
                    }
                }
                root.type = t
                root.name = n
            }
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser { onRead: debounce.restart() }
    }

    Timer { id: debounce; interval: 400; onTriggered: root.refresh() }

    Component.onCompleted: refresh()
}