import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // ── IPC — called from volume/brightness scripts ───────────────────────
    IpcHandler {
        target: "osd"
        function showVolume(val) {
            osdWindow.icon  = parseInt(val) === 0 ? "󰝟"
                            : parseInt(val) < 33  ? "󰕿"
                            : parseInt(val) < 66  ? "󰖀" : "󰕾"
            osdWindow.value = parseInt(val)
            osdWindow.label = val + "%"
            osdWindow.show()
        }
        function showBrightness(val) {
            osdWindow.icon  = parseInt(val) < 33 ? "󰃞"
                            : parseInt(val) < 66 ? "󰃟" : "󰃠"
            osdWindow.value = parseInt(val)
            osdWindow.label = val + "%"
            osdWindow.show()
        }
        function showMuted() {
            osdWindow.icon  = "󰝟"
            osdWindow.value = 0
            osdWindow.label = "Muted"
            osdWindow.show()
        }
    }

    // ── Color loader ──────────────────────────────────────────────────────
    property var colors: ({
        bg:     "#1E1E2E",
        surface:"#313244",
        text:   "#CDD6F4",
        accent: "#CBA6F7",
        sub:    "#6C7086"
    })

    Process {
        id: colorReader
        command: ["cat", `${Quickshell.env("HOME")}/.config/quickshell/topbar/colors.json`]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.colors = JSON.parse(this.text) } catch(e) {}
            }
        }
        running: true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: colorReader.running = true }

    // ── OSD Window ────────────────────────────────────────────────────────
    PanelWindow {
        id: osdWindow
        visible: false
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-osd"
        exclusiveZone: -1

        anchors { top: true; left: true; right: true }
        implicitHeight: 70

        property string icon:  "󰕾"
        property int    value: 100
        property string label: "100%"

        function show() {
            visible = true
            hideTimer.restart()
        }

        // Auto-hide after 1.5s
        Timer {
            id: hideTimer
            interval: 1500
            onTriggered: osdWindow.visible = false
        }

        // Fade in/out
        NumberAnimation on opacity {
            running: osdWindow.visible
            from: 0; to: 1
            duration: 120
            easing.type: Easing.OutCubic
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            width: 220
            height: 50
            radius: 25
            color: root.colors.bg
            border.color: root.colors.accent
            border.width: 1
            antialiasing: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // Icon
                Text {
                    text: osdWindow.icon
                    color: root.colors.accent
                    font.pixelSize: 18
                    font.family: "JetBrainsMono Nerd Font"
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: root.colors.surface

                    Rectangle {
                        width: Math.max(0, parent.width * osdWindow.value / 100)
                        height: parent.height
                        radius: parent.radius
                        color: root.colors.accent
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }
                }

                // Value label
                Text {
                    text: osdWindow.label
                    color: root.colors.sub
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.preferredWidth: 36
                }
            }
        }
    }
}
