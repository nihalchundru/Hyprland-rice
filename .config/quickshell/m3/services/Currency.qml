pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Exchange rates from open.er-api.com (no key), refreshed hourly.
Singleton {
    id: root
    property var rates: ({})
    property bool ready: false
    function rate(from, to) {
        const f = rates[(from || "").toUpperCase()], t = rates[(to || "").toUpperCase()]
        return f && t ? t / f : 0
    }
    function fmt(v) { return v <= 0 ? "--" : Number(v).toLocaleString(Qt.locale(), "f", v >= 100 ? 0 : 3) }
    function refresh() { if (!proc.running) proc.running = true }
    Process {
        id: proc
        command: ["curl", "-sf", "-m", "10", "https://open.er-api.com/v6/latest/USD"]
        stdout: StdioCollector {
            onStreamFinished: { try { const j = JSON.parse(text); if (j.rates) { root.rates = j.rates; root.ready = true } } catch (e) {} }
        }
    }
    Timer { interval: 3600000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refresh() }
}
