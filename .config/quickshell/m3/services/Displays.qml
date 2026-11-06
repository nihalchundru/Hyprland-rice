pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Monitors via hyprctl. Changes use `hyprctl eval hl.monitor{...}` on Lua configs (0.55+), `hyprctl keyword monitor` otherwise.
// apply() starts a 10 s revert countdown; call keep() to accept.
Singleton {
    id: root
    property var monitors: []
    property string selected: ""
    property bool confirming: false
    property int secondsLeft: 0
    property var prev: null

    function refresh() { if (!list.running) list.running = true }
    function snapshot(name) {
        const m = monitors.find(x => x.name === name)
        return m ? { name: m.name, mode: m.width + "x" + m.height + "@" + m.refresh.toFixed(2), x: m.x, y: m.y, scale: m.scale, transform: m.transform, disabled: m.disabled } : null
    }
    function cmdFor(m) {
        if (Hypr.lua) {
            const body = m.disabled ? "disabled = true" : 'mode = "' + m.mode + '", position = "' + m.x + "x" + m.y + '", scale = ' + m.scale + ", transform = " + m.transform
            return ["hyprctl", "eval", 'hl.monitor({ output = "' + m.name + '", ' + body + " })"]
        }
        return ["hyprctl", "keyword", "monitor", m.disabled ? m.name + ",disable" : m.name + "," + m.mode + "," + m.x + "x" + m.y + "," + m.scale + ",transform," + m.transform]
    }
    function apply(m) {
        prev = snapshot(m.name)
        run.command = cmdFor(m); run.running = true
        confirming = true; secondsLeft = 10; tick.restart(); settle.restart()
    }
    function keep() { confirming = false; tick.stop() }
    function revert() {
        confirming = false; tick.stop()
        if (prev) { run.command = cmdFor(prev); run.running = true; settle.restart() }
    }

    Process { id: run }
    Timer { id: settle; interval: 900; onTriggered: root.refresh() }
    Timer { id: tick; interval: 1000; repeat: true; onTriggered: { root.secondsLeft--; if (root.secondsLeft <= 0) root.revert() } }
    Process {
        id: list
        command: ["hyprctl", "monitors", "all", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(text).map(m => ({
                        name: m.name, desc: [m.make, m.model, m.serial].filter(x => x).join(" "),
                        width: m.width, height: m.height, refresh: m.refreshRate, x: m.x, y: m.y,
                        scale: m.scale, transform: m.transform, disabled: !!m.disabled,
                        modes: (m.availableModes || [])
                    }))
                    if (!root.monitors.find(x => x.name === root.selected)) root.selected = root.monitors.length > 0 ? root.monitors[0].name : ""
                } catch (e) {}
            }
        }
    }
}
