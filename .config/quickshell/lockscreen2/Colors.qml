pragma Singleton

import QtQuick
import Quickshell

// Cyberpunk / Bento Teal Palette based on the screenshot
Singleton {
    id: root

    // Background & Card surfaces
    property color bg:          "#0e1413"
    property color cardBg:      Qt.rgba(0.08, 0.12, 0.11, 0.78)
    property color cardBorder:  Qt.rgba(0.32, 0.85, 0.72, 0.16)

    // Accents & Typography
    property color accent:      "#52d9b8"
    property color tealSoft:    "#82e0cf"
    property color text:        "#e5f2ee"
    property color sub:         "#708a83"
    property color red:         "#f07178"

    // Palette dots for fastfetch
    readonly property var paletteDots: [
        "#2a3835", "#52d9b8", "#82e0cf", "#a7f3d0", "#6ee7b7", "#93c5fd", "#c4b5fd"
    ]
}
