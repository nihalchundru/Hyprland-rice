import QtQuick
import Quickshell.Bluetooth

Item {
    id: root
    width: 560
    height: 360 + Settings.get("notifHistoryH")

    onHeightChanged: Pill.setHeight("control", height)
    Component.onCompleted: Pill.setHeight("control", height)

    readonly property int pad: 16
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var btConnected: Bluetooth.devices.values.find(d => d.connected) ?? null

    Column {
        x: root.pad
        y: root.pad
        width: root.width - root.pad * 2
        spacing: 12

        // ── row 1 ───────────────────────────────────────────────────
        Row {
            width: parent.width
            height: 64
            spacing: 12

            Tile {
                width: (parent.width - 64 - 24) / 2
                icon: "wifi"
                title: "Wi-Fi"
                subtitle: !Net.hasWifi ? "No adapter" : !Net.radioOn ? "Off"
                        : Net.connected ? Net.ssid : "Not connected"
                active: Net.hasWifi && Net.radioOn
                onClicked: Pill.open("wifi", true)
                onToggled: Net.setRadio(!Net.radioOn)
            }

            Tile {
                width: (parent.width - 64 - 24) / 2
                icon: "focus"
                title: "Focus"
                subtitle: Toggles.focus ? "On" : "Off"
                active: Toggles.focus
                onClicked: Toggles.focus = !Toggles.focus
                onToggled: Toggles.focus = !Toggles.focus
            }

            CircleButton {
                icon: "lock"
                onClicked: Toggles.lock()
            }
        }

        // ── row 2 ───────────────────────────────────────────────────
        Row {
            width: parent.width
            height: 64
            spacing: 12

            Tile {
                width: (parent.width - 64 - 24) / 2
                icon: "bluetooth"
                title: "Bluetooth"
                subtitle: !root.adapter ? "No adapter" : !root.adapter.enabled ? "Off"
                        : root.btConnected ? (root.btConnected.name || root.btConnected.deviceName) : "On"
                active: !!root.adapter && root.adapter.enabled
                onClicked: Pill.open("bluetooth", true)
                onToggled: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
            }

            Tile {
                width: (parent.width - 64 - 24) / 2
                icon: "gamepad"
                title: "Game Mode"
                subtitle: Toggles.gameMode ? "On" : "Off"
                active: Toggles.gameMode
                onClicked: Toggles.setGameMode(!Toggles.gameMode)
                onToggled: Toggles.setGameMode(!Toggles.gameMode)
            }

            CircleButton {
                icon: "moon"
                onClicked: Toggles.suspend()
            }
        }

        // ── sound ───────────────────────────────────────────────────
        Item {
            width: parent.width
            height: 76

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: Theme.tile
                border.width: 1
                border.color: Theme.tileHi
            }

            Text {
                x: 16
                y: 10
                text: "Sound"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            CircleButton {
                x: parent.width - width - 12
                y: 8
                size: 24
                iconSize: 12
                icon: "chevron-right"
                onClicked: Pill.open("sound", true)
            }

            PillSlider {
                x: 12
                y: 38
                width: parent.width - 24
                icon: Audio.mutedOf(Audio.sink) ? "volume-mute" : "volume"
                active: !!Audio.sink
                value: Audio.volumeOf(Audio.sink)
                onMoved: v => Audio.setVolume(Audio.sink, v)
            }
        }

        // ── display ─────────────────────────────────────────────────
        Item {
            width: parent.width
            height: 76

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: Theme.tile
                border.width: 1
                border.color: Theme.tileHi
            }

            Text {
                x: 16
                y: 10
                text: "Display"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            CircleButton {
                x: parent.width - width - 12
                y: 8
                size: 24
                iconSize: 12
                icon: "chevron-right"
                onClicked: Pill.open("display", true)
            }

            PillSlider {
                x: 12
                y: 38
                width: parent.width - 24
                icon: "sun"
                active: Brightness.available
                value: Brightness.value
                onMoved: v => Brightness.set(v)
            }
        }

        // ── notifications ───────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: Settings.get("notifHistoryH")
            radius: 24
            color: Theme.tile
            border.width: 1
            border.color: Theme.tileHi

            Text {
                x: 16
                y: 14
                text: "Notifications"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 13
            }

            PillButton {
                visible: Notifs.count > 0
                x: parent.width - width - 12
                y: 8
                label: "Clear all"
                onClicked: Notifs.clear()
            }

            Text {
                visible: Notifs.count === 0
                x: 16
                y: 44
                text: "No notifications"
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }

            ListView {
                visible: Notifs.count > 0
                x: 12
                y: 46
                width: parent.width - 24
                height: parent.height - 58
                clip: true
                spacing: 8
                boundsBehavior: Flickable.StopAtBounds
                model: Notifs.list

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: nCol.implicitHeight + 20
                    radius: 16
                    color: Theme.tileHi

                    Column {
                        id: nCol
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: closeBtn.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: modelData.appName
                            elide: Text.ElideRight
                            color: Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                        }
                        Text {
                            width: parent.width
                            text: modelData.summary
                            elide: Text.ElideRight
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }
                        Text {
                            width: parent.width
                            visible: text !== ""
                            text: modelData.body
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            color: Theme.dim
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    CircleButton {
                        id: closeBtn
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        size: 26
                        iconSize: 12
                        icon: "x"
                        onClicked: modelData.dismiss()
                    }
                }
            }
        }
    }
}
