import QtQuick

Row {
    id: root

    readonly property int level: !Net.connected ? 0
        : Net.signal >= 75 ? 4
        : Net.signal >= 50 ? 3
        : Net.signal >= 25 ? 2 : 1

    spacing: 2

    Repeater {
        model: 4

        Item {
            required property int index
            width: 3
            height: 14

            Rectangle {
                anchors.bottom: parent.bottom
                width: 3
                height: 5 + parent.index * 3
                radius: Theme.r(1.5)
                color: parent.index < root.level ? Theme.accent : Theme.faint
                Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
            }
        }
    }
}
