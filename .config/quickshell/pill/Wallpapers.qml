pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "wallcolor.js" as WC

// Wallpaper list for the active theme + the one currently set.
Singleton {
    id: root

    property var list: []          // absolute paths
    property string current: ""

    // colour names per wallpaper, filled in by wall-colors.sh after the list loads
    property var colors: ({})
    property int colorsRev: 0              // bumps when colors changed (colors itself is edited in place)
    property bool analysing: false

    function addColors(line) {
        const t = line.indexOf("\t");
        if (t < 0) return;
        colors[line.slice(0, t)] = WC.classify(line.slice(t + 1).trim().split(" "));
        revTimer.restart();                 // many lines arrive quickly: update the UI in one go
    }

    function startColors() {
        if (!colorProc.running) colorProc.running = true;
    }

    Timer { id: revTimer; interval: 120; onTriggered: root.colorsRev++ }

    Process {
        id: colorProc
        command: ["bash", Theme.scriptsDir + "wall-colors.sh"]
        stdout: SplitParser { onRead: line => root.addColors(line) }
        onRunningChanged: root.analysing = running
    }

    function nameOf(p) {
        const s = (p || "").split("/");
        return s[s.length - 1];
    }

    function reload() {
        curFile.reload();
        if (!listProc.running) listProc.running = true;
    }

    function apply(path) {
        current = path;
        Quickshell.execDetached(["bash", Theme.scriptsDir + "apply-wall.sh", path]);
    }

    // set-wallpaper.sh keeps this file pointing at the current wallpaper
    FileView {
        id: curFile
        path: Quickshell.env("HOME") + "/.config/rofi/current_wallpaper.rasi"
        onLoaded: {
            // file contains: * { current-image: url("/path/to/wall.png", width); }
            const t = text();
            const a = t.indexOf('url("');
            const b = a >= 0 ? t.indexOf('"', a + 5) : -1;
            root.current = (a >= 0 && b > a) ? t.substring(a + 5, b) : "";
        }
    }

    Process {
        id: listProc
        command: ["bash", Theme.scriptsDir + "wall-list.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.list = text.trim().split("\n").filter(l => l);
                root.startColors();
            }
        }
    }
}
