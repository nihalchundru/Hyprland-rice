import QtQuick

// Small text button (Connect / Disconnect / Clear all).
Item {
    id: root

    property string label: ""
    property bool primary: false
    signal clicked()

    width: txt.implicitWidth + 28
    height: 30

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: ma.containsMouse ? Theme.tileHi : (root.primary ? Theme.tileHi : Theme.tile)
        border.width: 1
        border.color: Theme.tileHi
        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
    }

    Text {
        id: txt
        anchors.centerIn: parent
        text: root.label
        color: root.primary ? Theme.accent : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(13)
        font.weight: Font.Medium
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
