import QtQuick

// Read-only row: label on the left, value on the right.
Item {
    id: root

    property var def: ({})
    property bool first: false

    width: parent ? parent.width : 0
    height: 48

    Rectangle {
        visible: !root.first
        x: 16
        width: parent.width - 32
        height: 1
        color: Theme.mix(Theme.body, Theme.text, 0.07)
    }

    Text {
        id: lbl
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        text: root.def.label || ""
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 15
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, parent.width - lbl.implicitWidth - 64)
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideMiddle
        text: SysInfo.value(root.def.valueSource)
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 14
    }
}
