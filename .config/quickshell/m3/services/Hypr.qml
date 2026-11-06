pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root
    readonly property var workspaces: Hyprland.workspaces.values
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property int focusedId: focusedWorkspace ? focusedWorkspace.id : 1
    readonly property string activeTitle: Hyprland.activeToplevel ? (Hyprland.activeToplevel.title || "") : ""
    readonly property var workspaceIds: workspaces.map(w => w.id)

    // Hyprland 0.55+ replaced hyprlang with Lua: dispatch strings are now Lua expressions
    // (Hyprland wraps them as hl.dispatch(<expr>)). Older versions still take "workspace 3".
    property bool lua: true

    readonly property var focusedScreen: {
        const m = Hyprland.focusedMonitor
        const s = m ? Quickshell.screens.find(x => x.name === m.name) : null
        return s ? s : Quickshell.screens[0]
    }

    function exists(id) { return workspaceIds.indexOf(id) >= 0 }
    function dispatch(cmd) { Hyprland.dispatch(cmd) }
    function goto(id) { dispatch(lua ? 'hl.dsp.focus({ workspace = "' + id + '" })' : "workspace " + id) }
    function exec(cmd) { dispatch(lua ? "hl.dsp.exec_cmd(" + JSON.stringify(cmd) + ")" : "exec " + cmd) }

    Process {
        command: ["hyprctl", "version", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/"version"\s*:\s*"v?(\d+)\.(\d+)/) || text.match(/"tag"\s*:\s*"v?(\d+)\.(\d+)/)
                if (m) root.lua = parseInt(m[1]) > 0 || parseInt(m[2]) >= 55
            }
        }
    }
}
