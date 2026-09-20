import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root
    //property var colors: ({bg: "#1E1E2E", accent: root.colors.accent, text: root.colors.text, surface: root.colors.surface, sub: "#6C7086"})

    property var colors: ({
    bg: "#1E1E2E", surface: "#313244", surface2: "#45475A",
    text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7"
    //text: root.colors.text, sub: "#6C7086", accent: root.colors.accent
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

Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: colorReader.running = true
}

    IpcHandler {
        target: "keybinds"
        function toggle() { popup.visible = !popup.visible }
    }

    PanelWindow {
        id: popup
        visible: true
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-keybinds"

        anchors { top: true; left: true; right: true; bottom: true }

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: popup.visible = false
            z: 0
        }

        Rectangle {
            anchors.centerIn: parent
            width: 720
            height: content.implicitHeight + 0
            radius: 20
            color: Qt.rgba(40/255, 44/255, 52/255, 0.35)
            border.color: root.colors.accent
            border.width: 1
            antialiasing: true
            z: 1

            MouseArea {
                anchors.fill: parent
                onClicked: {} // absorb clicks so outer close doesn't fire
            }

            ColumnLayout {
                id: content
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 24
                }
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "  Keybinds"
                        color: root.colors.accent
                        font.pixelSize: 18
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: root.colors.surface
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: root.colors.text
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.visible = false
                        }
                    }
                }

                // Divider
                Rectangle { Layout.fillWidth: true; height: 1; color: root.colors.surface }

                // Two column grid of keybind sections
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 16

                    // ── Apps ─────────────────────────────────────────────────
                    KeySection {
                        title: "  Apps"
                        binds: [
                            ["ALT + Enter",    "Terminal (kitty)"],
                            ["ALT + D",        "App Launcher"],
                            ["ALT + E",        "File Manager"],
                            ["ALT + B",        "Browser"],
                        ]
                    }

                    // ── Windows ───────────────────────────────────────────────
                    KeySection {
                        title: "  Windows"
                        binds: [
                            ["ALT + Q",        "Close window"],
                            ["ALT + F",        "Fullscreen"],
                            ["ALT + W",        "Float window"],
                            ["ALT + ←↑↓→",    "Move focus"],
                            ["ALT + SHIFT ←↑↓→","Move window"],
                            ["ALT + CTRL ←↑↓→", "Resize window"],
                        ]
                    }

                    // ── Workspaces ─────────────────────────────────────────────
                    KeySection {
                        title: "  Workspaces"
                        binds: [
                            ["ALT + 1-5",      "Switch workspace"],
                            ["ALT + SHIFT 1-5","Move to workspace"],
                        ]
                    }

                    // ── Theming ────────────────────────────────────────────────
                    KeySection {
                        title: "  Theming"
                        binds: [
                            ["ALT + T",        "Theme switcher"],
                            ["ALT + W",        "Wallpaper switcher"],
                            ["ALT + SHIFT+W",  "Random wallpaper"],
                            ["ALT + SHIFT+T",  "Transition style"],
                            ["ALT + SHIFT+L",  "Transition length"],
                            ["ALT + SHIFT+C",  "Corner style"],
                            ["ALT + SHIFT+S",  "Picker style"],
                        ]
                    }

                    // ── Bars ──────────────────────────────────────────────────
                    KeySection {
                        title: "  Bars & Layouts"
                        binds: [
                            ["ALT + SHIFT+B",  "Bar switcher"],
                            ["ALT + P",        "Layout switcher"],
                            ["ALT + SHIFT+D",  "Rofi layout"],
                            ["ALT + SHIFT+P",  "Powermenu layout"],
                        ]
                    }

                    // ── System ────────────────────────────────────────────────
                    KeySection {
                        title: "  System"
                        binds: [
                            ["ALT + A",        "Sidebar toggle"],
                            ["ALT + X",        "Control panel"],
                            ["ALT + N",        "Notifications"],
                            ["ALT + L",        "Lock screen"],
                            ["CTRL+ALT+Delete","Power menu"],
                            ["Print",          "Screenshot"],
                            ["SHIFT+Print",    "Area screenshot"],
                            ["ALT + V",        "Clipboard history"],
                            ["ALT + SHIFT+V",  "Delete clipboard entry"],
                            ["ALT + M",        "This popup 󰘬"],
                            ["ALT+CTRL+S",     "Shell switcher"],
                        ]
                    }
                }

                Item { Layout.preferredHeight: 4 }
            }
        }
    }

    // ── Reusable section component ─────────────────────────────────────────
    component KeySection: Rectangle {
        property string title: ""
        property var binds: []

        Layout.fillWidth: true
        height: sectionCol.implicitHeight + 16
        radius: 12
        color: root.colors.surface

        ColumnLayout {
            id: sectionCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
            spacing: 6

            Text {
                text: title
                color: root.colors.accent
                font.pixelSize: 11
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                bottomPadding: 2
            }

            Repeater {
                model: binds
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        radius: 6
                        color: root.colors.surface2
                        Layout.preferredWidth: 160
                        height: keyText.implicitHeight + 6
                        Text {
                            id: keyText
                            anchors.centerIn: parent
                            text: modelData[0]
                            color: root.colors.text
                            font.pixelSize: 10
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                        }
                    }

                    Text {
                        text: modelData[1]
                        color: root.colors.sub
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
