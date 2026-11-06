pragma Singleton

import Quickshell
import QtQuick

// Single source of truth for the shell's look.
// Because this file sits next to every other file in the config, QML's implicit
// imports expose it by name (Theme.xyz) everywhere without an import statement.
Singleton {
    id: root

    // --- palette (mirrors the Firecrust hero page) ---
    readonly property color base:      "#140d0a"
    readonly property color surface:   "#1e1310"
    readonly property color surfaceHi: "#2e1c16"
    readonly property color cream:     "#fff6ea"
    readonly property color muted:     "#a8917f"
    readonly property color tomato:    "#ff4d2e"
    readonly property color cheese:    "#ffc24b"
    readonly property color basil:     "#6ec04a"
    readonly property color line:      "#1ffff6ea"  // #AARRGGBB

    // --- metrics ---
    readonly property int barHeight: 34
    readonly property int radius: 10
    readonly property int gap: 6
    readonly property int pad: 9

    // --- motion ---
    readonly property int animFast: 110
    readonly property int animMed: 200

    // --- type ---
    // Swap these for whatever you have installed (`fc-list | grep -i nerd`).
    readonly property string sans: "Inter"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property int fontPx: 12
}
