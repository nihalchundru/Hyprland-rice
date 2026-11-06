import QtQuick
import Quickshell
import Quickshell.Io
import "components"

// Quickshell visualizer: one strip PanelWindow per screen (same proven window
// pattern as a working cava visualizer: Variants + PanelWindow + screen +
// aboveWindows + mask). The settings panel is a separate overlay PanelWindow.
ShellRoot {
    id: root
    readonly property var s: Config.s
    readonly property bool center: s.position === "center"

    // ── visualizer strip, one per monitor ────────────────────────────────
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            // position-driven edge anchors
            anchors.left: root.center || s.position === "left" || s.position === "bottom" || s.position === "top"
            anchors.right: root.center || s.position === "right" || s.position === "bottom" || s.position === "top"
            anchors.top: root.center || s.position === "top" || s.position === "left" || s.position === "right"
            anchors.bottom: root.center || s.position === "bottom" || s.position === "left" || s.position === "right"

            margins {
                left: s.marginX
                right: s.marginX
                top: s.marginY
                bottom: s.marginY
            }
            implicitWidth: s.height  // used for left/right strips
            implicitHeight: s.height // used for bottom/top strips
            exclusiveZone: 0         // don't reserve workspace space
            aboveWindows: s.fullscreenLayer // false = on the desktop (behind windows), true = overlaps them
            focusable: false
            color: "transparent"
            mask: Region { item: gear } // only the gear is clickable; everything else passes through

            Component.onCompleted: console.log("WIN: created screen=", win.screen ? win.screen.name : "?", "pos=", s.position)

            Rectangle { // debug marker (set debugBox false when done)
                visible: s.debugBox
                anchors.fill: parent
                color: "transparent"
                border.color: "red"; border.width: 2
                Text {
                    anchors.centerIn: parent
                    text: "VIZ " + parent.width + "x" + parent.height + " " + s.position
                    color: "red"; font.pixelSize: 16; font.bold: true
                }
            }

            Visualizer {
                anchors.fill: root.center ? undefined : parent
                anchors.centerIn: root.center ? parent : undefined
                width: root.center ? parent.width : undefined
                height: root.center ? s.height : undefined
            }

            Rectangle { // gear toggle (only on the first screen)
                id: gear
                visible: Quickshell.screens.length === 0 || win.screen === Quickshell.screens[0]
                width: 26; height: 26; radius: 13
                anchors.top: parent.top; anchors.topMargin: 6
                anchors.right: parent.right; anchors.rightMargin: 6
                color: Qt.alpha(Colors.background, 0.6)
                border.color: Colors.outline; border.width: 1
                opacity: 0.45
                Text { anchors.centerIn: parent; text: "⚙"; color: Colors.primary; font.pixelSize: 15 }
                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onEntered: parent.opacity = 1; onExited: parent.opacity = 0.45
                    onClicked: Config.settingsOpen = !Config.settingsOpen }
            }
        }
    }

    // ── settings panel ───────────────────────────────────────────────────
    PanelWindow {
        visible: Config.settingsOpen
        color: "transparent"
        aboveWindows: true
        focusable: true
        implicitWidth: 380
        anchors.left: s.position === "left" ? false : true
        anchors.right: s.position === "left" ? true : false
        anchors.top: true
        anchors.bottom: true
        SettingsPanel { anchors.fill: parent; open: Config.settingsOpen }
    }

    // ── IPC: qs ipc call visualizer toggleSettings ──────────────────────
    IpcHandler {
        target: "visualizer"
        function toggleSettings(): void { Config.settingsOpen = !Config.settingsOpen }
        function setStyle(style: string): void { Config.s.style = style }
        function setPosition(position: string): void { Config.s.position = position }
        function setEnabled(enabled: bool): void { Config.s.enabled = enabled }
    }
}
