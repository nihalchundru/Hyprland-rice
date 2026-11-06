pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Color palette for the "Deck" lockscreen (Media Deck)
// Loads live colors from ~/.config/quickshell/topbar/colors.json and live-reloads on change.
Singleton {
    id: root

    readonly property string path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"

    // Default fallback values
    property color bg:          "#13151f"
    property color surface:     "#1c1e28"
    property color text:        "#e8eaf2"
    property color sub:         "#8d92a8"
    property color accent:      "#f29cb8"
    property color accentLight: "#ffb8cd"
    property color teal:        "#7dd3fc"
    property color red:         "#f87171"

    // Dynamic derivations for cards & borders
    property color cardBg:      Qt.rgba(surface.r, surface.g, surface.b, 0.86)
    property color cardBorder:  Qt.rgba(accent.r, accent.g, accent.b, 0.24)

    function apply(raw) {
        if (!raw || raw.trim().length === 0) return;
        let d;
        try {
            d = JSON.parse(raw);
        } catch (e) {
            console.warn("[lockscreen3] colors.json parse error:", e);
            return;
        }

        if (d.bg)      root.bg = d.bg;
        if (d.surface) root.surface = d.surface;
        else if (d.bg) root.surface = Qt.lighter(d.bg, 1.35);

        if (d.text)    root.text = d.text;
        if (d.sub)     root.sub = d.sub;
        if (d.accent)  root.accent = d.accent;
        if (d.teal)    root.teal = d.teal;
        if (d.red)     root.red = d.red;

        // Recompute derived colors
        root.cardBg = Qt.rgba(root.surface.r, root.surface.g, root.surface.b, 0.86);
        root.cardBorder = Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.24);
        root.accentLight = Qt.lighter(root.accent, 1.15);
    }

    // 1. Live file watcher
    FileView {
        id: file
        path: root.path
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.apply(text())
        onLoadFailed: err => console.warn("[lockscreen3] FileView could not read", root.path, "- using fallback colors")
    }

    // 2. Direct Process fallback to guarantee initial load on start
    Process {
        id: initProc
        command: ["sh", "-c", "cat " + root.path + " 2>/dev/null || echo ''"]
        running: true
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => root.apply(data)
        }
    }
}
