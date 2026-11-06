pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // [{ id, preview, isImage }], newest first
    property var items: []
    property string filter: ""
    property bool error: false

    readonly property var filtered: {
        const q = filter.trim().toLowerCase();
        if (q === "") return items;
        return items.filter(it => it.preview.toLowerCase().indexOf(q) >= 0);
    }

    // watchers: every new copy is stored in the history
    Process {
        running: true
        command: ["wl-paste", "--type", "text", "--watch", "cliphist", "store"]
    }
    Process {
        running: true
        command: ["wl-paste", "--type", "image", "--watch", "cliphist", "store"]
    }

    // reads the history
    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(this.text)
        }
        onExited: (code) => root.error = (code !== 0)
    }

    Process { id: copier }
    Process { id: deleter; onExited: root.refresh() }
    Process { id: wiper; onExited: root.refresh() }

    function refresh() {
        lister.running = true;
    }

    function parse(txt) {
        const out = [];
        const lines = txt.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const ln = lines[i];
            if (ln === "") continue;
            const t = ln.indexOf("\t");
            if (t < 0) continue;
            const prev = ln.substring(t + 1);
            out.push({
                id: ln.substring(0, t),
                preview: prev,
                isImage: prev.indexOf("[[ binary data") === 0
            });
        }
        items = out;
    }

    function copy(id) {
        const n = parseInt(id);
        if (isNaN(n)) return;
        copier.command = ["sh", "-c", "cliphist decode " + n + " | wl-copy"];
        copier.running = true;
    }

    function remove(id) {
        const n = parseInt(id);
        if (isNaN(n)) return;
        // hide it right away, then delete for real
        items = items.filter(it => it.id !== String(id));
        deleter.command = ["sh", "-c",
            "cliphist list | awk -F'\\t' -v id=" + n + " '$1==id' | cliphist delete"];
        deleter.running = true;
    }

    function wipe() {
        items = [];
        wiper.command = ["cliphist", "wipe"];
        wiper.running = true;
    }
}