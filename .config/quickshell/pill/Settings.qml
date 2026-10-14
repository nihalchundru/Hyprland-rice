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
        // bar & island
        notchMode: false,
        barHeight: 40,
        collapsedWidth: 300,
        expandedHeight: 124,
        gap: 8,
        innerPadding: 16,
        cornerRadius: 20,
        cornerRadiusExp: 30,
        stageLift: 0,
        // control center (layout is null until you first edit it)
        controlCols: 7,
        controlLayout: null,
        // volume / brightness OSD
        osdTime: 1500,
        osdThickness: 6,
        // clock & date (12/24h is stored in your rice's clock-format file instead)
        showSeconds: false,
        dateFormat: "short",
        showDate: true,
        weekStart: 0,
        // appearance
        accentChoice: "default",
        accentCustom: "",
        colorBurst: false,
        fontSize: 15,
        fontBody: "Inter",
        fontDisplay: "Inter",
        cornerRoundness: 100,
        surfaceDepth: 50,
        // media card
        mediaSongW: 152,
        mediaArt: 38,
        mediaArtist: true,
        mediaAlbum: false,
        mediaTransport: true,
        mediaLyrics: false,
        mediaScroll: true,
        // dock (off until you turn it on in Settings -> Dock)
        dockEnabled: false,
        dockPosition: "bottom",
        dockIconSize: 36,
        dockNotch: false,
        dockGap: 5,
        dockMonitor: "",
        dockPinned: [],
        dockHide: "never",
        dockReserve: true
    })

    property var store: ({})
    property double lastWrite: 0
    property string requestedPage: ""     // set by `ipc call settings page <id>`
    property int closeTick: 0             // bump to ask the settings window to close

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

    // everything back to defaults (the file is rewritten as an empty object)
    function resetAll() {
        store = ({});
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
