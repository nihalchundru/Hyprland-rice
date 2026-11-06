import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // Order must match $OPTIONS in rofi-shell-switch.sh
    readonly property var shells: [
        { name: "Default",      sub: "pill" },
        { name: "Material 3",   sub: "m3"            }
    ]

    // ── Colors: live from colors.json ────────────────────────────────
    // Defaults below are your current matugen values, used if the file
    // is missing or a key is absent.
    FileView {
        id: colorFile
        path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: pal
            property string bg:       "#19120d"
            property string bg2:      "#52443b"
            property string surface:  "#261e18"
            property string surface2: "#312822"
            property string text:     "#f0dfd6"
            property string sub:      "#d6c3b7"
            property string accent:   "#ffb783"
        }
    }

    readonly property color cBg:      Qt.alpha(pal.bg, 0.88)   // overlay dim
    readonly property color cBase:    pal.bg
    readonly property color cTile:    pal.bg2
    readonly property color cCard:    pal.surface
    readonly property color cCardHi:  pal.surface2
    readonly property color cAccent:  pal.accent
    readonly property color cText:    pal.text
    readonly property color cSubtext: pal.sub

    property int current: 0

    function choose(i) {
        Quickshell.execDetached([
            "bash",
            Quickshell.env("HOME") + "/.config/hypr/scripts/rofi-shell-switch.sh",
            String(i + 1)
        ])
        Qt.quit()
    }

    PanelWindow {
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-shell-switcher"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Rectangle {
            anchors.fill: parent
            color: root.cBg

            // click on empty space closes
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }

            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: e => {
                    if (e.key === Qt.Key_Escape)
                        Qt.quit()
                    else if (e.key === Qt.Key_Left)
                        root.current = Math.max(0, root.current - 1)
                    else if (e.key === Qt.Key_Right)
                        root.current = Math.min(root.shells.length - 1, root.current + 1)
                    else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter)
                        root.choose(root.current)
                }
            }

            Text {
                anchors { horizontalCenter: parent.horizontalCenter; bottom: row.top; bottomMargin: 40 }
                text: "Select Desktop Layout"
                color: root.cText
                font.pixelSize: 22
                font.weight: Font.Medium
            }

            Row {
                id: row
                anchors.centerIn: parent
                spacing: 20

                Repeater {
                    model: root.shells

                    Rectangle {
                        id: card
                        required property var modelData
                        required property int index
                        readonly property bool selected: index === root.current

                        width: 200
                        height: 260
                        radius: 24
                        color: selected ? root.cCardHi : root.cCard
                        border.width: selected ? 2 : 0
                        border.color: root.cAccent
                        scale: selected ? 1.06 : 1.0

                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            // placeholder preview: swap for an Image later
                            Rectangle {
                                width: 90; height: 90; radius: 28
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: card.selected ? root.cAccent : root.cTile
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: card.modelData.name.charAt(0)
                                    font.pixelSize: 40
                                    font.weight: Font.Bold
                                    color: card.selected ? root.cBase : root.cSubtext
                                }
                            }
                            Item { width: 1; height: 12 }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: card.modelData.name
                                color: root.cText
                                font.pixelSize: 18
                                font.weight: Font.Medium
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: card.modelData.sub
                                color: root.cSubtext
                                font.pixelSize: 13
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.current = card.index
                            onClicked: root.choose(card.index)
                        }
                    }
                }
            }

            Text {
                anchors { horizontalCenter: parent.horizontalCenter; top: row.bottom; topMargin: 40 }
                text: "← →  select     Enter  apply     Esc  cancel"
                color: root.cSubtext
                font.pixelSize: 13
            }
        }
    }
}