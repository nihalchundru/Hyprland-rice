pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Installed font families (fontconfig). Loaded the first time something reads it.
Singleton {
    id: root
    property var families: []
    Process {
        command: ["sh", "-c", "fc-list : family | sed 's/,.*//' | sort -u"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.families = text.split("\n").map(x => x.trim()).filter(x => x !== "")
        }
    }
}
