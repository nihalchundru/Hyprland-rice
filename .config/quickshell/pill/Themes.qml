pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Reads the theme list from ~/.config/hypr/themes/themes.sh and applies themes
// through the same scripts the rest of the rice uses.
Singleton {
    id: root

    property var list: []          // {name, bg, text, accent, accent2, green, yellow, red, teal}
    property string current: ""

    function col(s, fallback) {
        return (s && s[0] === "#") ? s : (fallback || "#444444");
    }

    function reload() {
        curFile.reload();
        if (!listProc.running) listProc.running = true;
    }

    function apply(name) {
        current = name;
        Quickshell.execDetached(["bash", Theme.scriptsDir + "apply-theme.sh", name]);
    }

    FileView {
        id: curFile
        path: Quickshell.env("HOME") + "/.config/hypr/themes/current-name"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.current = text().trim()
    }

    Process {
        id: listProc
        command: ["bash", Theme.scriptsDir + "themes-list.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.list = text.trim().split("\n").filter(l => l).map(l => {
                    const f = l.split("|");
                    return {
                        name: f[0],
                        bg: root.col(f[1], "#1e1e2e"),
                        text: root.col(f[2], "#cccccc"),
                        accent: root.col(f[3]),
                        accent2: root.col(f[4]),
                        green: root.col(f[5]),
                        yellow: root.col(f[6]),
                        red: root.col(f[7]),
                        teal: root.col(f[8])
                    };
                });
            }
        }
    }

    Component.onCompleted: listProc.running = true
}
