pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string path:
        Quickshell.env("HOME") + "/.config/quickshell/widgets/todos.json"

    property var items: []                  // [{ text, done }]
    property string lastWritten: ""
    readonly property int doneCount: items.filter(i => i.done).length

    function persist() {
        const t = JSON.stringify({ items: items }, null, 2);
        lastWritten = t;
        file.setText(t);
    }

    function add(text) {
        const t = String(text).trim();
        if (t === "") return;
        items = items.concat([{ text: t, done: false }]);
        persist();
    }

    function toggle(i) {
        items = items.map((it, n) => n === i ? { text: it.text, done: !it.done } : it);
        persist();
    }

    function remove(i) {
        items = items.filter((_, n) => n !== i);
        persist();
    }

    function clearDone() {
        items = items.filter(it => !it.done);
        persist();
    }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const t = text();
            if (t === root.lastWritten) return;     // our own save echoing back
            try {
                const j = JSON.parse(t);
                root.items = (Array.isArray(j.items) ? j.items : [])
                    .filter(i => i && typeof i.text === "string")
                    .map(i => ({ text: i.text, done: i.done === true }));
            } catch (e) {
                console.warn("Todos: bad todos.json:", e);
            }
        }
        onLoadFailed: (error) => {
            if (error === FileViewError.FileNotFound)
                root.persist();
        }
    }
}