import QtQuick

// Settings row: label, then a row of chips to pick one option from.
// An option can carry `fmt` (a date format) to show a live preview as its label.
Item {
    id: root

    property var def: ({})
    property bool first: false

    readonly property var value: Settings.get(def.key)

    width: parent ? parent.width : 0
    height: 46 + chips.implicitHeight + 14

    Rectangle {
        visible: !root.first
        x: 16
        width: parent.width - 32
        height: 1
        color: Theme.mix(Theme.body, Theme.text, 0.07)
    }

    Text {
        x: 16
        y: 14
        text: root.def.label || ""
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
    }

    Flow {
        id: chips
        x: 16
        y: 46
        width: parent.width - 32
        spacing: 8

        Repeater {
            model: root.def.options || []

            Rectangle {
                id: chip
                required property var modelData
                readonly property bool cur: root.value === modelData.value

                width: lbl.implicitWidth + 28
                height: 32
                radius: Theme.r(16)
                color: cur ? Theme.accent : (ma.containsMouse ? Theme.tileHi : Theme.tile)
                Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

                Text {
                    id: lbl
                    anchors.centerIn: parent
                    text: chip.modelData.fmt ? Qt.formatDateTime(Pill.now, chip.modelData.fmt) : chip.modelData.label
                    color: chip.cur ? Theme.onAccent : Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(13)
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Settings.set(root.def.key, chip.modelData.value)
                }
            }
        }
    }
}
