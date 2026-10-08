import QtQuick

// Lock / Suspend / Log Out / Reboot / Power Off. Left/Right + Enter, or click.
Item {
    id: root
    width: 576
    height: 136

    property int sel: 1

    readonly property var items: [
        { icon: "lock",      label: "Lock",      run: () => Toggles.lock() },
        { icon: "moon",      label: "Suspend",   run: () => Toggles.suspend() },
        { icon: "log-out",   label: "Log Out",   run: () => Toggles.logout() },
        { icon: "rotate-cw", label: "Reboot",    run: () => Toggles.reboot() },
        { icon: "power",     label: "Power Off", run: () => Toggles.poweroff() }
    ]

    onVisibleChanged: if (visible) keys.forceActiveFocus()

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Left) { root.sel = Math.max(0, root.sel - 1); event.accepted = true; }
            else if (event.key === Qt.Key_Right) { root.sel = Math.min(root.items.length - 1, root.sel + 1); event.accepted = true; }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { root.items[root.sel].run(); event.accepted = true; }
            else if (event.key === Qt.Key_Escape) { Pill.back(); event.accepted = true; }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: root.items

            Item {
                id: tile
                required property var modelData
                required property int index
                readonly property bool sel: root.sel === index

                width: 100
                height: 108

                Rectangle {
                    anchors.fill: parent
                    radius: 24
                    color: tile.sel ? Theme.mix(Theme.body, Theme.accent, 0.42) : Theme.tile
                    Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
                }

                Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 28
                    name: tile.modelData.icon
                    size: 22
                    color: Theme.text
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 18
                    text: tile.modelData.label
                    color: tile.sel ? Theme.text : Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: root.sel = tile.index
                    onClicked: tile.modelData.run()
                }
            }
        }
    }
}
