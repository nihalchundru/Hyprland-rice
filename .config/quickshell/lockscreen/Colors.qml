pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Palette loaded from the topbar's colors.json.
// Live-reloads when the file changes. Falls back to the defaults below
// if the file is missing or broken.
Singleton {
    id: root

    readonly property string path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"

    // Fallbacks = the current iris theme values.
    property color bg:      "#432934"
    property color surface: "#593745"
    property color text:    "#e7ad97"
    property color sub:     "#7b5a68"
    property color accent:  "#4ab369"
    property color teal:    "#93d2a6"
    property color red:     "#dc8767"

    // Colors that password chars cycle through (used in Stage 5).
    readonly property var charColors: [accent, teal, text, red]

    function apply(raw) {
        let d;
        try {
            d = JSON.parse(raw);
        } catch (e) {
            console.warn("[lockscreen] colors.json parse error:", e);
            return;
        }
        // Only overwrite keys that exist, so a partial file still works.
        if (d.bg)      root.bg = d.bg;
        if (d.surface) root.surface = d.surface;
        if (d.text)    root.text = d.text;
        if (d.sub)     root.sub = d.sub;
        if (d.accent)  root.accent = d.accent;
        if (d.teal)    root.teal = d.teal;
        if (d.red)     root.red = d.red;
    }

    FileView {
        id: file
        path: root.path
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.apply(text())
        onLoadFailed: err => console.warn("[lockscreen] could not read", root.path, "- using fallback colors")
    }
}
