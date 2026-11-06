import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.tokens
import qs.services
import qs.components

Page {
    id: page
    readonly property var schemes: ["tonal-spot", "content", "expressive", "fidelity", "fruit-salad", "monochrome", "neutral", "rainbow"]
    readonly property var pins: Array.from(M3Config.pinned || [])

    component SCard: Rectangle {
        property string title: ""
        default property alias body: inner.data
        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + 32
        radius: 28
        color: M3Colors.surfaceContainerHigh
        ColumnLayout {
            id: inner
            x: 18; y: 16
            width: parent.width - 36
            spacing: 12
            M3Text { text: title; role: M3Type.titleMedium; color: M3Colors.primary }
        }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: col.implicitHeight + 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: col
            width: parent.width
            spacing: 12

            SCard {
                title: "Appearance"
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    M3Text { Layout.fillWidth: true; text: "Theme"; role: M3Type.bodyLarge }
                    M3Chip { text: "Dark"; icon: "dark_mode"; selected: M3Config.mode === "dark"; onClicked: M3Config.mode = "dark" }
                    M3Chip { text: "Light"; icon: "light_mode"; selected: M3Config.mode === "light"; onClicked: M3Config.mode = "light" }
                }
                M3Text { text: "Color scheme"; role: M3Type.bodyLarge }
                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: page.schemes
                        M3Chip { required property string modelData; text: modelData; selected: M3Config.scheme === modelData; onClicked: M3Config.scheme = modelData }
                    }
                }
                SettingSwitch { title: "Floating bar"; sub: "Rounded bar detached from the screen edges"; checked: M3Config.barFloating; onToggled: v => M3Config.barFloating = v }
            }

            SCard {
                title: "Behavior"
                SettingSwitch { title: "Dock auto-hide"; sub: "Slide the dock away until you hover the bottom edge"; checked: M3Config.dockAutoHide; onToggled: v => M3Config.dockAutoHide = v }
                SettingSwitch { title: "Dock magnification"; sub: "Enlarge the hovered icon and its neighbors"; checked: M3Config.dockMagnify; onToggled: v => M3Config.dockMagnify = v }
                SettingSwitch { title: "Notification previews on lock screen"; sub: "Show the latest notification text while locked"; checked: M3Config.lockNotifPreview; onToggled: v => M3Config.lockNotifPreview = v }
                SettingSwitch { title: "24-hour clock"; checked: M3Config.clock24; onToggled: v => M3Config.clock24 = v }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    M3Text { Layout.fillWidth: true; text: "Temperature"; role: M3Type.bodyLarge }
                    M3Chip { text: "\u00b0F"; selected: M3Config.tempUnit === "F"; onClicked: M3Config.tempUnit = "F" }
                    M3Chip { text: "\u00b0C"; selected: M3Config.tempUnit === "C"; onClicked: M3Config.tempUnit = "C" }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        M3Text { text: "Terminal"; role: M3Type.bodyLarge }
                        M3Text { text: "Used by  >  commands in the launcher"; role: M3Type.bodySmall; color: M3Colors.fgSurfaceVariant }
                    }
                    Rectangle {
                        Layout.preferredWidth: 170; Layout.preferredHeight: 40
                        radius: 20
                        color: M3Colors.surfaceContainerHighest
                        TextInput {
                            anchors.fill: parent
                            anchors.leftMargin: 16; anchors.rightMargin: 16
                            verticalAlignment: TextInput.AlignVCenter
                            text: M3Config.terminal
                            color: M3Colors.fgSurface
                            font.family: M3Type.family
                            font.pixelSize: 14
                            clip: true
                            onEditingFinished: if (text.trim() !== "") M3Config.terminal = text.trim()
                        }
                    }
                }
            }

            SCard {
                title: "Dock apps"
                M3Text { text: "Click an app to unpin it"; role: M3Type.bodySmall; color: M3Colors.fgSurfaceVariant }
                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: page.pins
                        M3Chip { required property string modelData; text: modelData; icon: "close"; onClicked: M3Config.pinned = page.pins.filter(x => x !== modelData) }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 44
                        radius: 22
                        color: M3Colors.surfaceContainerHighest
                        M3Text { visible: addInput.text === ""; x: 18; anchors.verticalCenter: parent.verticalCenter; text: "Desktop entry id, e.g. org.gnome.Nautilus"; color: M3Colors.fgSurfaceVariant; role: M3Type.bodyMedium }
                        TextInput {
                            id: addInput
                            anchors.fill: parent
                            anchors.leftMargin: 18; anchors.rightMargin: 18
                            verticalAlignment: TextInput.AlignVCenter
                            color: M3Colors.fgSurface
                            font.family: M3Type.family
                            font.pixelSize: 14
                            clip: true
                            onAccepted: addBtn.clicked()
                        }
                    }
                    M3Button {
                        id: addBtn
                        icon: "add"; text: "Pin"; variant: "tonal"
                        onClicked: {
                            const id = addInput.text.trim()
                            if (id !== "" && page.pins.indexOf(id) < 0) M3Config.pinned = page.pins.concat([id])
                            addInput.text = ""
                        }
                    }
                }
            }

            SCard {
                title: "Maintenance"
                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    M3Button { text: "Re-run matugen"; icon: "palette"; variant: "tonal"; onClicked: Matugen.run() }
                    M3Button { text: "Refresh weather"; icon: "cloud_sync"; variant: "tonal"; onClicked: Weather.refresh() }
                    M3Button { text: "Reload binds"; icon: "keyboard"; variant: "tonal"; onClicked: Keybinds.refresh() }
                    M3Button { text: "Reload shell"; icon: "refresh"; variant: "filled"; onClicked: Quickshell.reload(true) }
                }
            }
        }
    }
}
