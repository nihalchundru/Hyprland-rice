import QtQuick

// One-cell-tall card: title, a chevron that opens the detail page, and a slider.
Item {
    id: root

    property string title: ""
    property string icon: ""
    property bool active: true
    property real value: 0
    signal moved(real v)
    signal opened()

    Rectangle {
        anchors.fill: parent
        radius: Theme.r(24)
        color: Theme.tile
        border.width: 1
        border.color: Theme.tileHi
    }

    Text {
        x: 16
        y: 8
        text: root.title
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(14)
        font.weight: Font.DemiBold
    }

    CircleButton {
        x: parent.width - width - 12
        y: 6
        size: 22
        iconSize: 11
        icon: "chevron-right"
        onClicked: root.opened()
    }

    PillSlider {
        x: 12
        y: parent.height - 30
        width: parent.width - 24
        height: 24
        icon: root.icon
        active: root.active
        value: root.value
        onMoved: v => root.moved(v)
    }
}
