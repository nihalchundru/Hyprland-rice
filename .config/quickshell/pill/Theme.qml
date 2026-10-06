pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── colors.json lives in the topbar config and is shared ──────────
    readonly property string colorsPath: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"

    FileView {
        path: root.colorsPath
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: c
            property string text: "#e7ad97"
            property string accent: "#4ab369"
            property string green: "#52b870"
            property string red: "#dc8767"
        }
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t,
                       a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t, 1);
    }

    // ── palette ───────────────────────────────────────────────────────
    readonly property color body: "#000000"          // hardcoded on purpose
    readonly property color accent: c.accent
    readonly property color text: c.text
    readonly property color green: c.green
    readonly property color red: c.red

    // derived neutrals: faint tints of `text` over black
    readonly property color tile: mix(body, text, 0.07)
    readonly property color tileHi: mix(body, text, 0.12)
    readonly property color inset: mix(body, text, 0.035)
    readonly property color dim: mix(body, text, 0.62)     // secondary text
    readonly property color faint: mix(body, text, 0.30)   // inactive dots, dimmest text
    readonly property color onAccent: mix(body, accent, 0.12)

    // ── sizing / motion ───────────────────────────────────────────────
    readonly property int idleW: 300
    readonly property int idleH: 40
    readonly property int margin: 8
    readonly property int windowH: 820
    readonly property int animMs: 380
    readonly property int hoverInMs: 110
    readonly property int hoverOutMs: 350
    readonly property string fontFamily: "Inter"

    // folder holding the helper scripts (change if you rename the config folder)
    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/pill/scripts/"
}
