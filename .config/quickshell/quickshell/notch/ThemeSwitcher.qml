import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: themeRoot
    property var colors
    property var palettes: ({})
    property bool open: false

    function toggle() { open = !open }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-theme"

    anchors { top: true; left: true; right: true }
    height: open ? 470 : 28
    color: "transparent"
    exclusiveZone: -1
    visible: open

    Process { id: applyProc }
    function applyTheme(name) {
        applyProc.command = ["bash", "-c",
            "bash ~/.config/hypr/scripts/theme-switch.sh " + name]
        applyProc.running = true
        themeRoot.open = false
   }

    // One continuous shape: small header pill + grid below, grown together
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6
        width: themeRoot.open ? 750 : 130
        height: themeRoot.open ? 450 : 28
        radius: 16
        color: themeRoot.colors.bg
        border.color: themeRoot.colors.accent
        border.width: 1
        clip: false
        antialiasing: true

        Behavior on width  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // Header label (always visible)
        RowLayout {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 6
            height: 22
            spacing: 6
            Text {
                text: "󰸌 Theme"
                color: themeRoot.colors.accent
                font.bold: true
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        GridLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 36
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            columns: 4
            columnSpacing: 10
            rowSpacing: 10
            opacity: themeRoot.open ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 150 } }

            Repeater {
                model: [
                    { key: "catppuccin", label: "Catppuccin" },
                    { key: "tokyonight", label: "Tokyo Night" },
                    { key: "gruvbox",    label: "Gruvbox" },
                    { key: "gruvbox-material", label: "Gruvbox Material" },
                    { key: "nord",       label: "Nord" },
                    { key: "rosepine",   label: "Rosé Pine" },
                    { key: "everforest", label: "Everforest" },
                    { key: "onedark",    label: "One Dark" },
                    { key: "everblush",  label: "Everblush" },
                    { key: "aozora",     label: "Aozora Ink" },
                    { key: "latte",      label: "Latte" },
                    { key: "astrabloom", label: "Astra Bloom" },
                    { key: "crimson",    label: "Crimson Twilight" },
                    { key: "iris",        label: "Iris (Dynamic)" },
                    { key: "matugen",    label: "Matugen (Material You)" },
                    { key: "solarized",  label: "Solarized" }
                ]

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 12
                    color: themeRoot.colors.theme === modelData.key
                           ? themeRoot.colors.accent
                           : themeRoot.colors.surface

                    property var pal: themeRoot.palettes[modelData.key] || {}

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        RowLayout {
                            spacing: 4
                            Layout.fillWidth: true
                            Repeater {
                                model: pal.swatches || []
                                Rectangle {
                                    width: 16; height: 16
                                    radius: 8
                                    color: modelData
                                    border.color: "#00000022"
                                    border.width: 1
                                }
                            }
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            color: themeRoot.colors.theme === modelData.key
                                   ? themeRoot.colors.bg
                                   : themeRoot.colors.text
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: themeRoot.applyTheme(modelData.key)
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }
    }
}
