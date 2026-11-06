pragma Singleton

import QtQuick
import Quickshell

// Centralized dynamic Colors singleton for lockscreen-switcher.
// Feeds the appropriate palette to loaded lockscreens so Colors.* resolves
// without error across directory boundaries.
Singleton {
    id: root

    property string currentStyle: "veil"

    readonly property bool isVeil: currentStyle === "veil"

    // Colors dynamically matching the active preview style
    property color bg:         isVeil ? "#432934" : "#0e1413"
    property color surface:    isVeil ? "#593745" : Qt.rgba(0.08, 0.12, 0.11, 0.78)
    property color cardBg:     isVeil ? Qt.rgba(0.26, 0.16, 0.22, 0.72) : Qt.rgba(0.08, 0.12, 0.11, 0.78)
    property color cardBorder: isVeil ? Qt.rgba(0.9, 0.68, 0.59, 0.18) : Qt.rgba(0.32, 0.85, 0.72, 0.16)
    property color text:       isVeil ? "#e7ad97" : "#e5f2ee"
    property color sub:        isVeil ? "#7b5a68" : "#708a83"
    property color accent:     isVeil ? "#4ab369" : "#52d9b8"
    property color teal:       isVeil ? "#93d2a6" : "#82e0cf"
    property color tealSoft:   "#82e0cf"
    property color red:        isVeil ? "#dc8767" : "#f07178"

    readonly property var charColors: [accent, teal, text, red]
    readonly property var paletteDots: [
        "#2a3835", "#52d9b8", "#82e0cf", "#a7f3d0", "#6ee7b7", "#93c5fd", "#c4b5fd"
    ]
}
