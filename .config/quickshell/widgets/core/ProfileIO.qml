pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    readonly property string dir:
        Quickshell.env("HOME") + "/.config/quickshell/widgets/profiles"
    readonly property string shownDir: "~/.config/quickshell/widgets/profiles"

    property var files: []              // *.json names found in the folder
    property string message: ""
    property bool isError: false
    property string importing: ""
    property string exporting: ""

    function say(text, err) {
        message = text;
        isError = !!err;
        msgTimer.restart();
    }

    function safeName(n) {
        const s = String(n).trim()
            .replace(/[^A-Za-z0-9._-]+/g, "_")
            .replace(/^[._]+|_+$/g, "");
        return s === "" ? "layout" : s;
    }

    function refresh() {
        if (!lister.running) lister.running = true;
    }

    function exportProfile(name) {
        if (writer.running) return;
        exporting = safeName(name) + ".json";
        const payload = JSON.stringify({
            qsWidgetsProfile: 1,
            name: name,
            widgets: LayoutStore.profileWidgets(name)
        }, null, 2);
        writer.command = ["sh", "-c",
            'mkdir -p "$1" && printf "%s\\n" "$2" > "$3"',
            "sh", dir, payload, dir + "/" + exporting];
        writer.running = true;
    }

    function importFile(fileName) {
        if (reader.running) return;
        importing = fileName;
        reader.command = ["cat", dir + "/" + fileName];
        reader.running = true;
    }

    function handleImport(text) {
        try {
            const j = JSON.parse(text);
            const list = Array.isArray(j) ? j : j.widgets;
            if (!Array.isArray(list)) throw new Error("no widgets list in file");
            const base = (!Array.isArray(j) && typeof j.name === "string" && j.name !== "")
                ? j.name : importing.replace(/\.json$/, "");
            const r = LayoutStore.importProfile(base, list);
            say("Imported \"" + r.name + "\" (" + r.kept + " widgets"
                + (r.skipped > 0 ? ", " + r.skipped + " skipped" : "") + ")", false);
        } catch (e) {
            say("Could not import " + importing + ": " + e.message, true);
        }
    }

    Timer { id: msgTimer; interval: 5000; onTriggered: root.message = "" }

    Process {
        id: lister
        command: ["sh", "-c", 'mkdir -p "$1"; ls -1 "$1"', "sh", root.dir]
        stdout: StdioCollector {
            onStreamFinished: root.files = text.split("\n")
                .filter(f => f.endsWith(".json")).sort()
        }
    }

    Process {
        id: writer
        onExited: (code, status) => {
            if (code === 0) root.say("Exported " + root.exporting, false);
            else root.say("Export failed (exit " + code + ")", true);
            root.refresh();
        }
    }

    Process {
        id: reader
        stdout: StdioCollector {
            onStreamFinished: root.handleImport(text)
        }
    }
}