pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper list for the active theme + the one currently set.
Singleton {
    id: root

    property var list: []          // absolute paths
    property string current: ""

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
            onStreamFinished: root.list = text.trim().split("\n").filter(l => l)
        }
    }
}
