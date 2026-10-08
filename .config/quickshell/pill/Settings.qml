pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Every user-tunable value lives here and is saved to settings.json.
// Read with Settings.get("key"), write with Settings.set("key", value).
// Bindings that call get() update live when a value changes.
Singleton {
    id: root

    readonly property string path: Quickshell.env("HOME") + "/.config/quickshell/pill/settings.json"

    // one place for defaults; settings.json only stores what you changed
    readonly property var defaults: ({
        // motion
        reduceMotion: false,
        motionMove: 380,
        motionFade: 180,
        hoverResponse: 110,
        bounce: 0,
        // launcher
        launcherWidth: 760,
        launcherRowH: 62,
        launcherRows: 7,
        // notifications
        notifTimeout: 5000,
        notifUrgentTimeout: 6000,
        notifWidth: 500,
        notifShowBody: true,
        notifHistoryH: 220,
        // bar & island
        notchMode: false,
        barHeight: 40,
        collapsedWidth: 300,
        expandedHeight: 124,
        gap: 8,
        innerPadding: 16,
        cornerRadius: 20,
        cornerRadiusExp: 30,
        stageLift: 0
    })

    property var store: ({})
    property double lastWrite: 0
    property string requestedPage: ""     // set by `ipc call settings page <id>`

    function get(key) {
        const v = store[key];
        return v !== undefined ? v : defaults[key];
    }

    function set(key, value) {
        if (get(key) === value) return;
        const o = Object.assign({}, store);
        o[key] = value;
        store = o;
        saveTimer.restart();
    }

    function reset(keys) {
        const o = Object.assign({}, store);
        keys.forEach(k => { delete o[k]; });
        store = o;
        saveTimer.restart();
    }

    // write shortly after the last change, so dragging a slider is one write
    Timer {
        id: saveTimer
        interval: 400
        onTriggered: {
            root.lastWrite = Date.now();
            file.setText(JSON.stringify(root.store, null, 2) + "\n");
        }
    }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        printErrors: false

        onLoaded: {
            try {
                const o = JSON.parse(text());
                if (o && typeof o === "object") root.store = o;
            } catch (e) {}
        }

        // pick up hand edits, but ignore the echo of our own write
        onFileChanged: {
            if (Date.now() - root.lastWrite > 1500) reload();
        }
    }
}
