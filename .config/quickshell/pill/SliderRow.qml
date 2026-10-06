import QtQuick

// PillSlider with a percentage label on the right (detail pages).
Item {
    id: root

    property real value: 0
    property string icon: ""
    property bool active: true
    signal moved(real v)

    height: 28

    PillSlider {
        anchors.left: parent.left
        anchors.right: pct.left
        anchors.rightMargin: 12
        value: root.value
        icon: root.icon
        active: root.active
        onMoved: v => root.moved(v)
    }

    Text {
        id: pct
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        horizontalAlignment: Text.AlignRight
        text: Math.round(root.value * 100) + "%"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 12
    }
}
