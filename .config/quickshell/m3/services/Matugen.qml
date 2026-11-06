pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Runs matugen on the rofi wallpaper copy at start, on wallpaper change, and on mode/scheme change.
// Output: m3/colors.json (via m3/matugen/config.toml, isolated from your other matugen templates).
Singleton {
    id: root
    readonly property string home: Quickshell.env("HOME")
    readonly property string wallpaper: home + "/.config/rofi/images/a.png"
    readonly property string cfg: home + "/.config/quickshell/m3/matugen/config.toml"
    readonly property bool busy: proc.running
    property string lastError: ""
    property bool pending: false

    function start() { run() }
    function run() {
        if (proc.running) { pending = true; return }
        proc.running = true
    }

    Process {
        id: proc
        command: ["matugen", "-c", root.cfg, "image", root.wallpaper,
                  "-m", M3Config.mode, "-t", "scheme-" + M3Config.scheme,
                  "--source-color-index", "0"]
        stderr: StdioCollector { id: err }
        onExited: code => {
            if (code !== 0) {
                root.lastError = err.text
                console.warn("[m3] matugen exit " + code + ": " + err.text)
            } else root.lastError = ""
            if (root.pending) { root.pending = false; root.run() }
        }
    }

    // set-wallpaper.sh rewrites a.png on every change -> recolor
    FileView {
        path: root.wallpaper
        preload: false
        watchChanges: true
        onFileChanged: debounce.restart()
    }

    Connections {
        target: M3Config
        function onModeChanged() { debounce.restart() }
        function onSchemeChanged() { debounce.restart() }
    }

    Timer { id: debounce; interval: 400; onTriggered: root.run() }
}
