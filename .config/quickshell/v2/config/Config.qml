pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string home: Quickshell.env("HOME")

    // ── paths (your existing theming system) ──
    readonly property string colorsPath:      home + "/.config/quickshell/topbar/colors.json"
    readonly property string clockFormatPath: home + "/.config/hypr/themes/clock-format"
    readonly property string scriptsDir:      home + "/.config/hypr/scripts"

    // ── fonts ──
    readonly property string fontSans:  "Roboto"
    readonly property string fontIcons: "Material Symbols Rounded"

    // ── bar metrics ──
    readonly property QtObject bar: QtObject {
        readonly property int height: 48        // window height (exclusive zone)
        readonly property int groupHeight: 36   // pill height
        readonly property int marginX: 8
        readonly property int marginY: 6
        readonly property int gap: 6
        readonly property int workspaces: 5     // minimum shown; grows to 10
        readonly property int titleMaxWidth: 280
    }

    // ── external apps ──
    readonly property QtObject cmd: QtObject {
        readonly property var audio:   ["pavucontrol"]
        readonly property var network: ["nm-connection-editor"]
    }
}